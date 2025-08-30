package com.stjoseph.assessmentsystem.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import com.stjoseph.assessmentsystem.model.Resume;

@Repository
public interface ResumeRepository extends MongoRepository<Resume, String> {
    
    List<Resume> findByUserIdAndIsActiveTrue(String userId);
    
    Optional<Resume> findByUserIdAndIsActiveTrueOrderByUploadedAtDesc(String userId);
    
    List<Resume> findByUserId(String userId);
    
    void deleteByUserId(String userId);
    
    List<Resume> findBySkillsContainingIgnoreCase(String skill);
    
    List<Resume> findByContactInfoLinkedinIsNotNull();
    
    List<Resume> findByContactInfoGithubIsNotNull();
}
