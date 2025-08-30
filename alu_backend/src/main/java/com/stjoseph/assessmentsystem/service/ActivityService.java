package com.stjoseph.assessmentsystem.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.stjoseph.assessmentsystem.model.Activity;
import com.stjoseph.assessmentsystem.model.User;
import com.stjoseph.assessmentsystem.repository.ActivityRepository;
import com.stjoseph.assessmentsystem.repository.UserRepository;

@Service
public class ActivityService {
    
    @Autowired
    private ActivityRepository activityRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    public void logActivity(String userEmail, String type, String description) {
        try {
            // Find user by email to get user ID
            User user = userRepository.findByEmail(userEmail)
                    .orElseThrow(() -> new RuntimeException("User not found with email: " + userEmail));
            
            Activity activity = new Activity();
            activity.setUserId(user.getId());
            
            try {
                activity.setType(Activity.ActivityType.valueOf(type.toUpperCase()));
            } catch (IllegalArgumentException e) {
                // If the activity type is not found, log it but don't fail
                System.err.println("Unknown activity type: " + type + ". Available types: " + 
                    java.util.Arrays.toString(Activity.ActivityType.values()));
                return;
            }
            
            activity.setDescription(description);
            
            activityRepository.save(activity);
            System.out.println("Activity logged successfully: " + type + " for user: " + userEmail);
        } catch (Exception e) {
            System.err.println("Error logging activity for user " + userEmail + ": " + e.getMessage());
            // Don't throw exception to avoid affecting main functionality
        }
    }
    
    public List<Activity> getUserActivities(String userId, String startDate, String endDate) {
        if (startDate != null && endDate != null) {
            LocalDate start = LocalDate.parse(startDate);
            LocalDate end = LocalDate.parse(endDate);
            return activityRepository.findByUserIdAndDateBetween(userId, start, end);
        } else {
            return activityRepository.findByUserId(userId);
        }
    }
    
    public Map<String, Object> getHeatmapData(String userId) {
        List<Activity> activities = activityRepository.findByUserId(userId);
        
        Map<String, Map<String, Integer>> heatmapData = new HashMap<>();
        
        activities.forEach(activity -> {
            String dateStr = activity.getDate().format(DateTimeFormatter.ISO_LOCAL_DATE);
            String activityType = activity.getType().name();
            
            heatmapData.computeIfAbsent(dateStr, k -> new HashMap<>())
                      .merge(activityType, 1, Integer::sum);
        });
        
        // Calculate total activities per date for intensity
        Map<String, Integer> dailyTotals = heatmapData.entrySet().stream()
                .collect(Collectors.toMap(
                    Map.Entry::getKey,
                    entry -> entry.getValue().values().stream().mapToInt(Integer::intValue).sum()
                ));
        
        Map<String, Object> result = new HashMap<>();
        result.put("heatmap", heatmapData);
        result.put("dailyTotals", dailyTotals);
        
        return result;
    }
}