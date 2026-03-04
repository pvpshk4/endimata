import 'package:endimata/features/auth/domain/repositories/auth_repository.dart';

class SignOut {
  final AuthRepository repository;

  const SignOut(this.repository);

  Future<void> call() async {
    return await repository.signOut();
  }
}
