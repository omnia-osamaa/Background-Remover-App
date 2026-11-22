import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<void> forgotPassword(String email);
}

/// Fake implementation so the UI can be tested without a backend.
/// TODO: replace with a Dio-based implementation when the API is ready.
///
/// Tip for testing errors: sign up with `taken@example.com`.
class AuthRemoteDataSourceFake implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return UserModel(
      id: '1',
      name: _nameFromEmail(email),
      email: email,
      token: 'fake-token',
    );
  }

  @override
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.toLowerCase() == 'taken@example.com') {
      throw const ServerException(message: 'This email is already registered');
    }
    return UserModel(id: '2', name: name, email: email, token: 'fake-token');
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'User';
    return local[0].toUpperCase() + local.substring(1);
  }
}
