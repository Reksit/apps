enum AssessmentType { aiGenerated, classAssessment }

class Assessment {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final List<String> assignedTo;
  final List<Question> questions;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final AssessmentType type;
  final String? domain;
  final String? difficulty;
  final int totalMarks;
  final int duration; // in minutes

  Assessment({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.assignedTo,
    required this.questions,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.type,
    this.domain,
    this.difficulty,
    required this.totalMarks,
    required this.duration,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['createdBy'] ?? '',
      assignedTo: (json['assignedTo'] as List<dynamic>?)?.cast<String>() ?? [],
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => Question.fromJson(q))
          .toList() ?? [],
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: DateTime.parse(json['endTime'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      type: _parseAssessmentType(json['type']),
      domain: json['domain'],
      difficulty: json['difficulty'],
      totalMarks: json['totalMarks'] ?? 0,
      duration: json['duration'] ?? 60,
    );
  }

  static AssessmentType _parseAssessmentType(String? type) {
    switch (type?.toUpperCase()) {
      case 'AI_GENERATED':
        return AssessmentType.aiGenerated;
      case 'CLASS_ASSESSMENT':
        return AssessmentType.classAssessment;
      default:
        return AssessmentType.classAssessment;
    }
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }

  bool get isCompleted {
    return DateTime.now().isAfter(endTime);
  }

  String get statusDisplay {
    if (isUpcoming) return 'Upcoming';
    if (isActive) return 'Active';
    return 'Completed';
  }
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? '',
      options: (json['options'] as List<dynamic>?)?.cast<String>() ?? [],
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'] ?? '',
    );
  }
}

class AssessmentResult {
  final String id;
  final String assessmentId;
  final String studentId;
  final String studentName;
  final List<Answer> answers;
  final int score;
  final int totalMarks;
  final double percentage;
  final DateTime submittedAt;
  final DateTime startedAt;
  final int timeTaken; // in seconds
  final List<Feedback> feedback;

  AssessmentResult({
    required this.id,
    required this.assessmentId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.submittedAt,
    required this.startedAt,
    required this.timeTaken,
    required this.feedback,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] ?? '',
      assessmentId: json['assessmentId'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      answers: (json['answers'] as List<dynamic>?)
          ?.map((a) => Answer.fromJson(a))
          .toList() ?? [],
      score: json['score'] ?? 0,
      totalMarks: json['totalMarks'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      submittedAt: DateTime.parse(json['submittedAt'] ?? DateTime.now().toIso8601String()),
      startedAt: DateTime.parse(json['startedAt'] ?? DateTime.now().toIso8601String()),
      timeTaken: json['timeTaken'] ?? 0,
      feedback: (json['feedback'] as List<dynamic>?)
          ?.map((f) => Feedback.fromJson(f))
          .toList() ?? [],
    );
  }

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    return 'F';
  }

  String get formattedTimeTaken {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    return '${minutes}m ${seconds}s';
  }
}

class Answer {
  final int questionIndex;
  final int selectedAnswer;
  final bool isCorrect;

  Answer({
    required this.questionIndex,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionIndex: json['questionIndex'] ?? 0,
      selectedAnswer: json['selectedAnswer'] ?? -1,
      isCorrect: json['isCorrect'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionIndex': questionIndex,
      'selectedAnswer': selectedAnswer,
      'isCorrect': isCorrect,
    };
  }
}

class Feedback {
  final int questionIndex;
  final String question;
  final String selectedOption;
  final String correctOption;
  final String explanation;
  final bool isCorrect;

  Feedback({
    required this.questionIndex,
    required this.question,
    required this.selectedOption,
    required this.correctOption,
    required this.explanation,
    required this.isCorrect,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      questionIndex: json['questionIndex'] ?? 0,
      question: json['question'] ?? '',
      selectedOption: json['selectedOption'] ?? '',
      correctOption: json['correctOption'] ?? '',
      explanation: json['explanation'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}