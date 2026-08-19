import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/core/theme/student_payments_repo.dart';
export 'package:thanaweya_online/features/student/logic/student_payments_state.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_state.dart';

class StudentPaymentsCubit extends Cubit<StudentPaymentsState> {
  final StudentPaymentsRepo _repo;

  StudentPaymentsCubit({required StudentPaymentsRepo repo})
    : _repo = repo,
      super(const StudentPaymentsState());

  @override
  void emit(StudentPaymentsState state) {
    if (!isClosed) super.emit(state);
  }

  Future<void> loadPayments(String userId) async {
    emit(state.copyWith(status: StudentPaymentsStatus.loading));
    final result = await _repo.getPayments(userId);
    result.when(
      success: (payments) => emit(state.copyWith(
        status: StudentPaymentsStatus.loaded, payments: payments,
      )),
      failure: (message, _) => emit(state.copyWith(
        status: StudentPaymentsStatus.error, errorMessage: message,
      )),
    );
  }

  Future<void> loadPaymentMethods(String studentId) async {
    emit(state.copyWith(methodsStatus: StudentPaymentsStatus.loading));
    final result = await _repo.getPaymentMethods(studentId);
    result.when(
      success: (methods) => emit(state.copyWith(
        methodsStatus: StudentPaymentsStatus.loaded, paymentMethods: methods,
      )),
      failure: (message, _) => emit(state.copyWith(
        methodsStatus: StudentPaymentsStatus.error, errorMessage: message,
      )),
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
      studentId: studentId, cardHolder: cardHolder, cardLast4: cardLast4,
      cardBrand: cardBrand, expiryMonth: expiryMonth, expiryYear: expiryYear,
      isDefault: isDefault,
    );
    var saved = false;
    result.when(
      success: (_) { saved = true; emit(state.copyWith(isSaving: false)); },
      failure: (m, _) => emit(state.copyWith(isSaving: false, errorMessage: m)),
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

  Future<bool> subscribeWithPayment({
    required String teacherId,
    required double amount,
    String? courseId,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _repo.subscribeWithPayment(
      teacherId: teacherId, amount: amount, courseId: courseId,
    );
    var ok = false;
    result.when(
      success: (_) { ok = true; emit(state.copyWith(isSaving: false)); },
      failure: (m, _) => emit(state.copyWith(isSaving: false, errorMessage: m)),
    );
    return ok;
  }

  Future<bool> subscribeFree({
    required String studentId,
    required String teacherId,
  }) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _repo.subscribeFree(studentId: studentId, teacherId: teacherId);
    var ok = false;
    result.when(
      success: (_) { ok = true; emit(state.copyWith(isSaving: false)); },
      failure: (m, _) => emit(state.copyWith(isSaving: false, errorMessage: m)),
    );
    return ok;
  }

  Future<String?> redeemActivationCode(
    String code, {String? courseId, String? teacherId}
  ) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));
    final result = await _repo.redeemActivationCode(
      code, courseId: courseId, teacherId: teacherId,
    );
    String? error;
    result.when(
      success: (_) => emit(state.copyWith(isSaving: false)),
      failure: (m, _) { error = m; emit(state.copyWith(isSaving: false, errorMessage: m)); },
    );
    return error;
  }
}
