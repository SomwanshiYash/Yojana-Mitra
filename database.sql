
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


-- Schemes
DELETE FROM eligibility_rules;
DELETE FROM schemes;

INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (1, 'PM Scholarship Scheme', 'Education', 'Student', 'Students aged 18-25 who are wards of ex-servicemen with income below 6L', 'Scholarship for wards of ex-servicemen and ex-coast guard for higher education');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (2, 'National Means-cum-Merit Scholarship', 'Education', 'Student', 'Students in Class 9-12 with family income below 1.5L', 'Scholarship to prevent dropout at Class 8 and support meritorious students');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (3, 'Post Matric Scholarship for SC Students', 'Education', 'Student', 'SC students pursuing post-matric education with family income below 2.5L', 'Financial assistance to SC students pursuing post-matriculation education');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (4, 'Central Sector Scholarship for College Students', 'Education', 'Student', 'Students in top 20 percentile in Class 12 with income below 8L', 'Scholarship for top academic performers in higher education');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (5, 'Pradhan Mantri Vidya Lakshmi Karyakram', 'Education', 'Student', 'Any student seeking education loan or scholarship for higher studies', 'Unified portal for education loan and scholarship applications');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (6, 'Ishan Uday Scholarship for North East', 'Education', 'Student', 'Students from NE states pursuing higher education with income below 6L', 'Special scholarship for students from North Eastern states');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (7, 'Pragati Scholarship for Girl Students', 'Education', 'Student', 'Girl students in AICTE-approved institutions with family income below 8L', 'Scholarship for girl students pursuing technical education');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (8, 'Saksham Scholarship for Disabled Students', 'Education', 'Student', 'Students with 40% or more disability in AICTE-approved courses', 'Scholarship for differently-abled students in technical institutions');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (9, 'Mid-Day Meal Scheme', 'Food', 'Student', 'All children enrolled in Classes 1-8 in government schools', 'Free cooked meals provided to children in government and aided schools');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (10, 'PM POSHAN Scheme', 'Food', 'All', 'Children aged 3-6 attending Anganwadi centres across India', 'Nutritional support to children in Anganwadis and pre-primary schools');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (11, 'Antyodaya Anna Yojana', 'Food', 'All', 'Families identified as poorest of poor under BPL category', 'Subsidised foodgrains at lowest prices for poorest of poor families');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (12, 'Pradhan Mantri Garib Kalyan Anna Yojana', 'Food', 'All', 'NFSA beneficiaries entitled to 5 kg free grain per person per month', 'Free foodgrains to poor households under National Food Security Act');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (13, 'National Food Security Act', 'Food', 'All', 'BPL and priority household members receiving 5 kg grain at subsidized rates', 'Subsidised food grains to priority households and Antyodaya families');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (14, 'Integrated Child Development Services', 'Food', 'All', 'Children under 6 and pregnant/lactating mothers in targeted areas', 'Nutrition and health services to children under 6 and pregnant women');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (15, 'Rajiv Gandhi Scheme for Empowerment of Adolescent Girls', 'Food', 'All', 'Girls aged 11-18 in selected districts especially out-of-school girls', 'Nutrition supplementation and life skills for adolescent girls');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (16, 'PM Kisan Samman Nidhi', 'Agriculture', 'Farmer', 'Farmers with cultivable land registered in PM-KISAN portal; Farmers with income <= 6L', 'Direct income support of 6000 per year to small and marginal farmers');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (17, 'PM Fasal Bima Yojana', 'Agriculture', 'Farmer', 'All farmers growing notified crops in notified areas eligible', 'Crop insurance to protect farmers against natural calamities');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (18, 'Kisan Credit Card Scheme', 'Agriculture', 'Farmer', 'Farmers with land records and valid cultivation history', 'Short-term credit facility for farmers to meet agricultural needs');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (19, 'Soil Health Card Scheme', 'Agriculture', 'Farmer', 'All farmers who own or cultivate land are eligible to apply', 'Provides soil health reports and fertilizer recommendations to farmers');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (20, 'PM Krishi Sinchayee Yojana', 'Agriculture', 'Farmer', 'Farmers with agricultural land who need irrigation infrastructure', 'Promotes water use efficiency and assured irrigation to farmers');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (21, 'National Agriculture Market e-NAM', 'Agriculture', 'Farmer', 'Farmers registered with their local Agricultural Produce Market Committee', 'Online trading platform for agricultural commodities across India');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (22, 'Paramparagat Krishi Vikas Yojana', 'Agriculture', 'Farmer', 'Farmers willing to adopt organic farming in groups of 50+', 'Promotes organic farming through cluster approach and certification');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (23, 'PM Kisan Maandhan Yojana', 'Agriculture', 'Farmer', 'Small/marginal farmers aged 18-40 with land up to 2 hectares', 'Pension scheme providing 3000 per month to small and marginal farmers');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (24, 'Agriculture Infrastructure Fund', 'Agriculture', 'Farmer', 'Farmers FPOs cooperatives and agri-entrepreneurs eligible', 'Financing facility for post-harvest management and agri infrastructure');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (25, 'Rashtriya Krishi Vikas Yojana', 'Agriculture', 'Farmer', 'Farmers and state government bodies in agriculture and allied sectors', 'Additional central assistance to incentivize agricultural development');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (26, 'Ayushman Bharat PM-JAY', 'Health', 'All', 'Bottom 40% economically vulnerable families identified through SECC database; Income <= 5L', 'Health insurance cover of 5 lakh per family per year for poor households');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (27, 'Janani Suraksha Yojana', 'Health', 'All', 'Pregnant women from BPL families delivering in government health facilities', 'Cash assistance to poor pregnant women for institutional delivery');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (28, 'Pradhan Mantri Surakshit Matritva Abhiyan', 'Health', 'All', 'All pregnant women in their 2nd or 3rd trimester eligible', 'Free antenatal checkups to pregnant women on fixed day every month');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (29, 'National Immunisation Programme', 'Health', 'All', 'All children from birth to 5 years and pregnant women eligible', 'Free vaccines to protect children from life-threatening diseases');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (30, 'Rashtriya Swasthya Bima Yojana', 'Health', 'All', 'BPL families and unorganised sector workers and their families; Income <= 3L', 'Health insurance of 30000 for BPL families including unorganised workers');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (31, 'National Mental Health Programme', 'Health', 'All', 'All citizens needing mental health care through public health facilities', 'Community-based mental health services through district mental health program');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (32, 'PM TB Mukt Bharat Abhiyan', 'Health', 'All', 'All TB patients notified and registered in Ni-kshay system', 'Nutritional support and treatment linkage for TB patients in India');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (33, 'Pradhan Mantri Bhartiya Jan Aushadhi Pariyojana', 'Health', 'All', 'All citizens can purchase medicines at 50-90% lower cost at PMBJP stores', 'Affordable generic medicines available at Jan Aushadhi Kendras');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (34, 'National Programme for Non-Communicable Diseases', 'Health', 'All', 'Adults 30 and above eligible for free screening at health and wellness centres', 'Prevention and control of diabetes cancer and cardiovascular diseases');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (35, 'Ayushman Bharat Health and Wellness Centres', 'Health', 'All', 'All citizens in rural and urban areas near Health and Wellness Centres', 'Comprehensive primary health care at upgraded sub-centres and PHCs');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (36, 'Mahatma Gandhi NREGA', 'Employment', 'All', 'Rural households willing to do unskilled manual work eligible', 'Guarantees 100 days of unskilled wage employment per year to rural households');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (37, 'Pradhan Mantri Rojgar Protsahan Yojana', 'Employment', 'All', 'New employees earning up to 15000 per month in EPFO-registered establishments', 'Government pays EPF contribution for new employees to boost formal employment');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (38, 'Deen Dayal Upadhyaya Grameen Kaushalya Yojana', 'Employment', 'All', 'Rural youth aged 15-35 from poor families in selected districts', 'Skill training and placement for rural youth below poverty line');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (39, 'Pradhan Mantri Kaushal Vikas Yojana', 'Employment', 'All', 'Indian nationals aged 15-45 seeking skill training and certification', 'Free short-term skill training and certification to youth of India');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (40, 'National Career Service Portal', 'Employment', 'All', 'All job seekers who register on the NCS portal are eligible', 'Job matching platform connecting job seekers with employers nationwide');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (41, 'PM SVANidhi Scheme', 'Employment', 'All', 'Street vendors with vending certificate or letter of recommendation eligible', 'Collateral-free working capital loans to street vendors affected by COVID');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (42, 'Startup India Scheme', 'Employment', 'Entrepreneur', 'DPIIT-recognized startups less than 10 years old with turnover under 100 crore', 'Funding support tax benefits and simplification for eligible startups');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (43, 'Stand Up India', 'Employment', 'Entrepreneur', 'SC/ST and women entrepreneurs setting up greenfield enterprises', 'Loans between 10 lakh and 1 crore to SC/ST and women entrepreneurs');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (44, 'Pradhan Mantri MUDRA Yojana', 'Employment', 'Entrepreneur', 'Non-farm income-generating businesses needing credit up to 10 lakh', 'Loans up to 10 lakh for non-farm micro and small enterprises');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (45, 'National Apprenticeship Promotion Scheme', 'Employment', 'All', 'Employers engaging apprentices and candidates wanting to undergo apprenticeship', 'Stipend support to apprentices and employers to boost apprenticeships');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (46, 'Pradhan Mantri Awas Yojana Urban', 'Housing', 'All', 'Urban residents belonging to EWS/LIG/MIG without pucca house; Income <= 6L', 'Affordable housing assistance for EWS LIG and MIG in urban areas');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (47, 'Pradhan Mantri Awas Yojana Gramin', 'Housing', 'All', 'Rural BPL households without pucca house listed in SECC data; Income <= 6L', 'Financial assistance to BPL rural households for constructing pucca house');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (48, 'Indira Awas Yojana', 'Housing', 'All', 'BPL rural families including SC/ST needing housing assistance', 'Rural housing scheme merged into PMAY-G providing financial aid for houses');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (49, 'Rajiv Awas Yojana', 'Housing', 'All', 'Slum dwellers and urban poor in cities identified under RAY', 'Slum-free India mission providing housing to slum dwellers in cities');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (50, 'Basic Services for Urban Poor', 'Housing', 'All', 'Urban poor living in slums without ownership rights', 'Provides tenure security and basic amenities to urban slum dwellers');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (51, 'Credit Linked Subsidy Scheme', 'Housing', 'All', 'First-time homebuyers in EWS/LIG/MIG income categories eligible', 'Interest subsidy on home loans for EWS/LIG/MIG under PMAY');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (52, 'Deen Dayal Antyodaya Yojana Urban', 'Housing', 'All', 'Urban poor including street vendors and slum dwellers eligible', 'Affordable housing and livelihood support for urban poor communities');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (53, 'Pradhan Mantri Jan Dhan Yojana', 'Finance', 'All', 'Any Indian citizen above 18 without a bank account eligible', 'Zero-balance bank account with RuPay debit card and overdraft facility');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (54, 'Atal Pension Yojana', 'Finance', 'All', 'Indian citizens aged 18-40 with a savings bank account', 'Government-backed pension scheme for unorganised sector workers');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (55, 'PM Jeevan Jyoti Bima Yojana', 'Finance', 'All', 'Bank account holders aged 18-50 eligible for this life insurance', 'Life insurance of 2 lakh at annual premium of 436 rupees');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (56, 'PM Suraksha Bima Yojana', 'Finance', 'All', 'Bank account holders aged 18-70 eligible for accident insurance', 'Accidental insurance of 2 lakh at premium of only 20 rupees per year');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (57, 'Sukanya Samriddhi Yojana', 'Finance', 'All', 'Girl children below 10 years of age for whom account is opened by parents', 'High-interest savings scheme for girl children to fund education and marriage');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (58, 'Public Provident Fund', 'Finance', 'All', 'Any Indian resident above 18 can open a PPF account', 'Long-term savings scheme with tax benefits and government-backed returns');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (59, 'Kisan Vikas Patra', 'Finance', 'All', 'Any Indian citizen above 18 with valid KYC can invest', 'Savings certificate scheme doubling investment in fixed years');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (60, 'National Pension System', 'Finance', 'All', 'Indian citizens aged 18-70 including NRIs can subscribe to NPS', 'Voluntary long-term pension scheme for citizens in organised and unorganised sector');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (61, 'Senior Citizen Savings Scheme', 'Finance', 'All', 'Indian residents aged 60 and above or 55 if retired under VRS', 'High-interest savings scheme with tax benefits exclusively for senior citizens');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (62, 'Pradhan Mantri Matru Vandana Yojana', 'Women & Child', 'All', 'Pregnant women above 18 for first live birth eligible for cash transfer', 'Maternity benefit of 5000 to pregnant and lactating mothers for first child');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (63, 'Beti Bachao Beti Padhao', 'Women & Child', 'All', 'Girl children in selected 100 districts and their families', 'Campaign to address decline in child sex ratio and promote girl education');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (64, 'One Stop Centre Scheme', 'Women & Child', 'All', 'Women above 18 who are victims of violence in any form', 'Integrated support services to women affected by violence at one location');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (65, 'Mahila Shakti Kendra', 'Women & Child', 'All', 'Rural women in selected districts eligible for skill and capacity building', 'Empowers rural women through community participation and awareness');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (66, 'Ujjwala Yojana', 'Women & Child', 'All', 'Women above 18 from BPL families without LPG connection eligible', 'Free LPG connection to women from BPL households for clean cooking');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (67, 'Working Women Hostel', 'Women & Child', 'All', 'Working women with income up to 50000 per month in urban areas', 'Safe and affordable hostel accommodation for working women in cities');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (68, 'Integrated Child Protection Scheme', 'Women & Child', 'All', 'Children below 18 in difficult circumstances or in conflict with law', 'Protection services and rehabilitation for children in need of care');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (69, 'SABLA Scheme', 'Women & Child', 'All', 'Girls aged 11-18 in selected blocks especially out-of-school girls', 'Holistic development of adolescent girls through nutrition and life skills');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (70, 'National Creche Scheme', 'Women & Child', 'All', 'Working women with children aged 6 months to 6 years eligible', 'Day care facilities for children of working women at subsidized cost');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (71, 'Indira Gandhi National Old Age Pension', 'Senior Citizen', 'All', 'Destitute persons aged 60 and above from BPL households; Income <= 2L', 'Monthly pension to BPL senior citizens who are above 60 years of age');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (72, 'National Programme for Health Care of Elderly', 'Senior Citizen', 'All', 'All citizens aged 60 and above through public health infrastructure', 'Dedicated healthcare services to elderly through sub-centres and hospitals');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (73, 'Rashtriya Vayoshri Yojana', 'Senior Citizen', 'All', 'BPL senior citizens with low vision hearing loss or mobility impairment', 'Free assistive living devices to BPL senior citizens with age-related disabilities');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (74, 'Senior Citizen Welfare Fund', 'Senior Citizen', 'All', 'Senior citizens in need of rehabilitation and welfare support', 'Utilises unclaimed deposits for welfare activities for senior citizens');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (75, 'Vayo Mitra Scheme', 'Senior Citizen', 'All', 'All senior citizens aged 60 and above in need of emergency support', 'Integrated helpline and outreach services for elderly citizens in distress');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (76, 'Annapurna Scheme', 'Senior Citizen', 'All', 'Destitute persons aged 65 and above not covered under old age pension', 'Free food grains to destitute senior citizens not covered under NOAPS');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (77, 'Indira Gandhi National Disability Pension', 'Senior Citizen', 'All', 'Persons aged 18-79 with 80% or more disability from BPL families', 'Monthly pension to severely disabled BPL persons');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (78, 'National Action Plan for Senior Citizens', 'Senior Citizen', 'All', 'All senior citizens aged 60 and above as beneficiaries of policy measures', 'Policy framework for welfare housing health care and social support for elderly');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (79, 'Elder Line National Helpline', 'Senior Citizen', 'All', 'Any senior citizen aged 60 and above can access the 14567 helpline', 'Toll-free helpline providing information emotional support to senior citizens');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (80, 'Varishtha Pension Bima Yojana', 'Senior Citizen', 'All', 'Senior citizens aged 60 and above investing lump sum through LIC', 'LIC-backed guaranteed pension plan offering 9.3% return to senior citizens');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (81, 'Pradhan Mantri Ujjwala Yojana 2.0', 'Women & Child', 'All', 'Women from poor migrant households and BPL families without LPG eligible', 'Extended LPG connections with first refill free to poor migrant households');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (82, 'Janani Shishu Suraksha Karyakram', 'Health', 'All', 'All pregnant women delivering in government hospitals and sick newborns', 'Free delivery and newborn care entitlements at public health facilities');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (83, 'Rashtriya Kishor Swasthya Karyakram', 'Health', 'All', 'Adolescents aged 10-19 accessing health services through public facilities', 'Adolescent health and wellness programme through peer education and clinics');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (84, 'National Tobacco Control Programme', 'Health', 'All', 'All citizens particularly tobacco users accessing NTCP centres', 'Awareness and cessation services to reduce tobacco use in India');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (85, 'Accessible India Campaign', 'Employment', 'All', 'Persons with disabilities and organisations working for their welfare', 'Making built environment transport and ICT accessible for persons with disability');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (86, 'Deendayal Disabled Rehabilitation Scheme', 'Employment', 'All', 'Persons with disability needing rehabilitation through NGO-run centres', 'Financial assistance to NGOs for rehabilitation services for persons with disability');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (87, 'PM Awas Yojana SC ST Component', 'Housing', 'All', 'SC/ST households without pucca house in rural areas under SECC database', 'Priority housing for SC and ST communities under PMAY rural component');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (88, 'National Rural Livelihood Mission', 'Employment', 'All', 'Rural poor women mobilised into Self Help Groups under DAY-NRLM', 'Mobilises rural poor women into SHGs and provides livelihood opportunities');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (89, 'PM Employment Generation Programme', 'Employment', 'Entrepreneur', 'Artisans entrepreneurs aged 18-35 for new micro enterprise setup', 'Credit-linked subsidy for setting up micro enterprises in rural and urban areas');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (90, 'Pradhan Mantri Vaya Vandana Yojana', 'Senior Citizen', 'All', 'Senior citizens aged 60 and above investing in LIC PMVVY plan', 'LIC pension scheme offering assured returns of 7.4% for 10 years');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (91, 'National Scholarship Portal', 'Education', 'Student', 'Students at any level with family income below 2.5L registered on NSP', 'Central platform for multiple government scholarships for pre and post matric');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (92, 'Eklavya Model Residential Schools', 'Education', 'Student', 'Scheduled Tribe children in blocks with over 50% ST population', 'Residential schooling for ST children with focus on tribal culture');
INSERT INTO schemes (id, name, category, target_group, eligibility, description) VALUES (93, 'Pre-Matric Scholarship for Minorities', 'Education', 'Student', '', 'Scholarship for minority community stu');

