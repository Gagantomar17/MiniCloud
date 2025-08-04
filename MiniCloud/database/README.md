# MiniCloud Database Setup

This directory contains the database schema and configuration files for the MiniCloud application.

## Files Overview

- `minicloud_production.sql` - Complete production-ready database schema with advanced features
- `minicloud_simple.sql` - Simple schema matching the current entity structure
- `application-prod.properties` - Production database configuration
- `application-dev.properties` - Development database configuration
- `README.md` - This file

## Quick Setup

### 1. Install MySQL/MariaDB

Make sure you have MySQL or MariaDB installed on your system.

### 2. Create Database

```sql
CREATE DATABASE minicloud;
-- or for development
CREATE DATABASE minicloud_dev;
```

### 3. Run Schema

Choose one of the following:

**For Simple Setup (Recommended for current application):**
```bash
mysql -u root -p minicloud < minicloud_simple.sql
```

**For Production Setup (Advanced features):**
```bash
mysql -u root -p minicloud < minicloud_production.sql
```

### 4. Create Database User (Production)

```sql
-- Create application user
CREATE USER 'minicloud_app'@'%' IDENTIFIED BY 'your_secure_password';
GRANT SELECT, INSERT, UPDATE, DELETE ON minicloud.* TO 'minicloud_app'@'%';

-- Create monitoring user (optional)
CREATE USER 'minicloud_monitor'@'%' IDENTIFIED BY 'strong_monitor_password';
GRANT SELECT ON minicloud.* TO 'minicloud_monitor'@'%';

FLUSH PRIVILEGES;
```

### 5. Configure Application

Copy the appropriate configuration file to your application:

**For Development:**
```bash
cp application-dev.properties ../src/main/resources/application-dev.properties
```

**For Production:**
```bash
cp application-prod.properties ../src/main/resources/application-prod.properties
```

## Schema Details

### Simple Schema (`minicloud_simple.sql`)

Contains only the essential tables matching your current entities:

- `users` - User accounts
- `file_record` - File metadata

### Production Schema (`minicloud_production.sql`)

Includes additional features for production use:

- **Core Tables**: `users`, `file_records`
- **Audit Tables**: `audit_logs`, `session_tokens`
- **Advanced Features**: `file_shares`, `storage_quotas`
- **Views**: `user_file_summary`, `file_storage_usage`
- **Stored Procedures**: Storage quota management, cleanup procedures
- **Triggers**: Automatic audit logging, storage quota creation

## Configuration Files

### Development Configuration (`application-dev.properties`)

- Uses `create-drop` for easy testing
- Shows SQL queries for debugging
- Local file system for uploads
- Debug logging enabled

### Production Configuration (`application-prod.properties`)

- Uses `validate` for schema validation
- Optimized connection pooling
- Secure file upload directory
- Production logging levels
- SSL/TLS enabled

## Security Considerations

### Production Security Checklist

- [ ] Change all default passwords
- [ ] Use environment variables for sensitive data
- [ ] Enable SSL/TLS for database connections
- [ ] Configure proper firewall rules
- [ ] Use strong JWT secrets (at least 256 bits)
- [ ] Regularly rotate credentials
- [ ] Set up database backups
- [ ] Monitor database access logs

### Environment Variables

For production, use environment variables instead of hardcoded values:

```bash
export DB_PASSWORD="your_secure_password"
export JWT_SECRET="your_jwt_secret_key"
export DB_URL="jdbc:mysql://your-db-host:3306/minicloud"
```

Then update your `application-prod.properties`:

```properties
spring.datasource.password=${DB_PASSWORD}
jwt.secret=${JWT_SECRET}
spring.datasource.url=${DB_URL}
```

## Maintenance

### Regular Maintenance Tasks

1. **Clean up expired sessions** (if using production schema):
   ```sql
   CALL CleanupExpiredSessions();
   ```

2. **Clean up expired file shares** (if using production schema):
   ```sql
   CALL CleanupExpiredShares();
   ```

3. **Monitor storage usage**:
   ```sql
   SELECT * FROM file_storage_usage WHERE usage_percentage > 80;
   ```

4. **Archive old audit logs** (if using production schema):
   ```sql
   DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
   ```

### Backup Strategy

1. **Daily full backups**
2. **Keep backups for at least 30 days**
3. **Test backup restoration regularly**
4. **Store backups in secure, off-site location**

## Troubleshooting

### Common Issues

1. **Connection refused**: Check if MySQL is running
2. **Access denied**: Verify user permissions
3. **Schema validation errors**: Ensure database schema matches entities
4. **File upload errors**: Check upload directory permissions

### Useful Queries

```sql
-- Check user count
SELECT COUNT(*) FROM users;

-- Check file count
SELECT COUNT(*) FROM file_record;

-- Check storage usage
SELECT u.email, COUNT(f.id) as file_count 
FROM users u 
LEFT JOIN file_record f ON u.id = f.user_id 
GROUP BY u.id, u.email;
```

## Support

For database-related issues:

1. Check MySQL error logs
2. Verify connection settings
3. Ensure proper permissions
4. Test with simple queries first

## Version History

- **v1.0** - Initial schema with basic tables
- **v1.1** - Added production schema with advanced features
- **v1.2** - Added configuration files and documentation 