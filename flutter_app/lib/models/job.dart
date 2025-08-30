enum JobType { fullTime, partTime, internship, contract }

enum JobStatus { active, inactive, expired }

class Job {
  final String id;
  final String title;
  final String company;
  final String? companyDescription;
  final String? companyWebsite;
  final String location;
  final String? workMode;
  final JobType type;
  final String? salary;
  final String? salaryMin;
  final String? salaryMax;
  final String? currency;
  final String description;
  final List<String> requirements;
  final List<String>? responsibilities;
  final List<String>? benefits;
  final List<String>? skillsRequired;
  final String? experienceLevel;
  final int? minExperience;
  final int? maxExperience;
  final String? educationLevel;
  final String? industry;
  final String? department;
  final String? employmentDuration;
  final DateTime? applicationDeadline;
  final String postedBy;
  final String postedByName;
  final String postedByEmail;
  final String? postedByDesignation;
  final String? postedByCompany;
  final DateTime postedAt;
  final String? applicationUrl;
  final String? contactEmail;
  final String? contactPhone;
  final JobStatus status;
  final int? viewCount;
  final int? applicationCount;

  Job({
    required this.id,
    required this.title,
    required this.company,
    this.companyDescription,
    this.companyWebsite,
    required this.location,
    this.workMode,
    required this.type,
    this.salary,
    this.salaryMin,
    this.salaryMax,
    this.currency,
    required this.description,
    required this.requirements,
    this.responsibilities,
    this.benefits,
    this.skillsRequired,
    this.experienceLevel,
    this.minExperience,
    this.maxExperience,
    this.educationLevel,
    this.industry,
    this.department,
    this.employmentDuration,
    this.applicationDeadline,
    required this.postedBy,
    required this.postedByName,
    required this.postedByEmail,
    this.postedByDesignation,
    this.postedByCompany,
    required this.postedAt,
    this.applicationUrl,
    this.contactEmail,
    this.contactPhone,
    this.status = JobStatus.active,
    this.viewCount,
    this.applicationCount,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      companyDescription: json['companyDescription'],
      companyWebsite: json['companyWebsite'],
      location: json['location'] ?? '',
      workMode: json['workMode'],
      type: _parseJobType(json['type']),
      salary: json['salary'],
      salaryMin: json['salaryMin'],
      salaryMax: json['salaryMax'],
      currency: json['currency'],
      description: json['description'] ?? '',
      requirements: (json['requirements'] as List<dynamic>?)?.cast<String>() ?? [],
      responsibilities: (json['responsibilities'] as List<dynamic>?)?.cast<String>(),
      benefits: (json['benefits'] as List<dynamic>?)?.cast<String>(),
      skillsRequired: (json['skillsRequired'] as List<dynamic>?)?.cast<String>(),
      experienceLevel: json['experienceLevel'],
      minExperience: json['minExperience'],
      maxExperience: json['maxExperience'],
      educationLevel: json['educationLevel'],
      industry: json['industry'],
      department: json['department'],
      employmentDuration: json['employmentDuration'],
      applicationDeadline: json['applicationDeadline'] != null 
          ? DateTime.parse(json['applicationDeadline']) 
          : null,
      postedBy: json['postedBy'] ?? '',
      postedByName: json['postedByName'] ?? '',
      postedByEmail: json['postedByEmail'] ?? '',
      postedByDesignation: json['postedByDesignation'],
      postedByCompany: json['postedByCompany'],
      postedAt: DateTime.parse(json['postedAt'] ?? DateTime.now().toIso8601String()),
      applicationUrl: json['applicationUrl'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      status: _parseJobStatus(json['status']),
      viewCount: json['viewCount'],
      applicationCount: json['applicationCount'],
    );
  }

  static JobType _parseJobType(String? type) {
    switch (type?.toUpperCase()) {
      case 'FULL_TIME':
        return JobType.fullTime;
      case 'PART_TIME':
        return JobType.partTime;
      case 'INTERNSHIP':
        return JobType.internship;
      case 'CONTRACT':
        return JobType.contract;
      default:
        return JobType.fullTime;
    }
  }

  static JobStatus _parseJobStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
        return JobStatus.active;
      case 'INACTIVE':
        return JobStatus.inactive;
      case 'EXPIRED':
        return JobStatus.expired;
      default:
        return JobStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'companyDescription': companyDescription,
      'companyWebsite': companyWebsite,
      'location': location,
      'workMode': workMode,
      'type': type.name.toUpperCase(),
      'salary': salary,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'currency': currency,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'benefits': benefits,
      'skillsRequired': skillsRequired,
      'experienceLevel': experienceLevel,
      'minExperience': minExperience,
      'maxExperience': maxExperience,
      'educationLevel': educationLevel,
      'industry': industry,
      'department': department,
      'employmentDuration': employmentDuration,
      'applicationDeadline': applicationDeadline?.toIso8601String(),
      'postedBy': postedBy,
      'postedByName': postedByName,
      'postedByEmail': postedByEmail,
      'postedByDesignation': postedByDesignation,
      'postedByCompany': postedByCompany,
      'postedAt': postedAt.toIso8601String(),
      'applicationUrl': applicationUrl,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'status': status.name.toUpperCase(),
      'viewCount': viewCount,
      'applicationCount': applicationCount,
    };
  }

  String get jobTypeDisplay {
    switch (type) {
      case JobType.fullTime:
        return 'Full-time';
      case JobType.partTime:
        return 'Part-time';
      case JobType.internship:
        return 'Internship';
      case JobType.contract:
        return 'Contract';
    }
  }

  String get salaryDisplay {
    if (salaryMin != null && salaryMax != null) {
      return '$salaryMin - $salaryMax ${currency ?? 'INR'}';
    } else if (salary != null) {
      return salary!;
    }
    return 'Not specified';
  }

  bool get isExpired {
    if (applicationDeadline == null) return false;
    return DateTime.now().isAfter(applicationDeadline!);
  }
}