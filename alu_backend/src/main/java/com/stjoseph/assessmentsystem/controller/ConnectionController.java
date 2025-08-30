package com.stjoseph.assessmentsystem.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.stjoseph.assessmentsystem.model.Connection;
import com.stjoseph.assessmentsystem.service.ConnectionService;

@RestController
@RequestMapping("/connections")
@CrossOrigin(origins = "*")
public class ConnectionController {
    
    @Autowired
    private ConnectionService connectionService;
    
    @PostMapping("/send-request")
    public ResponseEntity<?> sendConnectionRequest(@RequestBody Map<String, String> request, 
                                                  Authentication authentication) {
        try {
            String senderId = getUserIdFromAuth(authentication);
            String recipientId = request.get("recipientId");
            String message = request.get("message");
            
            Connection connection = connectionService.sendConnectionRequest(senderId, recipientId, message);
            return ResponseEntity.ok(Map.of(
                "message", "Connection request sent successfully",
                "connectionId", connection.getId()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/{connectionId}/accept")
    public ResponseEntity<?> acceptConnectionRequest(@PathVariable String connectionId,
                                                   Authentication authentication) {
        try {
            String userId = getUserIdFromAuth(authentication);
            Connection connection = connectionService.acceptConnectionRequest(connectionId, userId);
            return ResponseEntity.ok(Map.of(
                "message", "Connection request accepted",
                "connection", connection
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PostMapping("/{connectionId}/reject")
    public ResponseEntity<?> rejectConnectionRequest(@PathVariable String connectionId,
                                                   Authentication authentication) {
        try {
            String userId = getUserIdFromAuth(authentication);
            Connection connection = connectionService.rejectConnectionRequest(connectionId, userId);
            return ResponseEntity.ok(Map.of(
                "message", "Connection request rejected",
                "connection", connection
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/pending")
    public ResponseEntity<?> getPendingRequests(Authentication authentication) {
        try {
            String userId = getUserIdFromAuth(authentication);
            List<Connection> pending = connectionService.getPendingConnectionRequests(userId);
            return ResponseEntity.ok(pending);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/accepted")
    public ResponseEntity<?> getAcceptedConnections(Authentication authentication) {
        try {
            String userId = getUserIdFromAuth(authentication);
            List<Connection> connections = connectionService.getAcceptedConnections(userId);
            return ResponseEntity.ok(connections);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/status/{otherUserId}")
    public ResponseEntity<?> getConnectionStatus(@PathVariable String otherUserId,
                                                Authentication authentication) {
        try {
            String userId = getUserIdFromAuth(authentication);
            String status = connectionService.getConnectionStatus(userId, otherUserId);
            return ResponseEntity.ok(Map.of("status", status));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @GetMapping("/count")
    public ResponseEntity<?> getConnectionCount(Authentication authentication) {
        try {
            String userId = getUserIdFromAuth(authentication);
            long count = connectionService.getConnectionCount(userId);
            return ResponseEntity.ok(Map.of("count", count));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    private String getUserIdFromAuth(Authentication authentication) {
        return ((com.stjoseph.assessmentsystem.security.UserDetailsImpl) authentication.getPrincipal()).getId();
    }
}
