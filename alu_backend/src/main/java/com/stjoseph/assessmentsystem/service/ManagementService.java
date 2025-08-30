package com.stjoseph.assessmentsystem.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.stjoseph.assessmentsystem.model.Alumni;
import com.stjoseph.assessmentsystem.model.Event;
import com.stjoseph.assessmentsystem.model.User;
import com.stjoseph.assessmentsystem.repository.AlumniRepository;
import com.stjoseph.assessmentsystem.repository.UserRepository;

@Service
public class ManagementService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private AlumniRepository alumniRepository;
    
    @Autowired
    private EmailService emailService;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private ActivityService activityService;
    
    @Autowired
    private AlumniEventService alumniEventService;
    
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        
        try {
            // Get total counts
            long totalStudents = userRepository.countByRole(User.UserRole.STUDENT);
            long totalProfessors = userRepository.countByRole(User.UserRole.PROFESSOR);
            long totalAlumni = userRepository.countByRole(User.UserRole.ALUMNI);
            long pendingAlumni = alumniRepository.countByStatus(Alumni.AlumniStatus.PENDING);
            
            stats.put("totalStudents", totalStudents);
            stats.put("totalProfessors", totalProfessors);
            stats.put("totalAlumni", totalAlumni);
            stats.put("pendingAlumni", pendingAlumni);
            stats.put("totalAssessments", 0); // Placeholder for now
            
            System.out.println("Dashboard stats: " + stats);
        } catch (Exception e) {
            System.err.println("Error getting dashboard stats: " + e.getMessage());
            // Return default values if there's an error
            stats.put("totalStudents", 0);
            stats.put("totalProfessors", 0);
            stats.put("totalAlumni", 0);
            stats.put("pendingAlumni", 0);
            stats.put("totalAssessments", 0);
        }
        
        return stats;
    }
    
    public Map<String, Object> getStudentHeatmap(String studentId) {
        // Get student activity data for heatmap
        // This would be implemented based on your requirements
        Map<String, Object> heatmapData = activityService.getHeatmapData(studentId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("studentId", studentId);
        result.put("heatmapData", heatmapData);
        
        return result;
    }
    
    public List<Alumni> getAlumniApplications() {
        return alumniRepository.findByStatus(Alumni.AlumniStatus.PENDING);
    }
    
    public List<Alumni> getApprovedAlumni() {
        return alumniRepository.findByStatus(Alumni.AlumniStatus.APPROVED);
    }
    
    public String updateAlumniStatus(String alumniId, boolean approved) {
        Optional<Alumni> alumniOpt = alumniRepository.findById(alumniId);
        if (alumniOpt.isPresent()) {
            Alumni alumni = alumniOpt.get();
            alumni.setStatus(approved ? Alumni.AlumniStatus.APPROVED : Alumni.AlumniStatus.REJECTED);
            alumni.setVerifiedAt(java.time.LocalDateTime.now());
            alumniRepository.save(alumni);
            
            // Send email notification
            try {
                if (approved) {
                    String temporaryPassword = generateRandomPassword();
                    // Set password directly in Alumni model
                    alumni.setPassword(passwordEncoder.encode(temporaryPassword));
                    alumni.setVerified(true);
                    alumni.setCreatedAt(java.time.LocalDateTime.now());
                    alumniRepository.save(alumni);
                    sendApprovalEmailWithCredentials(alumni, temporaryPassword);
                } else {
                    emailService.sendAlumniApprovalNotification(alumni.getEmail(), false);
                }
            } catch (Exception e) {
                System.out.println("Email notification failed: " + e.getMessage());
            }
            
            return approved ? "Alumni approved successfully" : "Alumni rejected successfully";
        }
        throw new RuntimeException("Alumni not found");
    }
    
    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random random = new Random();
        StringBuilder password = new StringBuilder();
        for (int i = 0; i < 8; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }
        return password.toString();
    }
    
    private void sendApprovalEmailWithCredentials(Alumni alumni, String password) {
        String subject = "Alumni Registration Approved - Login Credentials";
        String message = String.format(
            "Dear %s,\n\n" +
            "Congratulations! Your alumni registration has been approved by the management.\n\n" +
            "You can now log in to the St. Joseph Assessment System using the following credentials:\n\n" +
            "Email: %s\n" +
            "Temporary Password: %s\n\n" +
            "IMPORTANT: Please log in and change your password immediately for security reasons.\n\n" +
            "Login URL: [Your System URL]\n\n" +
            "Welcome to the alumni network!\n\n" +
            "Best regards,\n" +
            "St. Joseph Assessment System Management",
            alumni.getName(),
            alumni.getEmail(),
            password
        );
        
        emailService.sendSimpleMessage(alumni.getEmail(), subject, message);
    }
    
    public List<User> searchStudents(String email) {
        return userRepository.findByEmailContainingIgnoreCase(email)
                .stream()
                .filter(user -> user.getRole() == User.UserRole.STUDENT)
                .collect(Collectors.toList());
    }
    
    public String cleanupDuplicateUsers() {
        List<User> allUsers = userRepository.findAll();
        
        // Group users by email
        Map<String, List<User>> usersByEmail = allUsers.stream()
                .collect(Collectors.groupingBy(User::getEmail));
        
        int deletedCount = 0;
        for (Map.Entry<String, List<User>> entry : usersByEmail.entrySet()) {
            List<User> duplicates = entry.getValue();
            if (duplicates.size() > 1) {
                // Keep the first user, delete the rest
                for (int i = 1; i < duplicates.size(); i++) {
                    userRepository.delete(duplicates.get(i));
                    deletedCount++;
                }
            }
        }
        
        return "Deleted " + deletedCount + " duplicate users";
    }
    
    // Event Management methods
    public List<Object> getAllEventRequests() {
        return new ArrayList<>(); // Placeholder
    }
    
    public List<Event> getAllAlumniEventRequests() {
        return alumniEventService.getAllAlumniEventRequests();
    }
    
    public Object approveAlumniEventRequest(String requestId, String managementId) {
        return alumniEventService.approveAlumniEventRequest(requestId, managementId);
    }
    
    public Object rejectAlumniEventRequest(String requestId, String managementId, String reason) {
        return alumniEventService.rejectAlumniEventRequest(requestId, managementId, reason);
    }
    
    public List<Map<String, Object>> getAvailableAlumni() {
        try {
            // Get from both Alumni collection and User collection
            List<Alumni> verifiedAlumniFromAlumni = alumniRepository.findByStatus(Alumni.AlumniStatus.APPROVED);
            List<User> verifiedAlumniFromUsers = userRepository.findByRoleAndApproved(User.UserRole.ALUMNI, true);
            
            List<Map<String, Object>> result = new ArrayList<>();
            java.util.Set<String> addedEmails = new java.util.HashSet<>();
            
            // Add from Alumni collection
            verifiedAlumniFromAlumni.forEach(alumni -> {
                if (!addedEmails.contains(alumni.getEmail())) {
                    addedEmails.add(alumni.getEmail());
                    Map<String, Object> alumniData = new HashMap<>();
                    alumniData.put("id", alumni.getId());
                    alumniData.put("name", alumni.getName());
                    alumniData.put("email", alumni.getEmail());
                    alumniData.put("department", alumni.getDepartment());
                    alumniData.put("graduationYear", alumni.getGraduationYear());
                    alumniData.put("currentCompany", alumni.getPlacedCompany());
                    result.add(alumniData);
                }
            });
            
            // Add from User collection
            verifiedAlumniFromUsers.forEach(user -> {
                if (!addedEmails.contains(user.getEmail())) {
                    addedEmails.add(user.getEmail());
                    Map<String, Object> alumniData = new HashMap<>();
                    alumniData.put("id", user.getId());
                    alumniData.put("name", user.getName());
                    alumniData.put("email", user.getEmail());
                    alumniData.put("department", user.getDepartment());
                    alumniData.put("graduationYear", user.getGraduationYear() != null ? user.getGraduationYear().toString() : "Unknown");
                    alumniData.put("currentCompany", user.getCurrentCompany());
                    result.add(alumniData);
                }
            });
            
            System.out.println("ManagementService: Found " + result.size() + " available alumni");
            return result;
        } catch (Exception e) {
            System.err.println("Error getting available alumni: " + e.getMessage());
            return new ArrayList<>();
        }
    }
    

    
    public Object requestEventFromAlumni(String managementId, String alumniId, Map<String, Object> requestData) {
        return alumniEventService.requestEventFromAlumni(managementId, alumniId, requestData);
    }
    
    public List<Event> getAllManagementEventRequests() {
        return alumniEventService.getAllManagementEventRequests();
    }
}
