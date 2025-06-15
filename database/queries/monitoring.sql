-- Monitoring queries for system health

-- Database growth metrics
SELECT 
    'companies' as table_name,
    COUNT(*) as row_count,
    pg_size_pretty(pg_relation_size('companies')) as table_size
FROM companies
UNION ALL
SELECT 
    'contacts' as table_name,
    COUNT(*) as row_count,
    pg_size_pretty(pg_relation_size('contacts')) as table_size
FROM contacts
UNION ALL
SELECT 
    'research_findings' as table_name,
    COUNT(*) as row_count,
    pg_size_pretty(pg_relation_size('research_findings')) as table_size
FROM research_findings
UNION ALL
SELECT 
    'email_tracking' as table_name,
    COUNT(*) as row_count,
    pg_size_pretty(pg_relation_size('email_tracking')) as table_size
FROM email_tracking;

-- Daily activity summary
SELECT 
    DATE(created_at) as date,
    COUNT(CASE WHEN created_at::date = CURRENT_DATE THEN 1 END) as records_today,
    COUNT(*) as total_records
FROM (
    SELECT created_at FROM companies
    UNION ALL
    SELECT created_at FROM contacts
    UNION ALL
    SELECT created_at FROM research_findings
) as all_records
WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Failed email campaigns
SELECT 
    campaign_id,
    COUNT(*) as total_emails,
    COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed_count,
    COUNT(CASE WHEN status = 'bounced' THEN 1 END) as bounced_count
FROM email_tracking
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY campaign_id
HAVING COUNT(CASE WHEN status IN ('failed', 'bounced') THEN 1 END) > 0
ORDER BY failed_count DESC;