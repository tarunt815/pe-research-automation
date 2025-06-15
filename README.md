# PE Research Automation System

An intelligent email monitoring and report generation system built on n8n for Private Equity research.

## 🎯 Overview

This system automatically:
- Monitors Gmail for topic-specific content
- Extracts insights using AI (GPT-4)
- Stores data in a flexible PostgreSQL database
- Generates weekly PDF reports
- Supports multiple research topics through workflow cloning

## 📁 Repository Structure

```
pe-research-automation/
├── workflows/
│   ├── core/                 # Core workflows (database setup, report generator)
│   ├── templates/           # Master templates to clone
│   └── utilities/           # Helper workflows (monitoring, cleanup)
├── database/
│   ├── schemas/            # SQL schema definitions
│   ├── migrations/         # Database migrations
│   └── queries/           # Useful SQL queries
├── docs/                  # Documentation
├── scripts/              # Automation scripts
├── config/              # Configuration files
└── tests/              # Test files
```

## 🚀 Quick Start

### Prerequisites
- n8n Cloud account or self-hosted instance
- PostgreSQL database
- Gmail account with OAuth2
- OpenAI API key

### Installation

1. **Clone this repository**
   ```bash
   git clone https://github.com/yourcompany/pe-research-automation.git
   cd pe-research-automation
   ```

2. **Set up environment**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

3. **Deploy to n8n**
   ```bash
   npm install
   npm run deploy:all
   ```

### Creating a New Research Topic

1. Clone the master template in n8n
2. Configure the topic in the workflow:
   ```
   report_name: "Your Topic Name"
   topic: "Research Focus Area"
   keywords: "keyword1,keyword2,keyword3"
   ```
3. Activate the workflow

## 📊 Available Topics

### Pre-configured Templates
- AI & Technology Research
- Healthcare Investment Tracker
- Investment Banking Deals
- Venture Capital Monitor

### Custom Topics
Create any topic by cloning the master template and adjusting keywords.

## 🔧 Configuration

### Environment Variables
```bash
# n8n
N8N_HOST=your-instance.n8n.cloud
N8N_API_KEY=your-api-key

# Database
DATABASE_URL=postgresql://user:pass@host:5432/research_reports

# Notifications
ADMIN_EMAIL=admin@company.com
REPORT_RECIPIENTS=team@company.com
```

## 📈 Monitoring

Access the monitoring dashboard at:
```
https://your-n8n-instance/webhook/research-dashboard
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## 📝 License

MIT License - see LICENSE file

## 🆘 Support

- Documentation: `/docs`
- Issues: GitHub Issues
- Email: research-automation@company.com
