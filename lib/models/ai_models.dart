class ChatMessage {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}

class Conversation {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final int messageCount;
  final String? lastMessage;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.title,
    this.messages = const [],
    this.messageCount = 0,
    this.lastMessage,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? 'New Conversation',
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((m) => ChatMessage.fromJson(m))
              .toList()
          : [],
      messageCount: json['messageCount'] ?? 0,
      lastMessage: json['lastMessage'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class SoilAnalysisResult {
  final String message;
  final List<String> crops;
  final List<String> fertilizers;
  final List<String> organicSolutions;
  final String irrigation;
  final String? cropRotation;
  final List<String> warnings;
  final String riskLevel;
  final String? yieldPotential;
  final List<AgriShop> shops;
  final String? analysisId;

  SoilAnalysisResult({
    required this.message,
    this.crops = const [],
    this.fertilizers = const [],
    this.organicSolutions = const [],
    this.irrigation = '',
    this.cropRotation,
    this.warnings = const [],
    this.riskLevel = 'medium',
    this.yieldPotential,
    this.shops = const [],
    this.analysisId,
  });

  factory SoilAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SoilAnalysisResult(
      message: json['message'] ?? '',
      crops: json['crops'] != null ? List<String>.from(json['crops']) : [],
      fertilizers: json['fertilizers'] != null
          ? List<String>.from(json['fertilizers'])
          : [],
      organicSolutions: json['organicSolutions'] != null
          ? List<String>.from(json['organicSolutions'])
          : [],
      irrigation: json['irrigation'] ?? '',
      cropRotation: json['cropRotation'],
      warnings:
          json['warnings'] != null ? List<String>.from(json['warnings']) : [],
      riskLevel: json['riskLevel'] ?? 'medium',
      yieldPotential: json['yieldPotential'],
      shops: json['shops'] != null
          ? (json['shops'] as List).map((s) => AgriShop.fromJson(s)).toList()
          : [],
      analysisId: json['analysisId'],
    );
  }
}

class DiseaseDetectionResult {
  final String plantType;
  final String disease;
  final double confidence;
  final List<String> medicines;
  final List<String> organicAlternatives;
  final List<String> preventiveSteps;
  final String? severity;
  final String? symptoms;
  final String? spreadRisk;
  final List<AgriShop> shops;
  final String? detectionId;

  DiseaseDetectionResult({
    required this.plantType,
    required this.disease,
    required this.confidence,
    this.medicines = const [],
    this.organicAlternatives = const [],
    this.preventiveSteps = const [],
    this.severity,
    this.symptoms,
    this.spreadRisk,
    this.shops = const [],
    this.detectionId,
  });

  factory DiseaseDetectionResult.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionResult(
      plantType: json['plantType'] ?? 'Unknown',
      disease: json['disease'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      medicines: json['medicines'] != null
          ? List<String>.from(json['medicines'])
          : [],
      organicAlternatives: json['organicAlternatives'] != null
          ? List<String>.from(json['organicAlternatives'])
          : [],
      preventiveSteps: json['preventiveSteps'] != null
          ? List<String>.from(json['preventiveSteps'])
          : [],
      severity: json['severity'],
      symptoms: json['symptoms'],
      spreadRisk: json['spreadRisk'],
      shops: json['shops'] != null
          ? (json['shops'] as List).map((s) => AgriShop.fromJson(s)).toList()
          : [],
      detectionId: json['detectionId'],
    );
  }
}

class AgriShop {
  final String name;
  final String phone;
  final String address;
  final String distance;
  final double rating;
  final String mapsUrl;

  AgriShop({
    required this.name,
    required this.phone,
    required this.address,
    required this.distance,
    required this.rating,
    required this.mapsUrl,
  });

  factory AgriShop.fromJson(Map<String, dynamic> json) {
    return AgriShop(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      distance: json['distance']?.toString() ?? '0',
      rating: (json['rating'] ?? 0.0).toDouble(),
      mapsUrl: json['mapsUrl'] ?? '',
    );
  }
}
