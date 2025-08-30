package com.stjoseph.assessmentsystem.model;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "resumes")
public class Resume {
    @Id
    private String id;
    
    private String userId;
    private String fileName;
    private String filePath;
    private String fileType;
    private long fileSize;
    private LocalDateTime uploadedAt;
    private boolean isActive;
    
    // Parsed resume data
    private List<String> skills;
    private List<Experience> experiences;
    private List<Education> educations;
    private List<String> certifications;
    private String summary;
    private ContactInfo contactInfo;
    
    public static class Experience {
        private String company;
        private String position;
        private String duration;
        private String description;
        private List<String> achievements;
        
        // Constructors
        public Experience() {}
        
        public Experience(String company, String position, String duration, String description) {
            this.company = company;
            this.position = position;
            this.duration = duration;
            this.description = description;
        }
        
        // Getters and Setters
        public String getCompany() { return company; }
        public void setCompany(String company) { this.company = company; }
        
        public String getPosition() { return position; }
        public void setPosition(String position) { this.position = position; }
        
        public String getDuration() { return duration; }
        public void setDuration(String duration) { this.duration = duration; }
        
        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }
        
        public List<String> getAchievements() { return achievements; }
        public void setAchievements(List<String> achievements) { this.achievements = achievements; }
    }
    
    public static class Education {
        private String institution;
        private String degree;
        private String field;
        private String duration;
        private String grade;
        
        // Constructors
        public Education() {}
        
        public Education(String institution, String degree, String field, String duration) {
            this.institution = institution;
            this.degree = degree;
            this.field = field;
            this.duration = duration;
        }
        
        // Getters and Setters
        public String getInstitution() { return institution; }
        public void setInstitution(String institution) { this.institution = institution; }
        
        public String getDegree() { return degree; }
        public void setDegree(String degree) { this.degree = degree; }
        
        public String getField() { return field; }
        public void setField(String field) { this.field = field; }
        
        public String getDuration() { return duration; }
        public void setDuration(String duration) { this.duration = duration; }
        
        public String getGrade() { return grade; }
        public void setGrade(String grade) { this.grade = grade; }
    }
    
    public static class ContactInfo {
        private String email;
        private String phone;
        private String address;
        private String linkedin;
        private String github;
        private String portfolio;
        
        // Constructors
        public ContactInfo() {}
        
        // Getters and Setters
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        
        public String getAddress() { return address; }
        public void setAddress(String address) { this.address = address; }
        
        public String getLinkedin() { return linkedin; }
        public void setLinkedin(String linkedin) { this.linkedin = linkedin; }
        
        public String getGithub() { return github; }
        public void setGithub(String github) { this.github = github; }
        
        public String getPortfolio() { return portfolio; }
        public void setPortfolio(String portfolio) { this.portfolio = portfolio; }
    }
    
    // Constructors
    public Resume() {
        this.uploadedAt = LocalDateTime.now();
        this.isActive = true;
    }
    
    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    
    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }
    
    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }
    
    public long getFileSize() { return fileSize; }
    public void setFileSize(long fileSize) { this.fileSize = fileSize; }
    
    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    
    public List<String> getSkills() { return skills; }
    public void setSkills(List<String> skills) { this.skills = skills; }
    
    public List<Experience> getExperiences() { return experiences; }
    public void setExperiences(List<Experience> experiences) { this.experiences = experiences; }
    
    public List<Education> getEducations() { return educations; }
    public void setEducations(List<Education> educations) { this.educations = educations; }
    
    public List<String> getCertifications() { return certifications; }
    public void setCertifications(List<String> certifications) { this.certifications = certifications; }
    
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    
    public ContactInfo getContactInfo() { return contactInfo; }
    public void setContactInfo(ContactInfo contactInfo) { this.contactInfo = contactInfo; }
}
