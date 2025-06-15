#!/usr/bin/env node
const { Client } = require('pg');
const chalk = require('chalk');
require('dotenv').config();

async function getStats() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL
  });
  
  await client.connect();
  
  try {
    // Get overview
    const overviewResult = await client.query(`
      SELECT 
        COUNT(DISTINCT rc.id) as total_reports,
        COUNT(DISTINCT CASE WHEN rc.is_active THEN rc.id END) as active_reports,
        COUNT(DISTINCT pc.id) as total_content,
        COUNT(DISTINCT i.id) as total_insights,
        COUNT(DISTINCT CASE WHEN pc.processed_at >= NOW() - INTERVAL '24 hours' THEN pc.id END) as content_24h,
        COUNT(DISTINCT CASE WHEN i.created_at >= NOW() - INTERVAL '24 hours' THEN i.id END) as insights_24h
      FROM report_configs rc
      LEFT JOIN processed_content pc ON rc.id = pc.report_config_id
      LEFT JOIN insights i ON rc.id = i.report_config_id
    `);
    
    const stats = overviewResult.rows[0];
    
    console.log(chalk.bold('\n📊 PE Research System Stats\n'));
    console.log(chalk.cyan('Reports:'), `${stats.active_reports} active / ${stats.total_reports} total`);
    console.log(chalk.cyan('Content:'), `${stats.total_content} total (${stats.content_24h} in last 24h)`);
    console.log(chalk.cyan('Insights:'), `${stats.total_insights} total (${stats.insights_24h} in last 24h)`);
    
    // Get report details
    const reportsResult = await client.query(`
      SELECT 
        rc.report_name,
        rc.is_active,
        COUNT(DISTINCT pc.id) as content_count,
        COUNT(DISTINCT i.id) as insight_count,
        MAX(pc.processed_at) as last_processed
      FROM report_configs rc
      LEFT JOIN processed_content pc ON rc.id = pc.report_config_id
      LEFT JOIN insights i ON rc.id = i.report_config_id
      GROUP BY rc.id, rc.report_name, rc.is_active
      ORDER BY rc.is_active DESC, insight_count DESC
    `);
    
    console.log(chalk.bold('\n📋 Report Status:\n'));
    reportsResult.rows.forEach(report => {
      const status = report.is_active ? chalk.green('●') : chalk.red('●');
      const lastProcessed = report.last_processed 
        ? new Date(report.last_processed).toLocaleString()
        : 'Never';
      
      console.log(`${status} ${chalk.bold(report.report_name)}`);
      console.log(`  Content: ${report.content_count} | Insights: ${report.insight_count} | Last: ${lastProcessed}`);
    });
    
  } finally {
    await client.end();
  }
}

async function monitor() {
  console.clear();
  console.log(chalk.bold.blue('PE Research Monitoring Dashboard'));
  console.log(chalk.gray('Refreshing every 30 seconds... (Ctrl+C to exit)\n'));
  
  await getStats();
  
  // Refresh every 30 seconds
  if (process.env.ENABLE_MONITORING === 'true') {
    setInterval(async () => {
      console.clear();
      console.log(chalk.bold.blue('PE Research Monitoring Dashboard'));
      console.log(chalk.gray('Refreshing every 30 seconds... (Ctrl+C to exit)\n'));
      await getStats();
    }, 30000);
  }
}

monitor().catch(console.error);
