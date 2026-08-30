class AdminReportsData {
  final int totalStudents;
  final int totalTeachers;
  final int approvedTeachers;
  final int pendingTeachers;
  final int rejectedTeachers;
  final int totalCourses;
  final int publishedCourses;
  final int totalLessons;
  final int totalExams;
  final int totalSubmissions;
  final int activeSubscriptions;
  final double estimatedRevenue;
  final List<Map<String, dynamic>> subjectDistribution;

  const AdminReportsData({
    required this.totalStudents,
    required this.totalTeachers,
    required this.approvedTeachers,
    required this.pendingTeachers,
    required this.rejectedTeachers,
    required this.totalCourses,
    required this.publishedCourses,
    required this.totalLessons,
    required this.totalExams,
    required this.totalSubmissions,
    required this.activeSubscriptions,
    required this.estimatedRevenue,
    required this.subjectDistribution,
  });

  int get totalUsers => totalStudents + totalTeachers;
}
