-- =====================================================
-- MiniCloud Production Database Schema
-- Version: 1.0
-- Created: 2024
-- Description: Production-ready database schema for MiniCloud file storage application
-- =====================================================

-- Create database (uncomment if needed)
-- CREATE DATABASE minicloud_production;
-- USE minicloud_production;

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    enabled BOOLEAN DEFAULT TRUE,
    
    -- Indexes for performance
    INDEX idx_users_email (email),
    INDEX idx_users_enabled (enabled),
    INDEX idx_users_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FILE_RECORDS TABLE
-- =====================================================
CREATE TABLE file_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    file_name VARCHAR(500) NOT NULL,
    file_type VARCHAR(100),
    compressed BOOLEAN DEFAULT FALSE,
    tiny_url VARCHAR(50) UNIQUE,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes for performance
    INDEX idx_file_records_user_id (user_id),
    INDEX idx_file_records_tiny_url (tiny_url),
    INDEX idx_file_records_uploaded_at (uploaded_at),
    INDEX idx_file_records_file_type (file_type),
    INDEX idx_file_records_compressed (compressed),
    
    -- Composite indexes for common queries
    INDEX idx_file_records_user_uploaded (user_id, uploaded_at),
    INDEX idx_file_records_user_type (user_id, file_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- AUDIT LOG TABLE (for production monitoring)
-- =====================================================
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50) NOT NULL,
    resource_id BIGINT,
    details JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign key constraint (nullable for anonymous actions)
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Indexes for performance
    INDEX idx_audit_logs_user_id (user_id),
    INDEX idx_audit_logs_action (action),
    INDEX idx_audit_logs_created_at (created_at),
    INDEX idx_audit_logs_resource (resource_type, resource_id),
    INDEX idx_audit_logs_ip_address (ip_address)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SESSION TOKENS TABLE (for JWT blacklisting)
