import 'package:flutter/foundation.dart';
import 'package:melo_desktop/models/user_response.dart';

class UserProvider extends ChangeNotifier {
  UserResponse? _user;

  UserResponse? get user => _user;

  void setUser(UserResponse user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
