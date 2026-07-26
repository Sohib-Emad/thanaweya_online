import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool isVerified;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isVerified = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isVerified,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isVerified];
}
