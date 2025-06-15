#!/usr/bin/env node

/**
 * Sync workflows between local files and n8n instance
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const http = require('http');

// Configuration
const N8N_BASE_URL = process.env.N8N_WEBHOOK_URL || 'http://localhost:5678';
const N8N_API_KEY = process.env.N8N_API_KEY || '';
const WORKFLOWS_DIR = path.join(__dirname, '../workflows');

/**
 * Make HTTP request to n8n API
 */
function makeRequest(endpoint, method = 'GET', data = null) {
    return new Promise((resolve, reject) => {
        const url = new URL(endpoint, N8N_BASE_URL);
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
                ...(N8N_API_KEY && { 'X-N8N-API-KEY': N8N_API_KEY })
            }
        };

        const client = url.protocol === 'https:' ? https : http;
        
        const req = client.request(url, options, (res) => {
            let body = '';
            res.on('data', chunk => body += chunk);
            res.on('end', () => {
                try {
                    const result = JSON.parse(body);
                    resolve(result);
                } catch (e) {
                    resolve({ data: body });
                }
            });
        });

        req.on('error', reject);
        
        if (data) {
            req.write(JSON.stringify(data));
        }
        
        req.end();
    });
}

/**
 * Import workflows from local files to n8n
 */
async function importWorkflows() {
    console.log('📦 Importing workflows to n8n...');
    
    const files = fs.readdirSync(WORKFLOWS_DIR).filter(f => f.endsWith('.json'));
    
    for (const file of files) {
        try {
            const filepath = path.join(WORKFLOWS_DIR, file);
            const workflow = JSON.parse(fs.readFileSync(filepath, 'utf8'));
            
            console.log(`Importing ${workflow.name}...`);
            
            // Try to create workflow
            const result = await makeRequest('/rest/workflows', 'POST', workflow);
            
            if (result.error) {
                console.error(`❌ Failed to import ${file}: ${result.message}`);
            } else {
                console.log(`✅ Imported ${workflow.name}`);
            }
        } catch (error) {
            console.error(`❌ Error importing ${file}:`, error.message);
        }
    }
}

/**
 * Export workflows from n8n to local files
 */
async function exportWorkflows(outputDir = WORKFLOWS_DIR) {
    console.log('📋 Exporting workflows from n8n...');
    
    try {
        const response = await makeRequest('/rest/workflows');
        const workflows = response.data || response;
        
        if (!Array.isArray(workflows)) {
            throw new Error('Invalid response from n8n API');
        }
        
        // Ensure output directory exists
        if (!fs.existsSync(outputDir)) {
            fs.mkdirSync(outputDir, { recursive: true });
        }
        
        for (const workflow of workflows) {
            const filename = `${workflow.id.toString().padStart(2, '0')}-${workflow.name.toLowerCase().replace(/[^a-z0-9]+/g, '-')}.json`;
            const filepath = path.join(outputDir, filename);
            
            // Clean up workflow object for export
            const cleanWorkflow = {
                name: workflow.name,
                nodes: workflow.nodes,
                connections: workflow.connections,
                active: workflow.active,
                settings: workflow.settings,
                id: workflow.id
            };
            
            fs.writeFileSync(filepath, JSON.stringify(cleanWorkflow, null, 2));
            console.log(`✅ Exported ${workflow.name} to ${filename}`);
        }
        
        console.log(`📁 Exported ${workflows.length} workflows to ${outputDir}`);
    } catch (error) {
        console.error('❌ Error exporting workflows:', error.message);
    }
}

/**
 * Main function
 */
async function main() {
    const command = process.argv[2];
    const outputDir = process.argv[3];
    
    switch (command) {
        case 'import':
            await importWorkflows();
            break;
        case 'export':
            await exportWorkflows(outputDir);
            break;
        default:
            console.log('Usage: node sync-workflows.js [import|export] [output-dir]');
            console.log('');
            console.log('Commands:');
            console.log('  import  - Import workflows from local files to n8n');
            console.log('  export  - Export workflows from n8n to local files');
            console.log('');
            console.log('Environment variables:');
            console.log('  N8N_WEBHOOK_URL - n8n instance URL (default: http://localhost:5678)');
            console.log('  N8N_API_KEY     - n8n API key (optional)');
            break;
    }
}

if (require.main === module) {
    main().catch(console.error);
}