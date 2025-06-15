#!/usr/bin/env node
const fs = require('fs').promises;
const path = require('path');
const axios = require('axios');
const chalk = require('chalk');
require('dotenv').config();

const N8N_API = process.env.N8N_HOST + '/api/v1';
const API_KEY = process.env.N8N_API_KEY;

const api = axios.create({
  baseURL: N8N_API,
  headers: {
    'X-N8N-API-KEY': API_KEY,
    'Content-Type': 'application/json'
  }
});

async function deployWorkflow(filePath, workflowName) {
  try {
    console.log(chalk.blue(`Deploying ${workflowName}...`));
    
    const content = await fs.readFile(filePath, 'utf8');
    const workflow = JSON.parse(content);
    
    // Check if workflow exists
    const existing = await api.get('/workflows', {
      params: { name: workflow.name }
    }).catch(() => ({ data: { data: [] } }));
    
    if (existing.data.data.length > 0) {
      // Update existing
      await api.patch(`/workflows/${existing.data.data[0].id}`, workflow);
      console.log(chalk.green(`✓ Updated ${workflowName}`));
    } else {
      // Create new
      const response = await api.post('/workflows', workflow);
      console.log(chalk.green(`✓ Created ${workflowName}`));
      
      // Save workflow ID if it's a core workflow
      if (workflowName.includes('Report Generator')) {
        console.log(chalk.yellow(`Report Generator ID: ${response.data.data.id}`));
        console.log(chalk.yellow('Add this to your .env file as REPORT_GENERATOR_WORKFLOW_ID'));
      }
    }
  } catch (error) {
    console.error(chalk.red(`✗ Failed to deploy ${workflowName}:`), error.message);
  }
}

async function deployAll() {
  console.log(chalk.bold('\n🚀 Deploying all workflows to n8n...\n'));
  
  // Deploy in order
  const deploymentOrder = [
    { path: 'workflows/core/01-database-setup.json', name: 'Database Setup' },
    { path: 'workflows/core/02-report-generator.json', name: 'Report Generator' },
    { path: 'workflows/templates/research-report-template.json', name: 'Master Template' },
    { path: 'workflows/utilities/monitoring-dashboard.json', name: 'Monitoring Dashboard' }
  ];
  
  for (const item of deploymentOrder) {
    const filePath = path.join(__dirname, '..', item.path);
    if (await fs.access(filePath).then(() => true).catch(() => false)) {
      await deployWorkflow(filePath, item.name);
    }
  }
  
  console.log(chalk.bold.green('\n✅ Deployment complete!\n'));
  console.log(chalk.cyan('Next steps:'));
  console.log('1. Run the Database Setup workflow in n8n');
  console.log('2. Clone the Master Template for each research topic');
  console.log('3. Configure each clone with specific keywords');
  console.log('4. Activate the workflows\n');
}

deployAll().catch(console.error);
