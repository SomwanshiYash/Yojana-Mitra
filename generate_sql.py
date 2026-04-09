import pandas as pd

df = pd.read_excel('shemesfor_wp.xlsx')

schema_sql = """
-- ============================================================
--  Government Scheme Eligibility Checker — Database
-- ============================================================

CREATE TABLE IF NOT EXISTS schemes (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT    NOT NULL,
    category        TEXT    NOT NULL,
    sub_category    TEXT,
    ministry        TEXT,
    scheme_type     TEXT    DEFAULT 'Central',
    target_group    TEXT    NOT NULL,
    eligibility     TEXT    NOT NULL,
    description     TEXT,
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS eligibility_rules (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    scheme_id       INTEGER NOT NULL REFERENCES schemes(id) ON DELETE CASCADE,
    field           TEXT    NOT NULL,
    operator        TEXT    NOT NULL,
    value           TEXT    NOT NULL
);

CREATE TABLE IF NOT EXISTS applicants (
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

CREATE TABLE IF NOT EXISTS check_results (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    applicant_id    INTEGER NOT NULL REFERENCES applicants(id) ON DELETE CASCADE,
    scheme_id       INTEGER NOT NULL REFERENCES schemes(id)    ON DELETE CASCADE,
    is_eligible     INTEGER NOT NULL DEFAULT 0,
    checked_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_rules_scheme   ON eligibility_rules(scheme_id);
CREATE INDEX IF NOT EXISTS idx_results_app    ON check_results(applicant_id);
CREATE INDEX IF NOT EXISTS idx_results_scheme ON check_results(scheme_id);
"""

schemes_inserts = []
rules_inserts = []

def clean_str(val):
    if pd.isna(val): return ''
    return str(val).replace("'", "''")

def extract_class_from_text(text):
    if not text: return None
    t = text.lower()
    if 'class 9-12' in t or 'classes 9-12' in t or 'class 9 to 12' in t: return '9,10,11,12'
    if 'classes 1-8' in t or 'class 1-8' in t: return '1,2,3,4,5,6,7,8'
    if 'class 8' in t: return '8'
    if 'class 10' in t: return '10'
    if 'class 12' in t: return '12'
    if 'post-matric' in t or 'post matric' in t or 'higher education' in t or 'college' in t or 'ug' in t: return 'Post-Matric,UG,PG'
    if 'pre-matric' in t or 'pre matric' in t: return '1,2,3,4,5,6,7,8,9,10'
    if 'postgraduate' in t or 'pg' in t: return 'PG'
    return None

for index, row in df.iterrows():
    scheme_id = row['scheme_id']
    name = clean_str(row['scheme_name'])
    category = clean_str(row['category'])
    
    occ = str(row['occupation']) if not pd.isna(row['occupation']) else 'All'
    if occ.upper() == 'NULL' or occ.upper() == 'NAN': occ = 'All'
    target_group = occ
    
    description = clean_str(row['description'])
    eligibility = clean_str(row['eligibility_summary'])
    
    # Insert scheme
    schemes_inserts.append(f"INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES ({scheme_id}, '{name}', '{category}', '{target_group}', '{eligibility}', '{description}');")
    
    # Rules
    min_age = row['min_age']
    max_age = row['max_age']
    gender = str(row['gender']) if not pd.isna(row['gender']) else 'All'
    annual_inc = row['annual_income_limit']
    caste_cat = row['caste_categories']
    
    if not pd.isna(min_age):
        rules_inserts.append(f"INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES ({scheme_id}, 'age', 'gte', '{int(min_age)}');")
    if not pd.isna(max_age):
        rules_inserts.append(f"INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES ({scheme_id}, 'age', 'lte', '{int(max_age)}');")
    if gender.upper() not in ['ALL', 'NULL', 'NAN']:
        rules_inserts.append(f"INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES ({scheme_id}, 'gender', 'eq', '{clean_str(gender)}');")
    if occ.upper() not in ['ALL', 'NULL', 'NAN']:
        rules_inserts.append(f"INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES ({scheme_id}, 'occupation', 'eq', '{clean_str(occ)}');")
    if not pd.isna(annual_inc):
        rules_inserts.append(f"INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES ({scheme_id}, 'yearly_income', 'lte', '{int(annual_inc)}');")
    if not pd.isna(caste_cat):
        caste_val = clean_str(caste_cat)
        if caste_val and caste_val.upper() != 'NULL' and caste_val.upper() != 'NAN':
            rules_inserts.append(f"INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES ({scheme_id}, 'caste_category', 'in', '{caste_val}');")
    
    class_req = extract_class_from_text(str(row.get('eligibility_summary', '')) + ' ' + str(row.get('description', '')))
    if class_req:
        rules_inserts.append(f"INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES ({scheme_id}, 'student_class', 'in', '{class_req}');")

with open('database.sql', 'w', encoding='utf-8') as f:
    f.write(schema_sql)
    f.write("\n\n-- Schemes\n")
    f.write("DELETE FROM eligibility_rules;\n")
    f.write("DELETE FROM schemes;\n\n")
    f.write("\n".join(schemes_inserts))
    f.write("\n\n-- Eligibility Rules\n")
    f.write("\n".join(rules_inserts))
    f.write("\n")

print("Done generating database.sql")
