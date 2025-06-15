#!/usr/bin/env node
const fs = require('fs').promises;
const path = require('path');
const { exec } = require('child_process');
const util = require('util');
const chalk = require('chalk');
require('dotenv').config();

const execAsync = util.promisify(exec);

async function backupDatabase() {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupDir = path.join(__dirname, '..', 'backups');
  const backupFile = `research_reports_${timestamp}.sql`;
  
  await fs.mkdir(backupDir, { recursive: true });
  
  console.log(chalk.blue('Backing up database...'));
  
  const pgDumpCommand = `pg_dump ${process.env.DATABASE_URL} > ${path.join(backupDir, backupFile)}`;
  
  try {
    await execAsync(pgDumpCommand);
    console.log(chalk.green(`✓ Database backed up to ${backupFile}`));
    
    // Compress
    await execAsync(`gzip ${path.join(backupDir, backupFile)}`);
    console.log(chalk.green('✓ Backup compressed'));
    
    // Clean old backups
    const files = await fs.readdir(backupDir);
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - (process.env.BACKUP_RETENTION_DAYS || 30));
    
    for (const file of files) {
      const filePath = path.join(backupDir, file);
      const stats = await fs.stat(filePath);
      if (stats.mtime < cutoffDate) {
        await fs.unlink(filePath);
        console.log(chalk.yellow(`Deleted old backup: ${file}`));
      }
    }
  } catch (error) {
    console.error(chalk.red('Backup failed:'), error);
  }
}

async function backupWorkflows() {
  console.log(chalk.blue('Backing up workflows...'));
  // Implementation for workflow backup via n8n API
}

async function runBackup() {
  console.log(chalk.bold('\n🔄 Starting backup process...\n'));
  
  await backupDatabase();
  await backupWorkflows();
  
  console.log(chalk.bold.green('\n✅ Backup complete!\n'));
}

runBackup().catch(console.error);
