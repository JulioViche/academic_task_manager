import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return repository.signInWithGoogle();
  }
}

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return repository.signOut();
  }
}
