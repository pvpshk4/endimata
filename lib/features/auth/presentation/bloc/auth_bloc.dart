import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc(AuthRepository authRepository)
    : _signInWithGoogle = SignInWithGoogle(authRepository),
      _signOut = SignOut(authRepository),
      _getCurrentUser = GetCurrentUser(authRepository),
      _authRepository = authRepository,
      super(const AuthInitialState()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);

    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticatedState(user));
      } else {
        if (state is! AuthInitialState) {
          emit(const AuthUnauthenticatedState());
        }
      }
    });

    add(const CheckAuthStatusEvent());
  }

  void _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) {
    final user = _getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticatedState(user));
    } else {
      emit(const AuthUnauthenticatedState());
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoadingState());
    try {
      final user = await _signInWithGoogle();
      if (user != null) {
        emit(AuthAuthenticatedState(user));
      } else {
        emit(const AuthUnauthenticatedState());
      }
    } catch (e) {
      emit(AuthErrorState('Ошибка входа: $e'));
    }
  }

  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoadingState());
    try {
      await _signOut();
      emit(const AuthUnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState('Ошибка выхода: $e'));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
