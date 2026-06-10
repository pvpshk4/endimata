import 'package:equatable/equatable.dart';
import 'package:endimata/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitialState extends AuthState {
  const AuthInitialState();
  @override
  List<Object?> get props => [];
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
  @override
  List<Object?> get props => [];
}

class AuthAuthenticatedState extends AuthState {
  final UserEntity user;
  const AuthAuthenticatedState(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState();
  @override
  List<Object?> get props => [];
}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
