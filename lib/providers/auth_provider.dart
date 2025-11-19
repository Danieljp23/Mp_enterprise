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
  bool _workspaceLinked = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get workspaceLinked => _workspaceLinked;
  bool get needsWorkspaceLink => !_workspaceLinked;

  void initialize() {
    _authSubscription = _repository.authStateChanges().listen(
      (user) {
        _user = user;
        _isLoading = false;
        _workspaceLinked = _repository.isWorkspaceLinked;
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
    _error = null;
    _setLoading(true);
    try {
      await _repository.signInWithGoogle();
      _workspaceLinked = true;
    } catch (e) {
      _error = 'Falha ao autenticar: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _error = null;
    _setLoading(true);
    try {
      await _repository.signInWithEmailAndPassword(email, password);
      // Workspace linking is optional - user can link later from tasks screen
      _workspaceLinked = _repository.isWorkspaceLinked;
    } catch (e) {
      _error = 'Falha ao autenticar: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _error = null;
    _setLoading(true);
    try {
      await _repository.registerWithEmailAndPassword(email, password);
      // Workspace linking is optional - user can link later from tasks screen
      _workspaceLinked = _repository.isWorkspaceLinked;
    } catch (e) {
      _error = 'Falha ao registrar: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> linkWorkspaceAccount() async {
    _error = null;
    _setLoading(true);
    try {
      await _repository.linkWorkspaceAccount();
      _workspaceLinked = _repository.isWorkspaceLinked;
    } catch (e) {
      _error = 'Não foi possível conectar ao Workspace: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    await _repository.signOut();
    _workspaceLinked = false;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
