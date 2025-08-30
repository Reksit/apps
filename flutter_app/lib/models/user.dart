class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final String? department;
  final String? profilePicture;
  final DateTime? lastLogin;
  final bool verified;
  
  // Student specific
  final String? studentId;
  final String? course;
  final String? year;
  final String? semester;
  final double? cgpa;
  final String? className;
  
  // Professor specific
  final String? employeeId;
  final String? designation;
  final int? experience;
  final List<String>? subjectsTeaching;
  final List<String>? researchInterests;
  final int? publications;
  final int? studentsSupervised;
  
  // Alumni specific
  final int? graduationYear;
  final String? currentCompany;
  final String? currentPosition;
  final int? workExperience;
  final List<String>? achievements;
  final bool? mentorshipAvailable;
  
  // Common profile fields
  final String? bio;
  final List<String>? skills;
  final String? location;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? portfolioUrl;
  final DateTime? createdAt;
  final DateTime? lastActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.department,
    this.profilePicture,
    this.lastLogin,
    this.verified = false,
    this.studentId,
    this.course,
    this.year,
    this.semester,
    this.cgpa,
    this.className,
    this.employeeId,
    this.designation,
    this.experience,
    this.subjectsTeaching,
    this.researchInterests,
    this.publications,
    this.studentsSupervised,
    this.graduationYear,
    this.currentCompany,
    this.currentPosition,
    this.workExperience,
    this.achievements,
    this.mentorshipAvailable,
    this.bio,
    this.skills,
    this.location,
    this.linkedinUrl,
    this.githubUrl,
    this.portfolioUrl,
    this.createdAt,
    this.lastActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      department: json['department'],
      profilePicture: json['profilePicture'],
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      verified: json['verified'] ?? false,
      studentId: json['studentId'],
      course: json['course'],
      year: json['year'],
      semester: json['semester'],
      cgpa: json['cgpa']?.toDouble(),
      className: json['className'],
      employeeId: json['employeeId'],
      designation: json['designation'],
      experience: json['experience'],
      subjectsTeaching: json['subjectsTeaching']?.cast<String>(),
      researchInterests: json['researchInterests']?.cast<String>(),
      publications: json['publications'],
      studentsSupervised: json['studentsSupervised'],
      graduationYear: json['graduationYear'],
      currentCompany: json['currentCompany'],
      currentPosition: json['currentPosition'],
      workExperience: json['workExperience'],
      achievements: json['achievements']?.cast<String>(),
      mentorshipAvailable: json['mentorshipAvailable'],
      bio: json['bio'],
      skills: json['skills']?.cast<String>(),
      location: json['location'],
      linkedinUrl: json['linkedinUrl'],
      githubUrl: json['githubUrl'],
      portfolioUrl: json['portfolioUrl'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastActive: json['lastActive'] != null ? DateTime.parse(json['lastActive']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'department': department,
      'profilePicture': profilePicture,
      'lastLogin': lastLogin?.toIso8601String(),
      'verified': verified,
      'studentId': studentId,
      'course': course,
      'year': year,
      'semester': semester,
      'cgpa': cgpa,
      'className': className,
      'employeeId': employeeId,
      'designation': designation,
      'experience': experience,
      'subjectsTeaching': subjectsTeaching,
      'researchInterests': researchInterests,
      'publications': publications,
      'studentsSupervised': studentsSupervised,
      'graduationYear': graduationYear,
      'currentCompany': currentCompany,
      'currentPosition': currentPosition,
      'workExperience': workExperience,
      'achievements': achievements,
      'mentorshipAvailable': mentorshipAvailable,
      'bio': bio,
      'skills': skills,
      'location': location,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'portfolioUrl': portfolioUrl,
      'createdAt': createdAt?.toIso8601String(),
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? phoneNumber,
    String? department,
    String? profilePicture,
    DateTime? lastLogin,
    bool? verified,
    String? studentId,
    String? course,
    String? year,
    String? semester,
    double? cgpa,
    String? className,
    String? employeeId,
    String? designation,
    int? experience,
    List<String>? subjectsTeaching,
    List<String>? researchInterests,
    int? publications,
    int? studentsSupervised,
    int? graduationYear,
    String? currentCompany,
    String? currentPosition,
    int? workExperience,
    List<String>? achievements,
    bool? mentorshipAvailable,
    String? bio,
    List<String>? skills,
    String? location,
    String? linkedinUrl,
    String? githubUrl,
    String? portfolioUrl,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      profilePicture: profilePicture ?? this.profilePicture,
      lastLogin: lastLogin ?? this.lastLogin,
      verified: verified ?? this.verified,
      studentId: studentId ?? this.studentId,
      course: course ?? this.course,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      cgpa: cgpa ?? this.cgpa,
      className: className ?? this.className,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      experience: experience ?? this.experience,
      subjectsTeaching: subjectsTeaching ?? this.subjectsTeaching,
      researchInterests: researchInterests ?? this.researchInterests,
      publications: publications ?? this.publications,
      studentsSupervised: studentsSupervised ?? this.studentsSupervised,
      graduationYear: graduationYear ?? this.graduationYear,
      currentCompany: currentCompany ?? this.currentCompany,
      currentPosition: currentPosition ?? this.currentPosition,
      workExperience: workExperience ?? this.workExperience,
      achievements: achievements ?? this.achievements,
      mentorshipAvailable: mentorshipAvailable ?? this.mentorshipAvailable,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}