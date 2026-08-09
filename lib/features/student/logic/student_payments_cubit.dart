import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';

class StudentPaymentsCubit extends Cubit<StudentPaymentsState> {
  final StudentPaymentsRepo _repo;

  StudentPaymentsCubit({required StudentPaymentsRepo repo})
    : _repo = repo,
      super(const StudentPaymentsState());

  Future<void> loadPayments(String userId) async {
    emit(state.copyWith(status: StudentPaymentsStatus.loading));
    final result = await _repo.getPayments(userId);
    result.when(
      success: (payments) => emit(
        state.copyWith(
          status: StudentPaymentsStatus.loaded,
          payments: payments,
        ),
      ),
      failure: (message, _) => emit(
        state.copyWith(
          status: StudentPaymentsStatus.error,
          errorMessage: message,
        ),
      ),
    );
  }

  Future<void> loadPaymentMethods(String studentId) async {
    emit(state.copyWith(methodsStatus: StudentPaymentsStatus.loading));
    final result = await _repo.getPaymentMethods(studentId);
    result.when(
      success: (methods) => emit(
        state.copyWith(
          methodsStatus: StudentPaymentsStatus.loaded,
          paymentMethods: methods,
        ),
      ),
      failure: (message, _) => emit(
        state.copyWith(
          methodsStatus: StudentPaymentsStatus.error,
          errorMessage: message,
        ),
      ),
    );
  }

  Future<bool> addPaymentMethod({
    required String studentId,
    required String cardHolder,
    required String cardLast4,
    String? cardBrand,
    int? expiryMonth,
    int? expiryYear,
    bool isDefault = false,
  }) async {
    emit(state.copyWith(isSaving: true));
    final result = await _repo.addPaymentMethod(
      studentId: studentId,
      cardHolder: cardHolder,
      cardLast4: cardLast4,
      cardBrand: cardBrand,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      isDefault: isDefault,
    );
    var saved = false;
    result.when(
      success: (_) {
        saved = true;
        emit(state.copyWith(isSaving: false));
      },
      failure: (message, _) =>
          emit(state.copyWith(isSaving: false, errorMessage: message)),
    );
    return saved;
  }

  Future<void> deletePaymentMethod(String studentId, String methodId) async {
    final result = await _repo.deletePaymentMethod(studentId, methodId);
    result.when(
      success: (_) => loadPaymentMethods(studentId),
      failure: (_, __) {},
    );
  }

  Future<void> setDefault(String studentId, String methodId) async {
    final result = await _repo.setDefaultPaymentMethod(studentId, methodId);
    result.when(
      success: (_) => loadPaymentMethods(studentId),
      failure: (_, __) {},
    );
  }

  /// Subscribes with payment; returns true on success.
  Future<bool> subscribeWithPayment({
    required String teacherId,
    required double amount,
    String? courseId,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _repo.subscribeWithPayment(
      teacherId: teacherId,
      amount: amount,
      courseId: courseId,
    );
    var ok = false;
    result.when(
      success: (_) {
        ok = true;
        emit(state.copyWith(isSaving: false));
      },
      failure: (message, _) =>
          emit(state.copyWith(isSaving: false, errorMessage: message)),
    );
    return ok;
  }

  /// Subscribes to a free course; returns true on success.
  Future<bool> subscribeFree({
    required String studentId,
    required String teacherId,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _repo.subscribeFree(
      studentId: studentId,
      teacherId: teacherId,
    );
    var ok = false;
    result.when(
      success: (_) {
        ok = true;
        emit(state.copyWith(isSaving: false));
      },
      failure: (message, _) =>
          emit(state.copyWith(isSaving: false, errorMessage: message)),
    );
    return ok;
  }

  /// Redeems an activation code; returns null on success or an Arabic error.
  Future<String?> redeemActivationCode(String code) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _repo.redeemActivationCode(code);
    String? error;
    result.when(
      success: (_) => emit(state.copyWith(isSaving: false)),
      failure: (message, _) {
        error = message;
        emit(state.copyWith(isSaving: false, errorMessage: message));
      },
    );
    return error;
  }
}

enum StudentPaymentsStatus { initial, loading, loaded, error }

class StudentPaymentsState {
  final StudentPaymentsStatus status;
  final List<Map<String, dynamic>> payments;
  final StudentPaymentsStatus methodsStatus;
  final List<Map<String, dynamic>> paymentMethods;
  final bool isSaving;
  final String? errorMessage;

  const StudentPaymentsState({
    this.status = StudentPaymentsStatus.initial,
    this.payments = const [],
    this.methodsStatus = StudentPaymentsStatus.initial,
    this.paymentMethods = const [],
    this.isSaving = false,
    this.errorMessage,
  });

  StudentPaymentsState copyWith({
    StudentPaymentsStatus? status,
    List<Map<String, dynamic>>? payments,
    StudentPaymentsStatus? methodsStatus,
    List<Map<String, dynamic>>? paymentMethods,
    bool? isSaving,
    String? errorMessage,
  }) {
    return StudentPaymentsState(
      status: status ?? this.status,
      payments: payments ?? this.payments,
      methodsStatus: methodsStatus ?? this.methodsStatus,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}
