# Architecture Overview

## System Components

### 1. Database Layer
- PostgreSQL for persistent storage
- Tables: companies, contacts, research_findings, email_tracking
- Optimized indexes for performance

### 2. n8n Workflows

#### Workflow 1: Database Setup
- Initializes database schema
- Sets up required tables and indexes
- Creates initial configuration

#### Workflow 2: Sender Discovery
- Scans email sources
- Identifies new companies and contacts
- Enriches contact information

#### Workflow 3: Weekly Processing
- Scheduled weekly execution
- Aggregates research data
- Triggers outreach campaigns

#### Workflow 4: Report Generation
- Compiles analytics
- Generates PDF/Excel reports
- Sends via email

### 3. External Integrations
- OpenAI API for content generation
- LinkedIn for contact enrichment
- Gmail for email operations
- Slack for notifications

## Data Flow

```
Email Sources → Sender Discovery → Database
                                      ↓
                              Weekly Processing
                                      ↓
                              Report Generation → Recipients
```

## Security Considerations
- Credentials stored securely in n8n
- Database access restricted
- API keys rotated regularly
- SSL/TLS for all connections