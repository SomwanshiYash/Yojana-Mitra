const fs = require('fs');
const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = path.join(__dirname, 'schemes.db');
const CSV_PATH = path.join(__dirname, 'schemes.csv');

function parseCSVLine(line) {
    const result = [];
    let current = '';
    let inQuotes = false;
    for (let i = 0; i < line.length; i++) {
        const char = line[i];
        if (char === '"' && line[i+1] === '"') {
            current += '"';
            i++;
        } else if (char === '"') {
            inQuotes = !inQuotes;
        } else if (char === ',' && !inQuotes) {
            result.push(current);
            current = '';
        } else {
            current += char;
        }
    }
    result.push(current);
    return result;
}

if (!fs.existsSync(CSV_PATH)) {
    console.error("schemes.csv not found.");
    process.exit(1);
}

const db = new Database(DB_PATH);
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

console.log("Resetting database...");

db.exec(`
    DROP TABLE IF EXISTS check_results;
    DROP TABLE IF EXISTS eligibility_rules;
    DROP TABLE IF EXISTS schemes;
    DROP TABLE IF EXISTS applicants;

    CREATE TABLE schemes (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        scheme_n        TEXT    NOT NULL,
        category        TEXT    NOT NULL,
        target_group    TEXT    NOT NULL,
        description     TEXT,
        eligibility     TEXT
    );

    CREATE TABLE eligibility_rules (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        scheme_id       INTEGER NOT NULL,
        field           TEXT    NOT NULL,
        operator        TEXT    NOT NULL,
        value           TEXT    NOT NULL,
        FOREIGN KEY(scheme_id) REFERENCES schemes(id) ON DELETE CASCADE
    );

    CREATE TABLE applicants (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        name            TEXT    NOT NULL,
        age             INTEGER NOT NULL CHECK (age > 0 AND age < 130),
        gender          TEXT    NOT NULL CHECK (gender IN ('Male','Female','Other')),
        occupation      TEXT    NOT NULL,
        yearly_income   REAL    NOT NULL CHECK (yearly_income >= 0),
        caste_category  TEXT    NOT NULL,
        student_class   TEXT,
        submitted_at    DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE check_results (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        applicant_id    INTEGER NOT NULL,
        scheme_id       INTEGER NOT NULL,
        is_eligible     INTEGER NOT NULL DEFAULT 0,
        checked_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(applicant_id) REFERENCES applicants(id) ON DELETE CASCADE,
        FOREIGN KEY(scheme_id) REFERENCES schemes(id) ON DELETE CASCADE
    );
`);

const rawCSV = fs.readFileSync(CSV_PATH, 'utf-8').trim();
const lines = rawCSV.split('\n');

const headers = parseCSVLine(lines[0].trim());

const insertScheme = db.prepare(`
    INSERT INTO schemes (id, scheme_n, category, target_group, description, eligibility)
    VALUES (?, ?, ?, ?, ?, ?)
`);
const insertRule = db.prepare(`
    INSERT INTO eligibility_rules (scheme_id, field, operator, value)
    VALUES (?, ?, ?, ?)
`);

db.transaction(() => {
    // Start from 1 to skip headers
    for (let i = 1; i < lines.length; i++) {
        if (!lines[i].trim()) continue;
        const cols = parseCSVLine(lines[i].trim());

        const [
            scheme_id, min_age, max_age, gender, occupation, 
            annual_inc, caste_eligible, caste_cate, scheme_n, 
            category, description, eligibility_summary
        ] = cols;

        let target_group = occupation === 'NULL' ? 'All' : occupation;

        function extractClassFromText(text) {
            if (!text) return 'NULL';
            const t = text.toLowerCase();
            if (t.includes('class 9-12') || t.includes('classes 9-12') || t.includes('class 9 to 12')) return '9,10,11,12';
            if (t.includes('classes 1-8') || t.includes('class 1-8')) return '1,2,3,4,5,6,7,8';
            if (t.includes('class 8')) return '8';
            if (t.includes('class 10')) return '10';
            if (t.includes('class 12')) return '12';
            if (t.includes('post-matric') || t.includes('post matric') || t.includes('higher education') || t.includes('college') || t.includes('ug')) return 'Post-Matric,UG,PG';
            if (t.includes('pre-matric') || t.includes('pre matric')) return '1,2,3,4,5,6,7,8,9,10';
            if (t.includes('postgraduate') || t.includes('pg')) return 'PG';
            return 'NULL';
        }
        
        let class_req = extractClassFromText(eligibility_summary + ' ' + description);

        insertScheme.run(
            parseInt(scheme_id.trim()), 
            scheme_n.trim(), 
            category.trim(), 
            target_group, 
            description.replace(/^"|"$/g, '').trim(), 
            eligibility_summary.replace(/^"|"$/g, '').trim()
        );

        // Add rules
        if (min_age.trim().toUpperCase() !== 'NULL') {
            insertRule.run(scheme_id, 'age', 'gte', min_age.trim());
        }
        if (max_age.trim().toUpperCase() !== 'NULL') {
            insertRule.run(scheme_id, 'age', 'lte', max_age.trim());
        }
        if (gender.trim().toUpperCase() !== 'ALL' && gender.trim().toUpperCase() !== 'NULL') {
            insertRule.run(scheme_id, 'gender', 'eq', gender.trim());
        }
        if (occupation.trim().toUpperCase() !== 'ALL' && occupation.trim().toUpperCase() !== 'NULL') {
            insertRule.run(scheme_id, 'occupation', 'eq', occupation.trim());
        }
        if (annual_inc.trim().toUpperCase() !== 'NULL') {
            insertRule.run(scheme_id, 'yearly_income', 'lte', annual_inc.trim());
        }
        if (caste_cate.trim().toUpperCase() !== 'NULL' && caste_cate.trim() !== '') {
            let casteVal = caste_cate.replace(/^"|"$/g, '').trim();
            insertRule.run(scheme_id, 'caste_category', 'in', casteVal);
        }
        if (class_req !== 'NULL') {
            insertRule.run(scheme_id, 'student_class', 'in', class_req);
        }
    }
})();

console.log("Database reset and seeded with", lines.length - 1, "schemes successfully!");
