# MiniCloud Frontend

A simple, minimalist frontend for the MiniCloud file management system built with HTML, CSS, and jQuery.

## Features

### 🔐 Authentication
- **User Registration**: Create new accounts with email and password
- **User Login**: Secure authentication with JWT tokens
- **Password Validation**: Enforces strong password requirements
- **Token Management**: Automatic token refresh and validation
- **Session Persistence**: Remembers login state across browser sessions

### 📁 File Management
- **File Upload**: Upload files with title and description
- **File List**: View all uploaded files with metadata
- **File Deletion**: Delete files with confirmation
- **File Metadata**: Display file size, upload date, and type

### 🎨 User Interface
- **Minimalist Design**: Clean, modern interface
- **Responsive Layout**: Works on desktop and mobile devices
- **Tab Navigation**: Easy switching between login and register
- **Real-time Feedback**: Success/error messages with animations
- **Loading States**: Visual feedback during operations

## File Structure

```
src/main/resources/static/
├── index.html          # Main HTML file
├── styles.css          # CSS styling
└── script.js           # JavaScript functionality
```

## API Endpoints Used

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/validate` - Token validation
- `POST /api/v1/auth/refresh` - Token refresh
- `POST /api/v1/auth/logout` - User logout

### File Management
- `POST /api/v1/files/upload` - Upload file
- `GET /api/v1/files/my-files` - Get user's files
- `DELETE /api/v1/files/{id}` - Delete file
- `POST /api/v1/files/{id}/share` - Share file

## How to Use

1. **Start the Backend**: Run the Spring Boot application
2. **Access Frontend**: Open `http://localhost:8080` in your browser
3. **Register/Login**: Create an account or login with existing credentials
4. **Upload Files**: Select files, add titles and descriptions
5. **Manage Files**: View, delete, or share your uploaded files

## Technical Details

### Dependencies
- **jQuery 3.6.0**: For AJAX calls and DOM manipulation
- **Modern CSS**: Flexbox, Grid, and animations
- **Local Storage**: For token persistence

### Security Features
- **JWT Token Authentication**: Secure API communication
- **Password Validation**: Client-side password strength checking
- **Token Auto-refresh**: Automatic token renewal every 5 minutes
- **Session Management**: Proper logout and token cleanup

### Browser Compatibility
- Modern browsers (Chrome, Firefox, Safari, Edge)
- Mobile responsive design
- Progressive enhancement approach

## Customization

### Styling
- Modify `styles.css` to change colors, fonts, and layout
- CSS variables can be added for easy theming
- Responsive breakpoints can be adjusted

### Functionality
- Add new features in `script.js`
- Extend API calls for additional functionality
- Implement file preview or download features

## Troubleshooting

### Common Issues
1. **CORS Errors**: Ensure backend has CORS configured
2. **File Upload Fails**: Check file size limits in backend
3. **Token Expired**: Frontend will automatically redirect to login
4. **Network Errors**: Check API endpoint URLs and server status

### Debug Mode
- Open browser developer tools to see AJAX requests
- Check console for JavaScript errors
- Monitor network tab for API responses

## Future Enhancements

- File preview functionality
- Drag and drop file upload
- File search and filtering
- Bulk file operations
- File sharing with public links
- User profile management 