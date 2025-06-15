#!/usr/bin/env node
const fs = require('fs').promises;
const path = require('path');
const chalk = require('chalk');

async function validateJSON(filePath) {
  try {
    const content = await fs.readFile(filePath, 'utf8');
    JSON.parse(content);
    return { valid: true };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

async function validateWorkflows() {
  console.log(chalk.bold('Validating workflow files...\n'));
  
  const workflowsDir = path.join(__dirname, '..', 'workflows');
  const results = [];
  
  async function scanDir(dir) {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      
      if (entry.isDirectory()) {
        await scanDir(fullPath);
      } else if (entry.name.endsWith('.json')) {
        const result = await validateJSON(fullPath);
        results.push({
          file: path.relative(workflowsDir, fullPath),
          ...result
        });
      }
    }
  }
  
  await scanDir(workflowsDir);
  
  // Display results
  results.forEach(result => {
    if (result.valid) {
      console.log(chalk.green(`✓ ${result.file}`));
    } else {
      console.log(chalk.red(`✗ ${result.file}: ${result.error}`));
    }
  });
  
  const invalidCount = results.filter(r => !r.valid).length;
  if (invalidCount > 0) {
    console.log(chalk.red(`\n${invalidCount} invalid files found`));
    process.exit(1);
  } else {
    console.log(chalk.green(`\n✅ All ${results.length} workflow files are valid`));
  }
}

validateWorkflows().catch(console.error);
