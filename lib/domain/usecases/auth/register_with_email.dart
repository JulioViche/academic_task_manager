import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

/// Use case for registering a new user with email and password
class RegisterWithEmail {
  final AuthRepository repository;

  RegisterWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call(
    String email,
    String password,
    String? displayName,
  ) async {
    // Validate email format
    if (!_isValidEmail(email)) {
      return const Left(AuthFailure('Invalid email format'));
    }
    
    // Validate password strength
    if (password.length < 6) {
      return const Left(AuthFailure('Password must be at least 6 characters'));
    }
    
    return await repository.signUpWithEmailPassword(email, password, displayName);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
