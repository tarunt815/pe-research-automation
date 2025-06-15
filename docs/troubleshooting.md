# Troubleshooting Guide

## Common Issues

### Database Connection Failed
**Symptoms:** Workflows fail with database connection error

**Solutions:**
1. Check PostgreSQL is running: `pg_isready`
2. Verify credentials in n8n
3. Check firewall/network settings
4. Ensure database exists: `psql -U postgres -l`

### Email Not Sending
**Symptoms:** Email nodes fail or emails not received

**Solutions:**
1. Verify SMTP credentials
2. Check spam folders
3. Review email logs in n8n
4. Test with simple email first
5. Check rate limits

### API Rate Limits
**Symptoms:** 429 errors from external APIs

**Solutions:**
1. Implement rate limiting in workflows
2. Add retry logic with exponential backoff
3. Cache API responses
4. Upgrade API plans if needed

### Workflow Execution Timeouts
**Symptoms:** Workflows fail after long execution

**Solutions:**
1. Break large workflows into smaller ones
2. Optimize database queries
3. Increase n8n timeout settings
4. Use webhook triggers for async processing

## Debug Commands

```bash
# Check n8n logs
docker logs n8n

# Test database connection
psql -h localhost -U your_user -d pe_research -c "SELECT 1;"

# Monitor workflow executions
curl http://localhost:5678/rest/executions

# Check system resources
htop
df -h
```

## Getting Help

1. Check n8n documentation
2. Review workflow logs
3. Enable debug mode in n8n
4. Contact support with error details