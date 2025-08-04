package com.EkAnek.MiniCloud.controller;

import com.EkAnek.MiniCloud.dto.LoginRequest;
import com.EkAnek.MiniCloud.dto.RegisterRequest;
import com.EkAnek.MiniCloud.dto.AuthResponse;
import com.EkAnek.MiniCloud.entity.User;
import com.EkAnek.MiniCloud.repository.UserRepository;
import com.EkAnek.MiniCloud.service.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Validated
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    /**
     * Register a new user
     * @param request Registration request containing email and password
     * @return JWT token and user info on successful registration
     */
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            // Check if user already exists
            if (userRepository.findByEmail(request.getEmail()).isPresent()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "User with this email already exists");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
            }

            // Validate email format
            if (!isValidEmail(request.getEmail())) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Invalid email format");
                return ResponseEntity.badRequest().body(error);
            }

            // Validate password strength
            if (!isValidPassword(request.getPassword())) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number");
                return ResponseEntity.badRequest().body(error);
            }

            // Create new user
            User user = new User();
            user.setEmail(request.getEmail());
            user.setPassword(passwordEncoder.encode(request.getPassword()));
            user.setCreatedAt(LocalDateTime.now());
            user.setEnabled(true);
            
            User savedUser = userRepository.save(user);

            // Generate JWT token
            String token = jwtService.generateToken(savedUser.getEmail());
            
            AuthResponse response = AuthResponse.builder()
                    .token(token)
                    .email(savedUser.getEmail())
                    .userId(savedUser.getId())
                    .message("User registered successfully")
                    .build();

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Registration failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Authenticate user and return JWT token
     * @param request Login request containing email and password
     * @return JWT token and user info on successful authentication
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            // Authenticate user
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            if (authentication.isAuthenticated()) {
                // Find user details
                User user = userRepository.findByEmail(request.getEmail())
                    .orElseThrow(() -> new UsernameNotFoundException("User not found"));

                if (!user.isEnabled()) {
                    Map<String, String> error = new HashMap<>();
                    error.put("error", "Account is disabled");
                    return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
                }

                // Generate JWT token
                String token = jwtService.generateToken(user.getEmail());
                
                AuthResponse response = AuthResponse.builder()
                        .token(token)
                        .email(user.getEmail())
                        .userId(user.getId())
                        .message("Login successful")
                        .build();

                return ResponseEntity.ok(response);
            } else {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Invalid credentials");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }

        } catch (UsernameNotFoundException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "User not found");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Authentication failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }

    /**
     * Validate JWT token
     * @param token JWT token to validate
     * @return Token validation status
     */
    @PostMapping("/validate")
    public ResponseEntity<?> validateToken(@RequestHeader("Authorization") String token) {
        try {
            if (token == null || !token.startsWith("Bearer ")) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Invalid token format");
                return ResponseEntity.badRequest().body(error);
            }

            String jwtToken = token.substring(7);
            String email = jwtService.extractUsername(jwtToken);
            
            if (email != null && jwtService.isTokenValid(jwtToken)) {
                User user = userRepository.findByEmail(email)
                    .orElseThrow(() -> new UsernameNotFoundException("User not found"));

                Map<String, Object> response = new HashMap<>();
                response.put("valid", true);
                response.put("email", user.getEmail());
                response.put("userId", user.getId());
                return ResponseEntity.ok(response);
            } else {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Invalid token");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Token validation failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }

    /**
     * Refresh JWT token
     * @param token Current JWT token
     * @return New JWT token
     */
    @PostMapping("/refresh")
    public ResponseEntity<?> refreshToken(@RequestHeader("Authorization") String token) {
        try {
            if (token == null || !token.startsWith("Bearer ")) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Invalid token format");
                return ResponseEntity.badRequest().body(error);
            }

            String jwtToken = token.substring(7);
            String email = jwtService.extractUsername(jwtToken);
            
            if (email != null && jwtService.isTokenValid(jwtToken)) {
                String newToken = jwtService.generateToken(email);
                
                AuthResponse response = AuthResponse.builder()
                        .token(newToken)
                        .email(email)
                        .message("Token refreshed successfully")
                        .build();

                return ResponseEntity.ok(response);
            } else {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Invalid token");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Token refresh failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }

    /**
     * Logout user (client-side token invalidation)
     * @return Logout confirmation
     */
    @PostMapping("/logout")
    public ResponseEntity<?> logout() {
        Map<String, String> response = new HashMap<>();
        response.put("message", "Logout successful");
        return ResponseEntity.ok(response);
    }

    /**
     * Health check endpoint
     * @return Service status
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "Authentication Service");
        response.put("timestamp", LocalDateTime.now().toString());
        return ResponseEntity.ok(response);
    }

    // Helper methods for validation
    private boolean isValidEmail(String email) {
        return email != null && email.matches("^[A-Za-z0-9+_.-]+@(.+)$");
    }

    private boolean isValidPassword(String password) {
        return password != null && 
               password.length() >= 8 && 
               password.matches(".*[A-Z].*") && 
               password.matches(".*[a-z].*") && 
               password.matches(".*\\d.*");
    }
}
