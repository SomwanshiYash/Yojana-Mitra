// ============================================================
//  Government Scheme Eligibility Checker — Backend (Node.js)
//  Stack: pure HTTP + mysql2 (MySQL database)
//
//  Install:  npm install mysql2
//  Run:      node server.js
//  API runs on: http://localhost:3001
// ============================================================

const http = require('http');
const mysql = require('mysql2/promise');
const path = require('path');
const fs = require('fs');

const PORT = process.env.PORT || 3001;

// ── DB Setup ─────────────────────────────────────────────
let db;

async function initDB() {
    try {
        const connectionString = process.env.DATABASE_URL || process.env.MYSQL_URL || 'mysql://root:@localhost/yojana_mitra';
        
        db = await mysql.createPool({
            uri: connectionString,
            waitForConnections: true,
            connectionLimit: 10,
            queueLimit: 0
        });

        await db.query('SELECT 1');
        console.log('Connected to MySQL successfully!');

        const SQL_PATH = path.join(__dirname, 'database.sql');
        if (!fs.existsSync(SQL_PATH)) {
            console.error('database.sql not found — place it in the same folder as server.js');
            process.exit(1);
        }
        const sql = fs.readFileSync(SQL_PATH, 'utf-8');
        
        const seedDb = await mysql.createConnection({
             uri: connectionString,
             multipleStatements: true
        });
        await seedDb.query(sql);
        await seedDb.end();
        console.log('Database synced from database.sql');

    } catch (err) {
        console.error('Failed to connect to MySQL:', err);
    }
}
initDB();

// ── Helpers ───────────────────────────────────────────────

function evaluateRule(rule, person) {
    const raw = person[rule.field];
    if (raw === undefined || raw === null) return false;

    const asNum = parseFloat(raw);
    const ruleNum = parseFloat(rule.value);

    switch (rule.operator) {
        case 'eq':       return String(raw).toLowerCase() === rule.value.toLowerCase();
        case 'neq':      return String(raw).toLowerCase() !== rule.value.toLowerCase();
        case 'lt':       return asNum <  ruleNum;
        case 'lte':      return asNum <= ruleNum;
        case 'gt':       return asNum >  ruleNum;
        case 'gte':      return asNum >= ruleNum;
        case 'in':       return rule.value.toLowerCase().split(',').map(s => s.trim())
                                .includes(String(raw).toLowerCase());
        case 'contains': return String(raw).toLowerCase().includes(rule.value.toLowerCase());
        default:         return false;
    }
}

async function checkEligibility(person) {
    const [schemes] = await db.query('SELECT * FROM schemes');
    const [rules] = await db.query('SELECT * FROM eligibility_rules');

    return schemes.map(scheme => {
        const schemeRules = rules.filter(r => r.scheme_id === scheme.id);
        const rule_evaluations = schemeRules.map(rule => {
            return {
                field: rule.field,
                operator: rule.operator,
                value: rule.value,
                passed: evaluateRule(rule, person),
                actual_value: person[rule.field]
            };
        });
        
        const eligible = schemeRules.length === 0
            ? false
            : rule_evaluations.every(r => r.passed);

        return { ...scheme, eligible, rule_evaluations };
    });
}

// ── Request Body Parser ───────────────────────────────────
function parseJSONBody(req) {
    return new Promise((resolve, reject) => {
        let body = '';
        req.on('data', chunk => body += chunk.toString());
        req.on('end', () => {
            try {
                resolve(body ? JSON.parse(body) : {});
            } catch (err) {
                reject(err);
            }
        });
        req.on('error', reject);
    });
}

