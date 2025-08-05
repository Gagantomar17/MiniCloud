# MiniCloud Authentication API

A Spring Boot application providing JWT-based authentication and file management services.

## Features

- 🔐 JWT-based authentication
- 👤 User registration and login
- 🔄 Token refresh functionality
- 📁 File upload and management
- 🛡️ Spring Security integration
- 🗄️ MySQL database integration

## Tech Stack

- **Backend**: Spring Boot 3.5.4, Java 22
- **Security**: Spring Security, JWT
- **Database**: MySQL
- **Build Tool**: Gradle
- **Dependencies**: Lombok, JPA, Validation

## API Endpoints

### Authentication Endpoints

#### 1. Register User
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "user@example.com",
  "userId": 1,
  "message": "User registered successfully"
}
```

#### 2. Login User
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "user@example.com",
  "userId": 1,
  "message": "Login successful"
}
```

#### 3. Validate Token
```http
POST /api/v1/auth/validate
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "valid": true,
  "email": "user@example.com",
  "userId": 1
}
```

#### 4. Refresh Token
```http
POST /api/v1/auth/refresh
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "user@example.com",
  "message": "Token refreshed successfully"
}
```

#### 5. Logout
```http
POST /api/v1/auth/logout
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "message": "Logout successful"
}
```

#### 6. Health Check
```http
GET /api/v1/auth/health
```

**Response:**
```json
{
  "status": "UP",
  "service": "Authentication Service",
  "timestamp": "2024-01-15T10:30:00"
}
```

## Setup Instructions

### Prerequisites
- Java 22
- MySQL 8.0+
- Gradle 8.0+

### Database Setup
1. Create a MySQL database named `minicloud`
2. Update database credentials in `application.properties`

### Running the Application

1. **Clone the repository**
```bash
git clone <repository-url>
cd MiniCloud
```
2. **Update MySQL password and username in application.properties**
#(Edit the file manually)

3. **Set up database**
```bash
./setup-database.bat
```

4. **Build the project**
```bash
./gradlew build
```

5. **Run the application**
```bash
./gradlew bootRun
```

The application will start on `http://localhost:8080`

### Configuration

Key configuration properties in `application.properties`:

```properties
# Database
spring.datasource.url=jdbc:mysql://localhost:3306/minicloud
spring.datasource.username=root
spring.datasource.password=your_password

# JWT
jwt.secret=your_jwt_secret_key
jwt.expiration=86400000
jwt.refresh-token.expiration=604800000

# File Upload
spring.servlet.multipart.max-file-size=1024MB
spring.servlet.multipart.max-request-size=1024MB
file.upload-dir=files
```

## Security Features

- **Password Validation**: Minimum 8 characters with uppercase, lowercase, and number
- **Email Validation**: Basic email format validation
- **JWT Token**: Secure token-based authentication
- **BCrypt Password Encoding**: Secure password hashing
- **CORS Support**: Cross-origin resource sharing enabled

## Error Handling

The API returns consistent error responses:

```json
{
  "error": "Error message description"
}
```

Common HTTP status codes:
- `200`: Success
- `201`: Created (registration)
- `400`: Bad Request (validation errors)
- `401`: Unauthorized (invalid credentials)
- `403`: Forbidden (disabled account)
- `404`: Not Found (user not found)
- `409`: Conflict (user already exists)
- `500`: Internal Server Error

## Testing

### Using cURL

**Register a new user:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Password123"}'
```

**Login:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Password123"}'
```

**Validate token:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/validate \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Project Structure

```
src/main/java/com/EkAnek/MiniCloud/
├── controller/
│   └── AuthController.java
├── service/
│   ├── JwtService.java
│   └── CustomUserDetailsService.java
├── config/
│   ├── SecurityConfig.java
│   └── JwtAuthenticationFilter.java
├── dto/
│   ├── LoginRequest.java
│   ├── RegisterRequest.java
│   └── AuthResponse.java
├── entity/
│   └── User.java
├── repository/
│   └── UserRepository.java
└── MiniCloudApplication.java
```