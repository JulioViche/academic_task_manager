import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in with email and password
class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      return const Left(AuthFailure('Invalid email format'));
    }
    
    // Validate password is not empty
    if (password.isEmpty) {
      return const Left(AuthFailure('Password cannot be empty'));
    }
    
    return await repository.signInWithEmailPassword(email, password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
