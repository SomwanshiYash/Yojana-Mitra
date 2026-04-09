// ============================================================
//  Government Scheme Eligibility Checker — Backend (Node.js)
//  Stack: Express + better-sqlite3 (zero-config, file-based)
//
//  Install:  npm install express better-sqlite3 cors
//  Run:      node server.js
//  API runs on: http://localhost:3001
// ============================================================

const express   = require('express');
const Database  = require('better-sqlite3');
const cors      = require('cors');
const path      = require('path');
const fs        = require('fs');

const app  = express();
const PORT = process.env.PORT || 3001;

// ── Middleware ────────────────────────────────────────────
app.use(cors({ origin: '*' }));       // allow frontend on any port
app.use(express.json());

// ── DB Setup ─────────────────────────────────────────────
const DB_PATH  = path.join(__dirname, 'schemes.db');
const SQL_PATH = path.join(__dirname, 'database.sql');

const db = new Database(DB_PATH);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// Run seed SQL only if the DB is fresh
const isNew = !db.prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='schemes'").get();
if (isNew) {
    if (!fs.existsSync(SQL_PATH)) {
        console.error('database.sql not found — place it in the same folder as server.js');
        process.exit(1);
    }
    const sql = fs.readFileSync(SQL_PATH, 'utf-8');
    db.exec(sql);
    console.log('Database seeded from database.sql');
} else {
    console.log('Database already initialised');
}

// ── Helpers ───────────────────────────────────────────────

/**
 * Evaluate a single eligibility rule against user data.
 * @param {Object} rule   - { field, operator, value }
 * @param {Object} person - { occupation, age, gender, yearly_income }
 */
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

/**
 * Check all schemes for a person and return eligible ones.
 */
function checkEligibility(person) {
    const schemes = db.prepare('SELECT * FROM schemes').all();
    const getRules = db.prepare('SELECT * FROM eligibility_rules WHERE scheme_id = ?');

    return schemes.map(scheme => {
        const rules = getRules.all(scheme.id);
        const rule_evaluations = rules.map(rule => {
            return {
                field: rule.field,
                operator: rule.operator,
                value: rule.value,
                passed: evaluateRule(rule, person),
                actual_value: person[rule.field]
            };
        });
        
        const eligible = rules.length === 0
            ? false
            : rule_evaluations.every(r => r.passed);

        return { ...scheme, eligible, rule_evaluations };
    });
}

// ── Routes ────────────────────────────────────────────────

// GET /api/schemes — all schemes (for browsing)
app.get('/api/schemes', (req, res) => {
    const schemes = db.prepare('SELECT * FROM schemes ORDER BY category, name').all();
    res.json({ success: true, data: schemes });
});

// POST /api/check — main eligibility check
app.post('/api/check', (req, res) => {
    const { name, age, gender, occupation, yearly_income, caste_category, student_class } = req.body;

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

    if (errors.length) return res.status(400).json({ success: false, errors });

    const person = {
        name:          name.trim(),
        age:           parseInt(age),
        gender,
        occupation:    occupation.trim(),
        yearly_income: parseFloat(yearly_income),
        caste_category: caste_category.trim(),
        student_class: student_class ? student_class.trim() : null
    };

    // Persist applicant
    const insertApplicant = db.prepare(
        'INSERT INTO applicants (name, age, gender, occupation, yearly_income, caste_category, student_class) VALUES (?,?,?,?,?,?,?)'
    );
    const applicantRow = insertApplicant.run(
        person.name, person.age, person.gender, person.occupation, person.yearly_income, person.caste_category, person.student_class
    );
    const applicantId = applicantRow.lastInsertRowid;

    // Run eligibility engine
    const results = checkEligibility(person);

    // Persist results
    const insertResult = db.prepare(
        'INSERT INTO check_results (applicant_id, scheme_id, is_eligible) VALUES (?,?,?)'
    );
    const insertMany = db.transaction(() => {
        results.forEach(r => insertResult.run(applicantId, r.id, r.eligible ? 1 : 0));
    });
    insertMany();

    const eligible   = results.filter(r => r.eligible);
    const ineligible = results.filter(r => !r.eligible);

    res.json({
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
});

// GET /api/history — last 20 checks
app.get('/api/history', (req, res) => {
    const rows = db.prepare(`
        SELECT a.name, a.age, a.gender, a.occupation, a.yearly_income, a.caste_category, a.student_class, a.submitted_at,
               COUNT(CASE WHEN cr.is_eligible = 1 THEN 1 END) as matched_schemes
        FROM applicants a
        LEFT JOIN check_results cr ON cr.applicant_id = a.id
        GROUP BY a.id
        ORDER BY a.submitted_at DESC
        LIMIT 20
    `).all();
    res.json({ success: true, data: rows });
});

// Health check
app.get('/api/health', (_, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

// Serve frontend
app.get('/', (req, res) => res.sendFile(path.join(__dirname, 'index.html')));

// ── Start Server ──────────────────────────────────────────
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
    console.log(`   POST /api/check     -> eligibility check`);
    console.log(`   GET  /api/schemes   -> all schemes`);
    console.log(`   GET  /api/history   -> recent checks`);
});
