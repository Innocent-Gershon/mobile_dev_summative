class UserModel {
  final String uid;
  final String email;
  final String name;
  final String userType;
  final String? phoneNumber;
  final String? studentName;
  final String? studentClass;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.userType,
    this.phoneNumber,
    this.studentName,
    this.studentClass,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? '',
      phoneNumber: map['phoneNumber'],
      studentName: map['childName'] ?? map['studentName'],
      studentClass: map['childClass'] ?? map['studentClass'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'userType': userType,
      'phoneNumber': phoneNumber,
      'childName': studentName,
      'childClass': studentClass,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class StudentModel {
  final String uid;
  final String email;
  final String name;
  final String studentClass;
  final bool isActive;
  final DateTime createdAt;

  StudentModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.studentClass,
    this.isActive = true,
    required this.createdAt,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      studentClass: map['studentClass'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}