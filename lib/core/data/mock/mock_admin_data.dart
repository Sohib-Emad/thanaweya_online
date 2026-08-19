import 'mock_subject_data.dart';

/// Mock admin dashboard data, teacher management, and subscription plans.
class MockAdminData {
  MockAdminData._();

  /// Admin overview statistics.
  static final mockAdminStats = {
    'pending_requests': 5,
    'total_teachers': 12,
    'total_students': 89,
  };

  /// Teachers awaiting admin approval.
  static final mockPendingTeachers = [
    {
      'id': 'pt1',
      'users': {'full_name': 'أ. عادل مصطفى', 'email': 'adel@test.com'},
      'subjects': {'name_ar': 'الرياضيات'},
      'approval_status': 'pending',
    },
    {
      'id': 'pt2',
      'users': {'full_name': 'أ. هبة الله أحمد', 'email': 'heba@test.com'},
      'subjects': {'name_ar': 'اللغة العربية'},
      'approval_status': 'pending',
    },
    {
      'id': 'pt3',
      'users': {'full_name': 'أ. كريم شريف', 'email': 'karim@test.com'},
      'subjects': {'name_ar': 'الفيزياء'},
      'approval_status': 'pending',
    },
  ];

  /// All teachers with approval status (approved, pending, rejected).
  static final mockAllTeachers = [
    ...MockSubjectData.mockTeachers
        .map((t) => {...t, 'approval_status': 'approved'}),
    ...mockPendingTeachers,
    {
      'id': 't_rejected',
      'users': {'full_name': 'أ. سيد حسن', 'email': 'sayed@test.com'},
      'subjects': {'name_ar': 'العلوم'},
      'approval_status': 'rejected',
    },
  ];

  /// Recently joined teachers for the admin dashboard.
  static final mockRecentTeachers = [
    {
      'users': {'full_name': 'أ. محمد علي'},
      'subjects': {'name_ar': 'الرياضيات'},
    },
    {
      'users': {'full_name': 'أ. فاطمة حسن'},
      'subjects': {'name_ar': 'الفيزياء'},
    },
    {
      'users': {'full_name': 'أ. خالد إبراهيم'},
      'subjects': {'name_ar': 'العلوم'},
    },
  ];

  /// Available subscription plans.
  static final mockPlans = [
    {
      'id': 'p1',
      'name': 'باقة شهرية',
      'price': 150,
      'billing_period': 'monthly',
      'is_active': true,
    },
    {
      'id': 'p2',
      'name': 'باقة فصل دراسي',
      'price': 400,
      'billing_period': 'term',
      'is_active': true,
    },
    {
      'id': 'p3',
      'name': 'باقة سنوية',
      'price': 1000,
      'billing_period': 'yearly',
      'is_active': false,
    },
  ];
}
