package com.stjoseph.assessmentsystem.service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.stjoseph.assessmentsystem.model.Connection;
import com.stjoseph.assessmentsystem.model.User;
import com.stjoseph.assessmentsystem.repository.ConnectionRepository;
import com.stjoseph.assessmentsystem.repository.UserRepository;

@Service
public class ConnectionService {
    
    @Autowired
    private ConnectionRepository connectionRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private NotificationService notificationService;
    
    public Connection sendConnectionRequest(String senderId, String recipientId, String message) {
        // Check if connection already exists
        Optional<Connection> existingConnection = connectionRepository.findConnectionBetweenUsers(senderId, recipientId);
        if (existingConnection.isPresent()) {
            throw new RuntimeException("You are already following this alumni");
        }
        
        // Check if users exist
        Optional<User> sender = userRepository.findById(senderId);
        Optional<User> recipient = userRepository.findById(recipientId);
        
        if (sender.isEmpty() || recipient.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        
        // Create new connection with auto-accepted status (following system)
        Connection connection = new Connection(senderId, recipientId, message);
        connection.setStatus(Connection.ConnectionStatus.ACCEPTED); // Auto-accept for following system
        Connection savedConnection = connectionRepository.save(connection);
        
        // Send notification to alumni that they have a new follower
        try {
            String senderName = sender.get().getName();
            notificationService.createNewFollowerNotification(recipientId, senderId, senderName);
        } catch (Exception e) {
            System.err.println("Failed to send follower notification: " + e.getMessage());
        }
        
        return savedConnection;
    }
    
    public Connection acceptConnectionRequest(String connectionId, String userId) {
        Optional<Connection> connectionOpt = connectionRepository.findById(connectionId);
        if (connectionOpt.isEmpty()) {
            throw new RuntimeException("Connection request not found");
        }
        
        Connection connection = connectionOpt.get();
        
        // Verify user is the recipient
        if (!connection.getRecipientId().equals(userId)) {
            throw new RuntimeException("Unauthorized to accept this connection request");
        }
        
        // Update connection status
        connection.setStatus(Connection.ConnectionStatus.ACCEPTED);
        connection.setRespondedAt(LocalDateTime.now());
        
        Connection savedConnection = connectionRepository.save(connection);
        
        // Send notification to sender
        try {
            Optional<User> recipient = userRepository.findById(connection.getRecipientId());
            if (recipient.isPresent()) {
                String recipientName = recipient.get().getName();
                notificationService.createConnectionAcceptedNotification(
                    connection.getSenderId(), connection.getRecipientId(), recipientName);
            }
        } catch (Exception e) {
            System.err.println("Failed to send connection accepted notification: " + e.getMessage());
        }
        
        return savedConnection;
    }
    
    public Connection rejectConnectionRequest(String connectionId, String userId) {
        Optional<Connection> connectionOpt = connectionRepository.findById(connectionId);
        if (connectionOpt.isEmpty()) {
            throw new RuntimeException("Connection request not found");
        }
        
        Connection connection = connectionOpt.get();
        
        // Verify user is the recipient
        if (!connection.getRecipientId().equals(userId)) {
            throw new RuntimeException("Unauthorized to reject this connection request");
        }
        
        // Update connection status
        connection.setStatus(Connection.ConnectionStatus.REJECTED);
        connection.setRespondedAt(LocalDateTime.now());
        
        return connectionRepository.save(connection);
    }
    
    public List<Connection> getPendingConnectionRequests(String userId) {
        return connectionRepository.findPendingConnectionRequests(userId);
    }
    
    public List<Connection> getAcceptedConnections(String userId) {
        return connectionRepository.findAcceptedConnectionsByUserId(userId);
    }
    
    public String getConnectionStatus(String userId1, String userId2) {
        Optional<Connection> connection = connectionRepository.findConnectionBetweenUsers(userId1, userId2);
        if (connection.isEmpty()) {
            return "none";
        }
        
        Connection conn = connection.get();
        switch (conn.getStatus()) {
            case PENDING:
                return "pending";
            case ACCEPTED:
                return "connected";
            case REJECTED:
                return "none";
            default:
                return "none";
        }
    }
    
    public long getConnectionCount(String userId) {
        return connectionRepository.findAcceptedConnectionsByUserId(userId).size();
    }
}