-- Eligibility Rules
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (1, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (1, 'age', 'lte', '25');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (1, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (1, 'yearly_income', 'lte', '600000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (1, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (2, 'age', 'gte', '13');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (2, 'age', 'lte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (2, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (2, 'yearly_income', 'lte', '150000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (2, 'student_class', 'in', '9,10,11,12');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (3, 'age', 'gte', '15');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (3, 'age', 'lte', '30');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (3, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (3, 'yearly_income', 'lte', '250000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (3, 'caste_category', 'in', 'SC');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (3, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (4, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (4, 'age', 'lte', '25');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (4, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (4, 'yearly_income', 'lte', '800000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (4, 'student_class', 'in', '12');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (5, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (5, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (6, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (6, 'age', 'lte', '30');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (6, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (6, 'yearly_income', 'lte', '600000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (6, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (7, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (7, 'age', 'lte', '30');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (7, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (7, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (7, 'yearly_income', 'lte', '800000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (8, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (8, 'age', 'lte', '30');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (8, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (8, 'yearly_income', 'lte', '800000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (9, 'age', 'gte', '6');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (9, 'age', 'lte', '14');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (9, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (9, 'student_class', 'in', '1,2,3,4,5,6,7,8');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (10, 'age', 'gte', '3');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (10, 'age', 'lte', '6');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (14, 'age', 'gte', '0');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (14, 'age', 'lte', '6');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (15, 'age', 'gte', '11');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (15, 'age', 'lte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (15, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (16, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (16, 'age', 'lte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (16, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (16, 'yearly_income', 'lte', '600000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (17, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (17, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (18, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (18, 'age', 'lte', '75');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (18, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (19, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (19, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (20, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (20, 'age', 'lte', '65');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (20, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (21, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (21, 'age', 'lte', '65');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (21, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (22, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (22, 'age', 'lte', '65');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (22, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (22, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (23, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (23, 'age', 'lte', '40');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (23, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (24, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (24, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (25, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (25, 'age', 'lte', '65');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (25, 'occupation', 'eq', 'Farmer');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (26, 'yearly_income', 'lte', '500000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (26, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (27, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (28, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (29, 'age', 'lte', '5');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (30, 'yearly_income', 'lte', '300000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (31, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (34, 'age', 'gte', '30');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (35, 'student_class', 'in', 'PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (36, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (36, 'age', 'lte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (37, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (38, 'age', 'gte', '15');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (38, 'age', 'lte', '35');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (38, 'caste_category', 'in', 'SC, ST, OBC');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (39, 'age', 'gte', '15');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (39, 'age', 'lte', '45');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (40, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (41, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (41, 'age', 'lte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (42, 'age', 'gte', '21');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (42, 'age', 'lte', '50');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (42, 'occupation', 'eq', 'Entrepreneur');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (43, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (43, 'age', 'lte', '55');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (43, 'occupation', 'eq', 'Entrepreneur');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (43, 'caste_category', 'in', 'SC, ST');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (44, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (44, 'occupation', 'eq', 'Entrepreneur');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (44, 'yearly_income', 'lte', '1000000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (45, 'age', 'gte', '14');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (45, 'age', 'lte', '30');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (46, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (46, 'age', 'lte', '70');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (46, 'yearly_income', 'lte', '300000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (46, 'caste_category', 'in', 'EWS');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (47, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (47, 'age', 'lte', '70');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (47, 'yearly_income', 'lte', '600000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (47, 'caste_category', 'in', 'SC, ST');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (48, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (48, 'caste_category', 'in', 'SC, ST');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (49, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (50, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (51, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (51, 'age', 'lte', '70');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (51, 'yearly_income', 'lte', '1800000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (51, 'caste_category', 'in', 'EWS');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (52, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (52, 'age', 'lte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (53, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (54, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (54, 'age', 'lte', '40');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (55, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (55, 'age', 'lte', '50');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (56, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (56, 'age', 'lte', '70');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (57, 'age', 'lte', '10');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (57, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (58, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (59, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (60, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (60, 'age', 'lte', '70');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (61, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (62, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (62, 'age', 'lte', '45');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (62, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (62, 'yearly_income', 'lte', '200000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (63, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (64, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (65, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (65, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (66, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (66, 'age', 'lte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (66, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (66, 'yearly_income', 'lte', '200000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (66, 'student_class', 'in', 'PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (67, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (67, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (68, 'age', 'lte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (69, 'age', 'gte', '11');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (69, 'age', 'lte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (69, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (69, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (70, 'age', 'gte', '6');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (70, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (71, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (71, 'age', 'lte', '100');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (71, 'yearly_income', 'lte', '200000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (72, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (72, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (73, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (74, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (75, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (76, 'age', 'gte', '65');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (77, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (77, 'age', 'lte', '79');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (78, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (79, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (80, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (80, 'age', 'lte', '80');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (80, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (81, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (81, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (81, 'student_class', 'in', 'PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (82, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (83, 'age', 'gte', '10');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (83, 'age', 'lte', '19');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (83, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (86, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (87, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (87, 'caste_category', 'in', 'SC, ST');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (88, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (88, 'age', 'lte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (88, 'gender', 'eq', 'Female');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (88, 'caste_category', 'in', 'SC, ST');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (89, 'age', 'gte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (89, 'age', 'lte', '35');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (89, 'occupation', 'eq', 'Entrepreneur');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (89, 'caste_category', 'in', 'SC, ST, OBC');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (90, 'age', 'gte', '60');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (91, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (91, 'yearly_income', 'lte', '250000');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (91, 'caste_category', 'in', 'SC, ST, OBC, EWS');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (91, 'student_class', 'in', 'Post-Matric,UG,PG');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (92, 'age', 'gte', '6');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (92, 'age', 'lte', '18');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (92, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (92, 'caste_category', 'in', 'ST');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (93, 'occupation', 'eq', 'Student');
INSERT INTO eligibility_rules (scheme_id, field, operator, value) VALUES (93, 'yearly_income', 'lte', '100000');
