-- PE Research Automation Database Schema
-- Version: 1.0.0

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Report configurations
CREATE TABLE IF NOT EXISTS report_configs (
    id SERIAL PRIMARY KEY,
    report_name VARCHAR(255) UNIQUE NOT NULL,
    topic VARCHAR(255) NOT NULL,
    keywords TEXT[],
    email_senders TEXT[],
    report_structure JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Processed content
CREATE TABLE IF NOT EXISTS processed_content (
    id SERIAL PRIMARY KEY,
    report_config_id INTEGER REFERENCES report_configs(id) ON DELETE CASCADE,
    source_type VARCHAR(50),
    source_id VARCHAR(255),
    source_date TIMESTAMP,
    source_metadata JSONB,
    extracted_data JSONB,
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processing_version VARCHAR(20) DEFAULT '1.0',
    UNIQUE(report_config_id, source_id)
);

-- Insights
CREATE TABLE IF NOT EXISTS insights (
    id SERIAL PRIMARY KEY,
    report_config_id INTEGER REFERENCES report_configs(id) ON DELETE CASCADE,
    content_id INTEGER REFERENCES processed_content(id) ON DELETE CASCADE,
    insight_type VARCHAR(100),
    title TEXT,
    summary TEXT,
    detailed_data JSONB,
    importance_score DECIMAL(3,2) CHECK (importance_score BETWEEN 0 AND 1),
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Weekly reports
CREATE TABLE IF NOT EXISTS weekly_reports (
    id SERIAL PRIMARY KEY,
    report_config_id INTEGER REFERENCES report_configs(id) ON DELETE CASCADE,
    week_start DATE,
    week_end DATE,
    executive_summary TEXT,
    report_sections JSONB,
    statistics JSONB,
    pdf_url TEXT,
    email_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP,
    recipients TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_report_configs_active ON report_configs(is_active);
CREATE INDEX idx_content_report_date ON processed_content(report_config_id, source_date);
CREATE INDEX idx_insights_report_type ON insights(report_config_id, insight_type);
CREATE INDEX idx_insights_importance ON insights(importance_score DESC);
CREATE INDEX idx_reports_week ON weekly_reports(report_config_id, week_start);

-- Full text search indexes
CREATE INDEX idx_content_search ON processed_content USING gin(to_tsvector('english', source_metadata || ' ' || extracted_data));
CREATE INDEX idx_insights_search ON insights USING gin(to_tsvector('english', title || ' ' || summary));

-- Update trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_report_configs_updated_at BEFORE UPDATE ON report_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
