import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in with Facebook
class LoginWithFacebook {
  final AuthRepository repository;

  LoginWithFacebook(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithFacebook();
  }
}
