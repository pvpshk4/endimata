import 'package:endimata/features/auth/domain/entities/user_entity.dart';
import 'package:endimata/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  const GetCurrentUser(this.repository);

  UserEntity? call() {
    return repository.getCurrentUser();
  }
}
