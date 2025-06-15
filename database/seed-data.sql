-- Sample seed data for testing

-- Insert sample companies
INSERT INTO companies (name, domain, industry, employee_count, headquarters, description) VALUES
('TechCorp Solutions', 'techcorp.com', 'Software', 500, 'San Francisco, CA', 'Enterprise software solutions provider'),
('DataDrive Analytics', 'datadrive.io', 'Data Analytics', 150, 'New York, NY', 'AI-powered analytics platform'),
('CloudScale Inc', 'cloudscale.com', 'Cloud Infrastructure', 300, 'Seattle, WA', 'Cloud infrastructure and DevOps tools');

-- Insert sample contacts
INSERT INTO contacts (company_id, email, first_name, last_name, title, linkedin_url) VALUES
(1, 'john.smith@techcorp.com', 'John', 'Smith', 'CEO', 'https://linkedin.com/in/johnsmith'),
(1, 'jane.doe@techcorp.com', 'Jane', 'Doe', 'CTO', 'https://linkedin.com/in/janedoe'),
(2, 'mike.johnson@datadrive.io', 'Mike', 'Johnson', 'Founder & CEO', 'https://linkedin.com/in/mikejohnson'),
(3, 'sarah.williams@cloudscale.com', 'Sarah', 'Williams', 'VP of Sales', 'https://linkedin.com/in/sarahwilliams');