// Global variables
let authToken = localStorage.getItem('authToken');
let currentUser = localStorage.getItem('currentUser');

// API Base URL
const API_BASE = '/api/v1';

// Initialize the application
$(document).ready(function() {
    checkAuthStatus();
    setupEventListeners();
});

// Check if user is already authenticated
function checkAuthStatus() {
    if (authToken) {
        validateToken();
    } else {
        showAuthSection();
    }
}

// Setup event listeners
function setupEventListeners() {
    // Login form
    $('#login-form').on('submit', function(e) {
        e.preventDefault();
        login();
    });

    // Register form
    $('#register-form').on('submit', function(e) {
        e.preventDefault();
        register();
    });

    // Upload form
    $('#upload-form').on('submit', function(e) {
        e.preventDefault();
        uploadFile();
    });
}

// Tab switching
function showTab(tabName) {
    $('.tab-btn').removeClass('active');
    $('.auth-tab').removeClass('active');
    
    $(`[onclick="showTab('${tabName}')"]`).addClass('active');
    $(`#${tabName}-tab`).addClass('active');
}

// Authentication functions
function login() {
    const email = $('#login-email').val();
    const password = $('#login-password').val();

    if (!email || !password) {
        showMessage('Please fill in all fields', 'error');
        return;
    }

    $.ajax({
        url: `${API_BASE}/auth/login`,
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ email, password }),
        success: function(response) {
            authToken = response.token;
            currentUser = response.email;
            
            localStorage.setItem('authToken', authToken);
            localStorage.setItem('currentUser', currentUser);
            
            showMessage('Login successful!', 'success');
            showFileSection();
            loadFiles();
        },
        error: function(xhr) {
            const error = xhr.responseJSON?.error || 'Login failed';
            showMessage(error, 'error');
        }
    });
}

function register() {
    const email = $('#register-email').val();
    const password = $('#register-password').val();

    if (!email || !password) {
        showMessage('Please fill in all fields', 'error');
        return;
    }

    // Basic password validation
    if (password.length < 8 || !/[A-Z]/.test(password) || !/[a-z]/.test(password) || !/\d/.test(password)) {
        showMessage('Password must be at least 8 characters with uppercase, lowercase, and number', 'error');
        return;
    }

    $.ajax({
        url: `${API_BASE}/auth/register`,
        method: 'POST',
        contentType: 'application/json',
        data: JSON.stringify({ email, password }),
        success: function(response) {
            authToken = response.token;
            currentUser = response.email;
            
            localStorage.setItem('authToken', authToken);
            localStorage.setItem('currentUser', currentUser);
            
            showMessage('Registration successful!', 'success');
            showFileSection();
            loadFiles();
        },
        error: function(xhr) {
            const error = xhr.responseJSON?.error || 'Registration failed';
            showMessage(error, 'error');
        }
    });
}

function validateToken() {
    $.ajax({
        url: `${API_BASE}/auth/validate`,
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${authToken}`
        },
        success: function(response) {
            if (response.valid) {
                showFileSection();
                loadFiles();
            } else {
                logout();
            }
        },
        error: function() {
            logout();
        }
    });
}

function logout() {
    $.ajax({
        url: `${API_BASE}/auth/logout`,
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${authToken}`
        },
        complete: function() {
            // Clear local storage and show auth section regardless of response
            localStorage.removeItem('authToken');
            localStorage.removeItem('currentUser');
            authToken = null;
            currentUser = null;
            showAuthSection();
        }
    });
}

// UI functions
function showAuthSection() {
    $('#auth-section').show();
    $('#file-section').hide();
    $('#user-email').text('');
}

function showFileSection() {
    $('#auth-section').hide();
    $('#file-section').show();
    $('#user-email').text(currentUser);
}

function showMessage(message, type = 'info') {
    const messageHtml = `<div class="message ${type}">${message}</div>`;
    $('#messages').append(messageHtml);
    
    setTimeout(function() {
        $('#messages .message').first().remove();
    }, 5000);
}

