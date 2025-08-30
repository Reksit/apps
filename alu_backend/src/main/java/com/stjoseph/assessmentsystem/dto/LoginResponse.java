package com.stjoseph.assessmentsystem.dto;

public class LoginResponse {
    private String token;
    private String type = "Bearer";
    private String id;
    private String email;
    private String name;
    private String role;
    
    public LoginResponse(String accessToken, String id, String email, String name, String role) {
        this.token = accessToken;
        this.id = id;
        this.email = email;
        this.name = name;
        this.role = role;
    }
    
    // Getters and setters
    public String getAccessToken() { return token; }
    public void setAccessToken(String accessToken) { this.token = accessToken; }
    
    public String getTokenType() { return type; }
    public void setTokenType(String tokenType) { this.type = tokenType; }
    
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}