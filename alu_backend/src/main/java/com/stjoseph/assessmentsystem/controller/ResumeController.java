package com.stjoseph.assessmentsystem.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.stjoseph.assessmentsystem.model.Resume;
import com.stjoseph.assessmentsystem.service.ResumeService;

@RestController
@RequestMapping("/resumes")
@CrossOrigin(origins = "*")
public class ResumeController {
    
    @Autowired
    private ResumeService resumeService;
    
    @PostMapping("/upload")
    public ResponseEntity<Resume> uploadResume(
            @RequestParam("file") MultipartFile file,
            Authentication authentication) {
        try {
            String userId = authentication.getName();
            Resume resume = resumeService.uploadResume(file, userId);
            return ResponseEntity.ok(resume);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/my")
    public ResponseEntity<List<Resume>> getMyResumes(Authentication authentication) {
        try {
            String userId = authentication.getName();
            List<Resume> resumes = resumeService.getUserResumes(userId);
            return ResponseEntity.ok(resumes);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/current")
    public ResponseEntity<Resume> getCurrentResume(Authentication authentication) {
        try {
            String userId = authentication.getName();
            Resume resume = resumeService.getCurrentResume(userId);
            if (resume != null) {
                return ResponseEntity.ok(resume);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Resume> getResume(@PathVariable String id, Authentication authentication) {
        try {
            Resume resume = resumeService.getResume(id);
            if (resume != null) {
                return ResponseEntity.ok(resume);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/{id}/download")
    public ResponseEntity<byte[]> downloadResume(@PathVariable String id, Authentication authentication) {
        try {
            Resume resume = resumeService.getResume(id);
            if (resume != null) {
                byte[] fileData = resumeService.downloadResume(id);
                
                HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
                headers.setContentDispositionFormData("attachment", resume.getFileName());
                
                return ResponseEntity.ok()
                        .headers(headers)
                        .body(fileData);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}/activate")
    public ResponseEntity<Void> activateResume(@PathVariable String id, Authentication authentication) {
        try {
            String userId = authentication.getName();
            resumeService.activateResume(id, userId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteResume(@PathVariable String id, Authentication authentication) {
        try {
            String userId = authentication.getName();
            resumeService.deleteResume(id, userId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Resume> updateResume(
            @PathVariable String id,
            @RequestBody Resume resumeData,
            Authentication authentication) {
        try {
            String userId = authentication.getName();
            Resume updatedResume = resumeService.updateResume(id, resumeData, userId);
            return ResponseEntity.ok(updatedResume);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Resume>> searchResumesBySkill(@RequestParam String skill) {
        try {
            List<Resume> resumes = resumeService.searchBySkill(skill);
            return ResponseEntity.ok(resumes);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<Resume> getUserCurrentResume(@PathVariable String userId) {
        try {
            Resume resume = resumeService.getCurrentResume(userId);
            if (resume != null) {
                return ResponseEntity.ok(resume);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}
