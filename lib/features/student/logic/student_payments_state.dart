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
