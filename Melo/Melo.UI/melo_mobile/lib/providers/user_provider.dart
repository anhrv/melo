import 'package:flutter/foundation.dart';
import 'package:melo_mobile/models/user_response.dart';

class UserProvider extends ChangeNotifier {
  UserResponse? _user;

  UserResponse? get user => _user;
  bool get isAdmin => _user?.roles.any((role) => role.name == 'Admin') ?? false;

  void setUser(UserResponse user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
