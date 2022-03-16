import 'package:mighty_delivery/main/utils/Constants.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store{

  @observable
  bool isLoading = false;

  @observable
  bool isLoggedIn = false;

  @observable
  String userEmail = '';

  @observable
  int allUnreadCount = 0;

  @action
  Future<void> setLoading(bool val) async {
    isLoading = val;
  }

  @action
  Future<void> setLogin(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (!isInitializing) await setValue(IS_LOGGED_IN, val);
  }

  @action
  Future<void> setUserEmail(String val, {bool isInitialization = false}) async {
    userEmail = val;
  }

  @action
  Future<void> setAllUnreadCount(int val) async {
    allUnreadCount = val;
  }
}