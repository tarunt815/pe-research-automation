#!/bin/bash

# PE Research Automation Deployment Script

set -e

echo "🚀 Starting deployment..."

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "❌ .env file not found. Please copy .env.example to .env and configure it."
    exit 1
fi

# Source environment variables
source .env

echo "📦 Setting up database..."

# Check if PostgreSQL is running
if ! pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER; then
    echo "❌ PostgreSQL is not accessible. Please check your database configuration."
    exit 1
fi

# Run database migrations
echo "Running database schema..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/schema.sql

# Import seed data (optional)
if [ "$1" = "with-seed" ]; then
    echo "Importing seed data..."
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f database/seed-data.sql
fi

echo "📋 Importing workflows to n8n..."

# Import workflows
node scripts/sync-workflows.js import

echo "✅ Deployment completed successfully!"
echo ""
echo "Next steps:"
echo "1. Configure credentials in n8n UI"
echo "2. Test database connection in workflows"
echo "3. Activate workflows as needed"
echo "4. Monitor execution logs"