import 'package:equatable/equatable.dart';
import 'package:thanaweya_online/features/shared/models/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool isVerified;
  final UserModel? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.isVerified = false,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    bool? isVerified,
    UserModel? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      isVerified: isVerified ?? this.isVerified,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, isVerified, user];
}
