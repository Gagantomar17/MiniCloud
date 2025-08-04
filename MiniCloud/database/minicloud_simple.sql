-- =====================================================
-- MiniCloud Simple Database Schema
-- Version: 1.0
-- Created: 2024
-- Description: Simple database schema matching the entity structure
-- =====================================================

-- Create database (uncomment if needed)
-- CREATE DATABASE minicloud;
-- USE minicloud;

-- =====================================================
-- USERS TABLE (matches User entity)
-- =====================================================
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    enabled BOOLEAN DEFAULT TRUE,
    
    -- Indexes for performance
    INDEX idx_users_email (email),
    INDEX idx_users_enabled (enabled)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FILE_RECORDS TABLE (matches FileRecord entity)
-- =====================================================
CREATE TABLE file_record (
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
    INDEX idx_file_record_user_id (user_id),
    INDEX idx_file_record_tiny_url (tiny_url),
    INDEX idx_file_record_uploaded_at (uploaded_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INITIAL DATA (Optional - for testing)
-- =====================================================

-- Insert a default admin user (password: Admin123!)
-- WARNING: Change this password in production!
-- INSERT INTO users (email, password, created_at, enabled) VALUES 
-- ('admin@minicloud.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', CURRENT_TIMESTAMP, TRUE);

-- =====================================================
-- END OF SCHEMA
-- ===================================================== 