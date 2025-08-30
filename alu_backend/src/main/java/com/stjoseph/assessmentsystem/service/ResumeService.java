package com.stjoseph.assessmentsystem.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.stjoseph.assessmentsystem.model.Resume;
import com.stjoseph.assessmentsystem.repository.ResumeRepository;

@Service
public class ResumeService {
    
    @Autowired
    private ResumeRepository resumeRepository;
    
    @Value("${app.upload.dir:uploads/resumes}")
    private String uploadDir;
    
    public Resume uploadResume(MultipartFile file, String userId) throws IOException {
        // Validate file
        if (file.isEmpty()) {
            throw new IllegalArgumentException("File is empty");
        }
        
        String fileName = file.getOriginalFilename();
        if (fileName == null || fileName.isEmpty()) {
            throw new IllegalArgumentException("Invalid file name");
        }
        
        // Check file type
        String fileType = file.getContentType();
        if (!isValidFileType(fileType)) {
            throw new IllegalArgumentException("Invalid file type. Only PDF, DOC, and DOCX files are allowed");
        }
        
        // Create upload directory if it doesn't exist
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // Generate unique file name
        String fileExtension = getFileExtension(fileName);
        String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
        Path filePath = uploadPath.resolve(uniqueFileName);
        
        // Save file
        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
        
        // Deactivate previous resumes
        List<Resume> existingResumes = resumeRepository.findByUserIdAndIsActiveTrue(userId);
        existingResumes.forEach(resume -> {
            resume.setActive(false);
            resumeRepository.save(resume);
        });
        
        // Create resume record
        Resume resume = new Resume();
        resume.setUserId(userId);
        resume.setFileName(fileName);
        resume.setFilePath(filePath.toString());
        resume.setFileType(fileType);
        resume.setFileSize(file.getSize());
        resume.setActive(true);
        
        // TODO: Parse resume content for skills, experience, etc.
        // This could be enhanced with AI/ML parsing
        
        return resumeRepository.save(resume);
    }
    
    public List<Resume> getUserResumes(String userId) {
        return resumeRepository.findByUserId(userId);
    }
    
    public Resume getCurrentResume(String userId) {
        return resumeRepository.findByUserIdAndIsActiveTrueOrderByUploadedAtDesc(userId)
                .orElse(null);
    }
    
    public Resume getResume(String id) {
        return resumeRepository.findById(id).orElse(null);
    }
    
    public byte[] downloadResume(String id) throws IOException {
        Resume resume = resumeRepository.findById(id).orElse(null);
        if (resume == null) {
            throw new IllegalArgumentException("Resume not found");
        }
        
        Path filePath = Paths.get(resume.getFilePath());
        if (!Files.exists(filePath)) {
            throw new IOException("File not found on disk");
        }
        
        return Files.readAllBytes(filePath);
    }
    
    public void activateResume(String id, String userId) {
        Resume resume = resumeRepository.findById(id).orElse(null);
        if (resume == null || !resume.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Resume not found or unauthorized");
        }
        
        // Deactivate other resumes
        List<Resume> existingResumes = resumeRepository.findByUserIdAndIsActiveTrue(userId);
        existingResumes.forEach(r -> {
            r.setActive(false);
            resumeRepository.save(r);
        });
        
        // Activate this resume
        resume.setActive(true);
        resumeRepository.save(resume);
    }
    
    public void deleteResume(String id, String userId) throws IOException {
        Resume resume = resumeRepository.findById(id).orElse(null);
        if (resume == null || !resume.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Resume not found or unauthorized");
        }
        
        // Delete file from disk
        Path filePath = Paths.get(resume.getFilePath());
        if (Files.exists(filePath)) {
            Files.delete(filePath);
        }
        
        // Delete from database
        resumeRepository.deleteById(id);
    }
    
    public Resume updateResume(String id, Resume resumeData, String userId) {
        Resume resume = resumeRepository.findById(id).orElse(null);
        if (resume == null || !resume.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Resume not found or unauthorized");
        }
        
        // Update only editable fields
        resume.setSkills(resumeData.getSkills());
        resume.setExperiences(resumeData.getExperiences());
        resume.setEducations(resumeData.getEducations());
        resume.setCertifications(resumeData.getCertifications());
        resume.setSummary(resumeData.getSummary());
        resume.setContactInfo(resumeData.getContactInfo());
        
        return resumeRepository.save(resume);
    }
    
    public List<Resume> searchBySkill(String skill) {
        return resumeRepository.findBySkillsContainingIgnoreCase(skill);
    }
    
    private boolean isValidFileType(String fileType) {
        return fileType != null && (
                fileType.equals("application/pdf") ||
                fileType.equals("application/msword") ||
                fileType.equals("application/vnd.openxmlformats-officedocument.wordprocessingml.document")
        );
    }
    
    private String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < fileName.length() - 1) {
            return fileName.substring(lastDotIndex);
        }
        return "";
    }
}
