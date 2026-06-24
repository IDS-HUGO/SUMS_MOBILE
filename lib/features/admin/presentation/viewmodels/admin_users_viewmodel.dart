import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/admin_repository.dart';

enum AdminUsersStatus { initial, loading, loaded, error }

class AdminUsersViewModel extends ChangeNotifier {
  final AdminRepository repository;

  AdminUsersViewModel({required this.repository});

  AdminUsersStatus _status = AdminUsersStatus.initial;
  List<AdminUserEntity> _users = [];
  String? _errorMessage;

  AdminUsersStatus get status => _status;
  List<AdminUserEntity> get users => _users;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _status = AdminUsersStatus.loading;
    notifyListeners();

    try {
      _users = await repository.getUsers();
      _status = AdminUsersStatus.loaded;
      _errorMessage = null;
    } catch (e) {
      _status = AdminUsersStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> createUser(Map<String, dynamic> body) async {
    _status = AdminUsersStatus.loading;
    notifyListeners();

    try {
      final newUser = await repository.createUser(body);
      _users.add(newUser);
      _status = AdminUsersStatus.loaded;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AdminUsersStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