// File management functions
function uploadFile() {
    const fileInput = $('#file-input')[0];
    const title = $('#file-title').val();
    const desc = $('#file-desc').val();

    if (!fileInput.files[0] || !title) {
        showMessage('Please select a file and provide a title', 'error');
        return;
    }

    const formData = new FormData();
    formData.append('file', fileInput.files[0]);
    formData.append('title', title);
    formData.append('desc', desc);

    $.ajax({
        url: `${API_BASE}/files/upload`,
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${authToken}`
        },
        data: formData,
        processData: false,
        contentType: false,
        success: function(response) {
            showMessage('File uploaded successfully!', 'success');
            $('#upload-form')[0].reset();
            loadFiles();
        },
        error: function(xhr) {
            const error = xhr.responseJSON?.error || 'Upload failed';
            showMessage(error, 'error');
        }
    });
}

function loadFiles() {
    $('#files-list').html('<div class="loading">Loading files...</div>');

    $.ajax({
        url: `${API_BASE}/files/my-files`,
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${authToken}`
        },
        success: function(files) {
            displayFiles(files);
        },
        error: function(xhr) {
            const error = xhr.responseJSON?.error || 'Failed to load files';
            showMessage(error, 'error');
            $('#files-list').html('<p>Failed to load files</p>');
        }
    });
}

function displayFiles(files) {
    if (files.length === 0) {
        $('#files-list').html('<p>No files uploaded yet.</p>');
        return;
    }

    let filesHtml = '';
    files.forEach(function(file) {
        const fileSize = formatFileSize(file.fileSize);
        const uploadDate = new Date(file.uploadedAt).toLocaleDateString();
        
        // Check if file has a public URL
        const hasPublicUrl = file.tinyUrl;
        const publicUrl = hasPublicUrl ? `${window.location.origin}${API_BASE}/public/${file.tinyUrl}` : null;
        
        filesHtml += `
            <div class="file-item">
                <div class="file-info">
                    <div class="file-title">${file.title}</div>
                    <div class="file-desc">${file.description || 'No description'}</div>
                    <div class="file-meta">
                        Size: ${fileSize} | Uploaded: ${uploadDate}
                    </div>
                    ${hasPublicUrl ? `
                        <div class="public-url">
                            <strong>Public URL:</strong> 
                            <a href="${publicUrl}" target="_blank">${publicUrl}</a>
                            <button class="btn btn-small btn-secondary" onclick="copyToClipboard('${publicUrl}')">Copy</button>
                        </div>
                    ` : ''}
                </div>
                <div class="file-actions">
                    ${!hasPublicUrl ? `<button class="btn btn-primary" onclick="shareFile(${file.id})">Share</button>` : `<button class="btn btn-warning" onclick="revokeShare(${file.id})">Revoke Share</button>`}
                    <button class="btn btn-danger" onclick="deleteFile(${file.id})">Delete</button>
                </div>
            </div>
        `;
    });
    
    $('#files-list').html(filesHtml);
}

function deleteFile(fileId) {
    if (!confirm('Are you sure you want to delete this file?')) {
        return;
    }

    $.ajax({
        url: `${API_BASE}/files/${fileId}`,
        method: 'DELETE',
        headers: {
            'Authorization': `Bearer ${authToken}`
        },
        success: function() {
            showMessage('File deleted successfully!', 'success');
            loadFiles();
        },
        error: function(xhr) {
            const error = xhr.responseJSON?.error || 'Delete failed';
            showMessage(error, 'error');
        }
    });
}

function shareFile(fileId) {
    $.ajax({
        url: `${API_BASE}/files/${fileId}/share`,
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${authToken}`
        },
        success: function(response) {
            const publicUrl = `${window.location.origin}${response}`;
            showMessage('File shared successfully! Public URL generated.', 'success');
            loadFiles(); // Reload to show the new public URL
        },
        error: function(xhr) {
            const error = xhr.responseJSON?.error || 'Share failed';
            showMessage(error, 'error');
        }
    });
}

function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(function() {
        showMessage('URL copied to clipboard!', 'success');
    }).catch(function(err) {
        showMessage('Failed to copy URL', 'error');
        console.error('Could not copy text: ', err);
    });
}

function revokeShare(fileId) {
    if (!confirm('Are you sure you want to revoke sharing for this file? This will make the public URL invalid.')) {
        return;
    }

    $.ajax({
        url: `${API_BASE}/files/${fileId}/share`,
        method: 'DELETE',
        headers: {
            'Authorization': `Bearer ${authToken}`
        },
        success: function() {
            showMessage('File sharing revoked successfully!', 'success');
            loadFiles(); // Reload to update the UI
        },
        error: function(xhr) {
            const error = xhr.responseJSON?.error || 'Revoke failed';
            showMessage(error, 'error');
        }
    });
}

// Utility functions
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Auto-refresh token every 5 minutes
setInterval(function() {
    if (authToken) {
        $.ajax({
            url: `${API_BASE}/auth/refresh`,
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`
            },
            success: function(response) {
                authToken = response.token;
                localStorage.setItem('authToken', authToken);
            },
            error: function() {
                // Token refresh failed, user will need to login again
                logout();
            }
        });
    }
}, 5 * 60 * 1000); // 5 minutes 