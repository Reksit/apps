package com.stjoseph.assessmentsystem.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.stjoseph.assessmentsystem.model.Event;
import com.stjoseph.assessmentsystem.repository.EventRepository;

@Service
public class EventCleanupService {
    
    @Autowired
    private EventRepository eventRepository;
    
    // Run every hour to check for expired events
    @Scheduled(fixedRate = 3600000) // 1 hour in milliseconds
    public void cleanupExpiredEvents() {
        try {
            System.out.println("Running event cleanup task...");
            
            LocalDateTime now = LocalDateTime.now();
            
            // Get all events that have ended (expired events)
            List<Event> expiredEvents = eventRepository.findExpiredEvents(now);
            
            if (!expiredEvents.isEmpty()) {
                System.out.println("Found " + expiredEvents.size() + " expired events to clean up");
                
                for (Event event : expiredEvents) {
                    System.out.println("Deleting expired event: " + event.getTitle() + " (ended at: " + event.getEndDateTime() + ")");
                }
                
                // Delete all expired events
                eventRepository.deleteAll(expiredEvents);
                System.out.println("Successfully cleaned up " + expiredEvents.size() + " expired events");
            } else {
                System.out.println("No expired events found");
            }
        } catch (Exception e) {
            System.err.println("Error during event cleanup: " + e.getMessage());
        }
    }
}
