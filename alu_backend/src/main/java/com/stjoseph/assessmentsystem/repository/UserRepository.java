package com.stjoseph.assessmentsystem.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.stereotype.Repository;

import com.stjoseph.assessmentsystem.model.User;

@Repository
public interface UserRepository extends MongoRepository<User, String> {
    Optional<User> findByEmail(String email);
    List<User> findByRole(User.UserRole role);
    boolean existsByEmail(String email);
    
    @Query("{ 'email': { $regex: ?0, $options: 'i' } }")
    List<User> findByEmailContainingIgnoreCase(String email);
    
    @Query("{ 'email': { $regex: '^?0', $options: 'i' } }")
    List<User> findByEmailStartingWithIgnoreCase(String emailPrefix);
    
    @Query("{ 'name': { $regex: ?0, $options: 'i' } }")
    List<User> findByNameContainingIgnoreCase(String name);
    
    @Query("{ 'phoneNumber': ?0 }")
    List<User> findByPhoneNumber(String phoneNumber);
    
    long countByRole(User.UserRole role);
    
    @Query("{ 'role': ?0, 'verified': ?1 }")
    List<User> findByRoleAndApproved(User.UserRole role, boolean approved);
}