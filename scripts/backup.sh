#!/bin/bash

# PE Research Automation Backup Script

set -e

# Create backup directory with timestamp
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "🔄 Starting backup to $BACKUP_DIR..."

# Source environment variables if .env exists
if [ -f ".env" ]; then
    source .env
fi

# Database backup
if [ ! -z "$DB_HOST" ] && [ ! -z "$DB_USER" ] && [ ! -z "$DB_NAME" ]; then
    echo "📊 Backing up database..."
    PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME > $BACKUP_DIR/database_backup.sql
    echo "✅ Database backup completed"
else
    echo "⚠️  Database credentials not found, skipping database backup"
fi

# Export workflows from n8n
echo "📋 Exporting workflows..."
if command -v node &> /dev/null; then
    node scripts/sync-workflows.js export $BACKUP_DIR/workflows
    echo "✅ Workflows exported"
else
    echo "⚠️  Node.js not found, copying workflow files manually"
    cp -r workflows/ $BACKUP_DIR/workflows/
fi

# Copy configuration files
echo "📁 Copying configuration files..."
cp -r config/ $BACKUP_DIR/config/ 2>/dev/null || echo "⚠️  Config directory not found"
cp .env.example $BACKUP_DIR/ 2>/dev/null || echo "⚠️  .env.example not found"

# Create backup info file
cat > $BACKUP_DIR/backup_info.txt << EOF
Backup Created: $(date)
Hostname: $(hostname)
User: $(whoami)
Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "Not a git repository")
EOF

# Compress backup
echo "🗜️  Compressing backup..."
tar -czf "${BACKUP_DIR}.tar.gz" -C backups $(basename $BACKUP_DIR)
rm -rf $BACKUP_DIR

echo "✅ Backup completed: ${BACKUP_DIR}.tar.gz"
echo "📊 Backup size: $(du -h ${BACKUP_DIR}.tar.gz | cut -f1)"