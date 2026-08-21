import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thanaweya_online/features/shared/models/user_model.dart';
import '../data/repos/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AuthCubit({required this.authRepo}) : super(const AuthState());

  void checkAuthStatus() {
    if (authRepo.isAuthenticated) {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepo.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: UserRole.fromString(role),
    );

    result.when(
      success: (_) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      },
      failure: (message, _) {
        emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
      },
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepo.signIn(email: email, password: password);

    result.when(
      success: (_) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      },
      failure: (message, _) {
        emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
      },
    );
  }

  Future<void> signOut() async {
    emit(state.copyWith(status: AuthStatus.loading));
    await authRepo.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepo.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    result.when(
      success: (_) {
        emit(state.copyWith(status: AuthStatus.authenticated));
      },
      failure: (message, _) {
        emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
      },
    );
  }

  Future<void> resetPassword(String email) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepo.resetPassword(email);

    result.when(
      success: (_) {
        emit(state.copyWith(status: AuthStatus.unauthenticated));
      },
      failure: (message, _) {
        emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
      },
    );
  }

  Future<void> verifyOtp({required String email, required String token}) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authRepo.verifyOtp(email: email, token: token);

    result.when(
      success: (_) {
        emit(
          state.copyWith(status: AuthStatus.authenticated, isVerified: true),
        );
      },
      failure: (message, _) {
        emit(state.copyWith(status: AuthStatus.error, errorMessage: message));
      },
    );
  }
}
