package com.stjoseph.assessmentsystem.service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.stjoseph.assessmentsystem.model.Alumni;
import com.stjoseph.assessmentsystem.model.Job;
import com.stjoseph.assessmentsystem.model.User;
import com.stjoseph.assessmentsystem.repository.AlumniRepository;
import com.stjoseph.assessmentsystem.repository.JobRepository;
import com.stjoseph.assessmentsystem.repository.UserRepository;

@Service
public class JobService {
    
    @Autowired
    private JobRepository jobRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private AlumniRepository alumniRepository;
    
    @Autowired
    private NotificationService notificationService;
    
    public List<Job> getAllActiveJobs() {
        return jobRepository.findByStatusOrderByPostedAtDesc(Job.JobStatus.ACTIVE);
    }
    
    public List<Job> getJobsByAlumni(String userEmail) {
        // Find user by email to get their ID
        Optional<User> userOpt = userRepository.findByEmail(userEmail);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("User not found");
        }
        return jobRepository.findByPostedByOrderByPostedAtDesc(userOpt.get().getId());
    }
    
    public Job createJob(Job job, String alumniEmail) {
        try {
            System.out.println("JobService: Creating job for alumni email: " + alumniEmail);
            
            // First try to find in User repository
            Optional<User> userOpt = userRepository.findByEmail(alumniEmail);
            User user = null;
            
            if (userOpt.isPresent()) {
                user = userOpt.get();
                System.out.println("JobService: Found user in User repository: " + user.getName() + ", Role: " + user.getRole());
                
                if (user.getRole() != User.UserRole.ALUMNI) {
                    System.err.println("JobService: User is not alumni, role: " + user.getRole());
                    throw new RuntimeException("Only alumni can post jobs");
                }
            } else {
                // Try to find in Alumni repository
                System.out.println("JobService: User not found in User repository, checking Alumni repository");
                Optional<Alumni> alumniOpt = alumniRepository.findByEmail(alumniEmail);
                
                if (alumniOpt.isPresent()) {
                    Alumni alumni = alumniOpt.get();
                    System.out.println("JobService: Found alumni in Alumni repository: " + alumni.getName() + ", Status: " + alumni.getStatus());
                    
                    if (alumni.getStatus() != Alumni.AlumniStatus.APPROVED) {
                        System.err.println("JobService: Alumni is not approved, status: " + alumni.getStatus());
                        throw new RuntimeException("Only approved alumni can post jobs");
                    }
                    
                    // Create a temporary User object for consistency
                    user = new User();
                    user.setId(alumni.getId());
                    user.setName(alumni.getName());
                    user.setEmail(alumni.getEmail());
                    user.setRole(User.UserRole.ALUMNI);
                } else {
                    System.err.println("JobService: User not found in either User or Alumni repository with email: " + alumniEmail);
                    throw new RuntimeException("User not found");
                }
            }
            
            // Set posting details
            job.setPostedBy(user.getId());
            job.setPostedByName(user.getName());
            job.setPostedByEmail(user.getEmail());
            job.setStatus(Job.JobStatus.ACTIVE);
            
            System.out.println("JobService: Saving job: " + job.getTitle());
            Job savedJob = jobRepository.save(job);
            System.out.println("JobService: Job saved with ID: " + savedJob.getId());
            
            // Send notification to followers
            try {
                notificationService.createJobPostNotification(user.getId(), user.getName(), job.getTitle());
            } catch (Exception e) {
                System.err.println("Failed to send job post notification: " + e.getMessage());
            }
            
            return savedJob;
        } catch (Exception e) {
            System.err.println("JobService: Error creating job: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to create job: " + e.getMessage());
        }
    }
    
    public Job updateJob(String jobId, Job jobData, String userEmail) {
        Job existingJob = jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found"));
        
        // Find user by email
        Optional<User> userOpt = userRepository.findByEmail(userEmail);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("User not found");
        }
        User user = userOpt.get();
        
        // Only the poster or management can edit
        if (!existingJob.getPostedBy().equals(user.getId())) {
            if (user.getRole() != User.UserRole.MANAGEMENT) {
                throw new RuntimeException("Unauthorized to edit this job");
            }
        }
        
        // Update fields
        existingJob.setTitle(jobData.getTitle());
        existingJob.setCompany(jobData.getCompany());
        existingJob.setLocation(jobData.getLocation());
        existingJob.setType(jobData.getType());
        existingJob.setSalary(jobData.getSalary());
        existingJob.setDescription(jobData.getDescription());
        existingJob.setRequirements(jobData.getRequirements());
        existingJob.setApplicationUrl(jobData.getApplicationUrl());
        existingJob.setContactEmail(jobData.getContactEmail());
        
        return jobRepository.save(existingJob);
    }
    
    public void deleteJob(String jobId, String userEmail) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found"));
        
        // Find user by email
        Optional<User> userOpt = userRepository.findByEmail(userEmail);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("User not found");
        }
        User user = userOpt.get();
        
        // Only the poster or management can delete
        if (!job.getPostedBy().equals(user.getId())) {
            if (user.getRole() != User.UserRole.MANAGEMENT) {
                throw new RuntimeException("Unauthorized to delete this job");
            }
        }
        
        jobRepository.deleteById(jobId);
    }
    
    public List<Job> searchJobs(String query) {
        // Simple search across title, company, and location
        List<Job> results = jobRepository.findByTitleContainingIgnoreCaseAndStatusOrderByPostedAtDesc(query, Job.JobStatus.ACTIVE);
        results.addAll(jobRepository.findByCompanyContainingIgnoreCaseAndStatusOrderByPostedAtDesc(query, Job.JobStatus.ACTIVE));
        results.addAll(jobRepository.findByLocationContainingIgnoreCaseAndStatusOrderByPostedAtDesc(query, Job.JobStatus.ACTIVE));
        
        // Remove duplicates
        return results.stream().distinct().toList();
    }
    
    public Job getJobById(String jobId) {
        return jobRepository.findById(jobId)
                .orElseThrow(() -> new RuntimeException("Job not found"));
    }
}
