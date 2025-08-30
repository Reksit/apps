package com.stjoseph.assessmentsystem.dto;

public class AlumniStatsResponse {
    private long networkConnections;
    private long studentsHelped;
    private long jobsPosted;
    
    public AlumniStatsResponse() {}
    
    public AlumniStatsResponse(long networkConnections, long studentsHelped, long jobsPosted) {
        this.networkConnections = networkConnections;
        this.studentsHelped = studentsHelped;
        this.jobsPosted = jobsPosted;
    }
    
    // Getters and setters
    public long getNetworkConnections() {
        return networkConnections;
    }
    
    public void setNetworkConnections(long networkConnections) {
        this.networkConnections = networkConnections;
    }
    
    public long getStudentsHelped() {
        return studentsHelped;
    }
    
    public void setStudentsHelped(long studentsHelped) {
        this.studentsHelped = studentsHelped;
    }
    
    public long getJobsPosted() {
        return jobsPosted;
    }
    
    public void setJobsPosted(long jobsPosted) {
        this.jobsPosted = jobsPosted;
    }
}
