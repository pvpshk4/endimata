import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final String? error;

  const ProfileState({this.isLoading = false, this.error});

  ProfileState copyWith({bool? isLoading, String? error}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, error];
}
