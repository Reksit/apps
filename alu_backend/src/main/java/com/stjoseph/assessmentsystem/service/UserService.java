package com.stjoseph.assessmentsystem.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.stjoseph.assessmentsystem.model.User;
import com.stjoseph.assessmentsystem.repository.UserRepository;
import com.stjoseph.assessmentsystem.security.JwtUtils;

@Service
public class UserService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private AlumniProfileService alumniProfileService;
    
    @Autowired
    private JwtUtils jwtUtils;
    
    public List<User> searchUsers(String query, String type) {
        List<User> users;
        
        if (query.contains("@")) {
            users = userRepository.findByEmailContainingIgnoreCase(query);
        } else {
            users = userRepository.findByPhoneNumber(query);
        }
        
        // Filter by type if specified
        if (type != null && !type.isEmpty()) {
            User.UserRole role = User.UserRole.valueOf(type.toUpperCase());
            users = users.stream()
                    .filter(user -> user.getRole() == role)
                    .collect(Collectors.toList());
        }
        
        // Remove sensitive information
        return users.stream()
                .peek(user -> user.setPassword(null))
                .collect(java.util.stream.Collectors.toList());
    }
    
    public List<?> getApprovedAlumniForDirectory() {
        return alumniProfileService.getAllVerifiedAlumniWithProfiles();
    }
    
    public String getUserIdFromToken(String token) {
        // Remove "Bearer " prefix if present
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        
        String email = jwtUtils.getUserNameFromJwtToken(token);
        java.util.Optional<User> userOpt = userRepository.findByEmail(email);
        if (userOpt.isPresent()) {
            return userOpt.get().getId();
        }
        throw new RuntimeException("User not found for token");
    }
}