-- Useful Analytics Queries

-- Weekly Processing Summary
SELECT 
  DATE_TRUNC('week', processed_at) as week,
  rc.report_name,
  COUNT(DISTINCT pc.id) as items_processed,
  COUNT(DISTINCT i.id) as insights_generated,
  AVG(i.importance_score) as avg_importance
FROM processed_content pc
JOIN report_configs rc ON pc.report_config_id = rc.id
LEFT JOIN insights i ON pc.id = i.content_id
WHERE pc.processed_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE_TRUNC('week', processed_at), rc.report_name
ORDER BY week DESC, rc.report_name;

-- Top Insights This Week
SELECT 
  rc.report_name,
  i.title,
  i.summary,
  i.importance_score,
  i.created_at
FROM insights i
JOIN report_configs rc ON i.report_config_id = rc.id
WHERE i.created_at >= DATE_TRUNC('week', CURRENT_DATE)
  AND i.importance_score >= 0.8
ORDER BY i.importance_score DESC
LIMIT 20;

-- Report Performance Metrics
SELECT 
  rc.report_name,
  COUNT(DISTINCT pc.id) as total_content,
  COUNT(DISTINCT i.id) as total_insights,
  COUNT(DISTINCT wr.id) as reports_generated,
  AVG(i.importance_score) as avg_insight_score,
  MAX(wr.created_at) as last_report_date
FROM report_configs rc
LEFT JOIN processed_content pc ON rc.id = pc.report_config_id
LEFT JOIN insights i ON rc.id = i.report_config_id
LEFT JOIN weekly_reports wr ON rc.id = wr.report_config_id
GROUP BY rc.id, rc.report_name
ORDER BY total_insights DESC;
