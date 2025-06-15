-- PE Research Automation Database Schema

-- Companies table
CREATE TABLE IF NOT EXISTS companies (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255),
    industry VARCHAR(100),
    employee_count INTEGER,
    headquarters VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contacts table
CREATE TABLE IF NOT EXISTS contacts (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    title VARCHAR(255),
    linkedin_url VARCHAR(500),
    phone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Research findings table
CREATE TABLE IF NOT EXISTS research_findings (
    id SERIAL PRIMARY KEY,
    company_id INTEGER REFERENCES companies(id),
    finding_type VARCHAR(50),
    content TEXT,
    source VARCHAR(255),
    confidence_score DECIMAL(3,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Email tracking table
CREATE TABLE IF NOT EXISTS email_tracking (
    id SERIAL PRIMARY KEY,
    contact_id INTEGER REFERENCES contacts(id),
    campaign_id VARCHAR(100),
    status VARCHAR(50),
    sent_at TIMESTAMP,
    opened_at TIMESTAMP,
    clicked_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_companies_domain ON companies(domain);
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_company ON contacts(company_id);
CREATE INDEX idx_research_company ON research_findings(company_id);