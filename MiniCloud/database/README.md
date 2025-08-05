# MiniCloud Database Setup

This directory contains the database schema and configuration files for the MiniCloud application.

## Files Overview

- `minicloud.sql` - Database schema matching the current entity structure
- `README.md` - This file

## Quick Setup

### 1. Install MySQL/MariaDB

Make sure you have MySQL or MariaDB installed on your system.

### 2. Create Database

```sql
CREATE DATABASE minicloud;
```

### 3. Run Schema

```bash
mysql -u root -p minicloud < minicloud.sql

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

Update the main application.properties file with your database credentials:

```bash
# Edit src/main/resources/application.properties
# Update the password field with your MySQL password
```

## Schema Details

### Database Schema (`minicloud.sql`)

Contains only the essential tables matching your current entities:

- `users` - User accounts
- `file_record` - File metadata



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

1. **Monitor storage usage**:
   ```sql
   SELECT COUNT(*) as file_count FROM file_record;
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
- **v1.1** - Simplified to use only simple schema
- **v1.2** - Added configuration files and documentation 