-- =====================================================
CREATE TABLE session_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_revoked BOOLEAN DEFAULT FALSE,
    
    -- Foreign key constraint
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes for performance
    INDEX idx_session_tokens_user_id (user_id),
    INDEX idx_session_tokens_expires_at (expires_at),
    INDEX idx_session_tokens_revoked (is_revoked),
    INDEX idx_session_tokens_hash (token_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FILE SHARING TABLE (for advanced sharing features)
-- =====================================================
CREATE TABLE file_shares (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    file_record_id BIGINT NOT NULL,
    shared_by_user_id BIGINT NOT NULL,
    shared_with_email VARCHAR(255),
    access_level ENUM('READ', 'WRITE', 'ADMIN') DEFAULT 'READ',
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Foreign key constraints
    FOREIGN KEY (file_record_id) REFERENCES file_records(id) ON DELETE CASCADE,
    FOREIGN KEY (shared_by_user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes for performance
    INDEX idx_file_shares_file_id (file_record_id),
    INDEX idx_file_shares_shared_by (shared_by_user_id),
    INDEX idx_file_shares_shared_with (shared_with_email),
    INDEX idx_file_shares_expires_at (expires_at),
    INDEX idx_file_shares_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- STORAGE QUOTAS TABLE (for user storage limits)
-- =====================================================
CREATE TABLE storage_quotas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    total_quota_bytes BIGINT DEFAULT 1073741824, -- 1GB default
    used_bytes BIGINT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraint
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes for performance
    INDEX idx_storage_quotas_user_id (user_id),
    INDEX idx_storage_quotas_used_bytes (used_bytes)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- User file summary view
CREATE VIEW user_file_summary AS
SELECT 
    u.id as user_id,
    u.email,
    COUNT(fr.id) as total_files,
    SUM(CASE WHEN fr.compressed = TRUE THEN 1 ELSE 0 END) as compressed_files,
    SUM(CASE WHEN fr.tiny_url IS NOT NULL THEN 1 ELSE 0 END) as shared_files,
    MAX(fr.uploaded_at) as last_upload
FROM users u
LEFT JOIN file_records fr ON u.id = fr.user_id
WHERE u.enabled = TRUE
GROUP BY u.id, u.email;

-- File storage usage view
CREATE VIEW file_storage_usage AS
SELECT 
    u.id as user_id,
    u.email,
    sq.total_quota_bytes,
    sq.used_bytes,
    ROUND((sq.used_bytes / sq.total_quota_bytes) * 100, 2) as usage_percentage,
    sq.total_quota_bytes - sq.used_bytes as remaining_bytes
FROM users u
JOIN storage_quotas sq ON u.id = sq.user_id
WHERE u.enabled = TRUE;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

DELIMITER //

-- Procedure to update user storage quota
CREATE PROCEDURE UpdateUserStorageQuota(
    IN p_user_id BIGINT,
    IN p_file_size_bytes BIGINT
)
BEGIN
    DECLARE current_used BIGINT;
    DECLARE total_quota BIGINT;
    
    -- Get current usage and quota
    SELECT used_bytes, total_quota_bytes 
    INTO current_used, total_quota
    FROM storage_quotas 
    WHERE user_id = p_user_id;
    
    -- Check if adding file would exceed quota
    IF (current_used + p_file_size_bytes) > total_quota THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Storage quota exceeded';
    END IF;
    
    -- Update usage
    UPDATE storage_quotas 
    SET used_bytes = used_bytes + p_file_size_bytes,
        last_updated = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;
END //

-- Procedure to clean up expired sessions
CREATE PROCEDURE CleanupExpiredSessions()
BEGIN
    DELETE FROM session_tokens 
    WHERE expires_at < CURRENT_TIMESTAMP 
    OR is_revoked = TRUE;
END //

-- Procedure to clean up expired file shares
CREATE PROCEDURE CleanupExpiredShares()
BEGIN
    UPDATE file_shares 
    SET is_active = FALSE 
    WHERE expires_at < CURRENT_TIMESTAMP 
    AND is_active = TRUE;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS
-- =====================================================

DELIMITER //

-- Trigger to create storage quota when user is created
CREATE TRIGGER after_user_insert
AFTER INSERT ON users
FOR EACH ROW
BEGIN
    INSERT INTO storage_quotas (user_id, total_quota_bytes, used_bytes)
    VALUES (NEW.id, 1073741824, 0); -- 1GB default quota
END //

-- Trigger to audit file operations
CREATE TRIGGER after_file_record_insert
AFTER INSERT ON file_records
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (user_id, action, resource_type, resource_id, details)
    VALUES (NEW.user_id, 'FILE_UPLOAD', 'FILE_RECORD', NEW.id, 
            JSON_OBJECT('file_name', NEW.file_name, 'file_type', NEW.file_type, 'size', 0));
END //

CREATE TRIGGER after_file_record_delete
AFTER DELETE ON file_records
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (user_id, action, resource_type, resource_id, details)
    VALUES (OLD.user_id, 'FILE_DELETE', 'FILE_RECORD', OLD.id, 
            JSON_OBJECT('file_name', OLD.file_name, 'file_type', OLD.file_type));
END //

DELIMITER ;

-- =====================================================
-- INITIAL DATA (Optional - for testing)
-- =====================================================

-- Insert a default admin user (password: Admin123!)
-- WARNING: Change this password in production!
INSERT INTO users (email, password, created_at, enabled) VALUES 
('admin@minicloud.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', CURRENT_TIMESTAMP, TRUE);

-- =====================================================
-- SECURITY CONSIDERATIONS
-- =====================================================

-- Create a read-only user for application monitoring
-- CREATE USER 'minicloud_monitor'@'%' IDENTIFIED BY 'strong_monitor_password';
-- GRANT SELECT ON minicloud_production.* TO 'minicloud_monitor'@'%';

-- Create application user with limited privileges
-- CREATE USER 'minicloud_app'@'%' IDENTIFIED BY 'strong_app_password';
-- GRANT SELECT, INSERT, UPDATE, DELETE ON minicloud_production.* TO 'minicloud_app'@'%';

-- =====================================================
-- MAINTENANCE QUERIES
-- =====================================================

-- Query to find users with high storage usage (>80%)
-- SELECT u.email, sq.used_bytes, sq.total_quota_bytes, 
--        ROUND((sq.used_bytes / sq.total_quota_bytes) * 100, 2) as usage_percentage
-- FROM users u
-- JOIN storage_quotas sq ON u.id = sq.user_id
-- WHERE (sq.used_bytes / sq.total_quota_bytes) > 0.8;

-- Query to find inactive users (no uploads in last 30 days)
-- SELECT u.email, u.created_at, MAX(fr.uploaded_at) as last_upload
-- FROM users u
-- LEFT JOIN file_records fr ON u.id = fr.user_id
-- WHERE u.enabled = TRUE
-- GROUP BY u.id, u.email, u.created_at
-- HAVING last_upload IS NULL OR last_upload < DATE_SUB(NOW(), INTERVAL 30 DAY);

-- Query to clean up old audit logs (older than 1 year)
-- DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- =====================================================
-- BACKUP AND RECOVERY NOTES
-- =====================================================

/*
IMPORTANT PRODUCTION NOTES:

1. REGULAR BACKUPS:
   - Schedule daily full backups
   - Keep backups for at least 30 days
   - Test backup restoration regularly

2. MONITORING:
   - Monitor storage usage per user
   - Track file upload/download patterns
   - Monitor database performance

3. SECURITY:
   - Regularly rotate database passwords
   - Use SSL/TLS for database connections
   - Implement proper access controls

4. MAINTENANCE:
   - Run cleanup procedures regularly
   - Monitor and optimize indexes
   - Archive old audit logs

5. SCALING:
   - Consider partitioning for large tables
   - Implement read replicas for heavy read loads
   - Monitor connection pool usage
*/

-- =====================================================
-- END OF SCHEMA
-- ===================================================== 