// ── Server / Routes ───────────────────────────────────────
const server = http.createServer(async (req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'OPTIONS, GET, POST, PUT, DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    // Handle preflight
    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    const sendJSON = (statusCode, data) => {
        res.writeHead(statusCode, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(data));
    };

    // GET /api/schemes
    if (req.method === 'GET' && req.url === '/api/schemes') {
        try {
            const [schemes] = await db.query('SELECT * FROM schemes ORDER BY category, name');
            return sendJSON(200, { success: true, data: schemes });
        } catch (err) {
            console.error(err);
            return sendJSON(500, { success: false, error: 'Database error' });
        }
    }

    // POST /api/check
    else if (req.method === 'POST' && req.url === '/api/check') {
        try {
            const body = await parseJSONBody(req);
            const { name, age, gender, occupation, yearly_income, caste_category, student_class } = body;

            // Validation
            const errors = [];
            if (!name || name.trim().length < 2)        errors.push('Name must be at least 2 characters');
            if (!age   || isNaN(age) || age < 1 || age > 120) errors.push('Age must be between 1 and 120');
            if (!gender || !['Male','Female','Other'].includes(gender)) errors.push('Gender must be Male, Female, or Other');
            if (!occupation || occupation.trim().length === 0)          errors.push('Occupation is required');
            if (!caste_category || !['General','SC','ST','OBC'].includes(caste_category)) errors.push('Caste Category is required');
            if (occupation === 'Student' && !student_class) errors.push('Student class is required');
            
            if (yearly_income === undefined || isNaN(yearly_income) || yearly_income < 0)
                errors.push('Yearly income must be a non-negative number');

            if (errors.length) return sendJSON(400, { success: false, errors });

            const person = {
                name:          name.trim(),
                age:           parseInt(age),
                gender,
                occupation:    occupation.trim(),
                yearly_income: parseFloat(yearly_income),
                caste_category: caste_category.trim(),
                student_class: student_class ? student_class.trim() : null
            };

            const [applicantRow] = await db.query(
                'INSERT INTO applicants (name, age, gender, occupation, yearly_income, caste_category, student_class) VALUES (?,?,?,?,?,?,?)',
                [person.name, person.age, person.gender, person.occupation, person.yearly_income, person.caste_category, person.student_class]
            );
            const applicantId = applicantRow.insertId;

            const results = await checkEligibility(person);

            const conn = await db.getConnection();
            try {
                await conn.beginTransaction();
                for (const r of results) {
                    await conn.query(
                        'INSERT INTO check_results (applicant_id, scheme_id, is_eligible) VALUES (?,?,?)',
                        [applicantId, r.id, r.eligible ? 1 : 0]
                    );
                }
                await conn.commit();
            } catch (txnErr) {
                await conn.rollback();
                throw txnErr;
            } finally {
                conn.release();
            }

            const eligible   = results.filter(r => r.eligible);
            const ineligible = results.filter(r => !r.eligible);

            return sendJSON(200, {
                success: true,
                applicant: { id: applicantId, ...person },
                summary: {
                    total:      results.length,
                    eligible:   eligible.length,
                    ineligible: ineligible.length
                },
                eligible_schemes:   eligible,
                ineligible_schemes: ineligible
            });
        } catch (err) {
            console.error(err);
            return sendJSON(500, { success: false, error: 'Database error' });
        }
    }

    // GET /api/history
    else if (req.method === 'GET' && req.url === '/api/history') {
        try {
            const [rows] = await db.query(`
                SELECT a.name, a.age, a.gender, a.occupation, a.yearly_income, a.caste_category, a.student_class, a.submitted_at,
                       COUNT(CASE WHEN cr.is_eligible = 1 THEN 1 END) as matched_schemes
                FROM applicants a
                LEFT JOIN check_results cr ON cr.applicant_id = a.id
                GROUP BY a.id, a.name, a.age, a.gender, a.occupation, a.yearly_income, a.caste_category, a.student_class, a.submitted_at
                ORDER BY a.submitted_at DESC
                LIMIT 20
            `);
            return sendJSON(200, { success: true, data: rows });
        } catch (err) {
            console.error(err);
            return sendJSON(500, { success: false, error: 'Database error' });
        }
    }

    // GET /api/health
    else if (req.method === 'GET' && req.url === '/api/health') {
        return sendJSON(200, { status: 'ok', timestamp: new Date().toISOString() });
    }

    // GET / (Serve frontend)
    else if (req.method === 'GET' && (req.url === '/' || req.url === '/index.html')) {
        const filePath = path.join(__dirname, 'index.html');
        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.writeHead(500);
                return res.end('Error loading index.html');
            }
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(data);
        });
    }

    // Unmatched routes (404)
    else {
        return sendJSON(404, { success: false, error: 'Not found' });
    }
});

// ── Start Server ──────────────────────────────────────────
server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
    console.log(`   POST /api/check     -> eligibility check`);
    console.log(`   GET  /api/schemes   -> all schemes`);
    console.log(`   GET  /api/history   -> recent checks`);
});
