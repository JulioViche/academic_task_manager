import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../datasources/remote/auth_remote_data_source.dart';
import '../datasources/local/user_dao.dart';

/// Implementation of AuthRepository with offline-first approach
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserDao userDao;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userDao,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signInWithGoogle();
        await _cacheAndSaveUser(user);
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Google sign in failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signInWithFacebook();
        await _cacheAndSaveUser(user);
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Facebook sign in failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailPassword(
      String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final user =
            await remoteDataSource.signInWithEmailPassword(email, password);
        await _cacheAndSaveUser(user);
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Sign in failed: ${e.toString()}'));
      }
    } else {
      // Try offline login with cached credentials
      try {
        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null && cachedUser.email == email) {
          return Right(cachedUser);
        }
        return const Left(NetworkFailure('No internet connection'));
      } catch (e) {
        return const Left(NetworkFailure('No internet connection'));
      }
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailPassword(
      String email, String password, String? displayName) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.signUpWithEmailPassword(
            email, password, displayName);
        await _cacheAndSaveUser(user);
        return Right(user);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Registration failed: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearCache();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      // First check cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      // If online, check remote
      if (await networkInfo.isConnected) {
        final remoteUser = await remoteDataSource.getCurrentUser();
        if (remoteUser != null) {
          await _cacheAndSaveUser(remoteUser);
        }
        return Right(remoteUser);
      }

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPasswordResetEmail(email);
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (e) {
        return Left(
            ServerFailure('Failed to send password reset: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final cachedUser = await localDataSource.getCachedUser();
    return cachedUser != null;
  }

  /// Helper to cache user and save to local database
  Future<void> _cacheAndSaveUser(UserModel user) async {
    await localDataSource.cacheUser(user);
    await userDao.insertOrUpdateUser(user);
  }
}
