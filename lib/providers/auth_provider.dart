import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maple/firebase_conection/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final FirebaseAuthRepository _repository;
  StreamSubscription<User?>? _authSubscription;

  User? _user;
  bool _isLoading = true;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void initialize() {
    _authSubscription = _repository.authStateChanges().listen(
      (user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.signInWithGoogle();
    } catch (e) {
      _error = 'Falha ao autenticar: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _repository.signOut();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
