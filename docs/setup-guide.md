# Setup Guide

## Prerequisites

1. **n8n Instance**
   - n8n Cloud account (recommended) or self-hosted
   - Admin access to create workflows

2. **PostgreSQL Database**
   - Version 12+
   - Empty database named `research_reports`

3. **API Keys**
   - OpenAI API key with GPT-4 access
   - Gmail OAuth2 credentials

## Step-by-Step Setup

### 1. Database Setup

```bash
# Create database
createdb research_reports

# Run schema
psql research_reports < database/schemas/001_initial_schema.sql
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your credentials
```

### 3. Deploy Workflows

```bash
npm install
npm run deploy:all
```

### 4. Initial Configuration

1. In n8n, run the "Database Setup" workflow once
2. Note the Report Generator workflow ID
3. Add to .env: `REPORT_GENERATOR_WORKFLOW_ID=<id>`

### 5. Create Your First Topic

1. Duplicate "Research Report - [TOPIC NAME]" workflow
2. Rename to your topic (e.g., "Research Report - AI Technology")
3. Edit Configuration node:
   - `report_name`: "AI Technology Research"
   - `topic`: "Artificial Intelligence"
   - `keywords`: "AI,machine learning,OpenAI,GPT"
   - `email_senders`: (optional specific senders)
   - `report_recipients`: "team@company.com"
4. Activate the workflow

## Troubleshooting

### Gmail Connection Issues
- Ensure Gmail API is enabled in Google Cloud Console
- Check OAuth redirect URI matches n8n instance

### Database Connection Failed
- Verify PostgreSQL is running
- Check credentials in .env
- Ensure database exists

### No Emails Processing
- Check keywords are broad enough
- Verify workflow is active
- Look at execution logs in n8n
