// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppStore on _AppStore, Store {
  final _$isLoadingAtom = Atom(name: '_AppStore.isLoading');

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  final _$isLoggedInAtom = Atom(name: '_AppStore.isLoggedIn');

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  final _$userEmailAtom = Atom(name: '_AppStore.userEmail');

  @override
  String get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  final _$allUnreadCountAtom = Atom(name: '_AppStore.allUnreadCount');

  @override
  int get allUnreadCount {
    _$allUnreadCountAtom.reportRead();
    return super.allUnreadCount;
  }

  @override
  set allUnreadCount(int value) {
    _$allUnreadCountAtom.reportWrite(value, super.allUnreadCount, () {
      super.allUnreadCount = value;
    });
  }

  final _$selectedLanguageAtom = Atom(name: '_AppStore.selectedLanguage');

  @override
  String get selectedLanguage {
    _$selectedLanguageAtom.reportRead();
    return super.selectedLanguage;
  }

  @override
  set selectedLanguage(String value) {
    _$selectedLanguageAtom.reportWrite(value, super.selectedLanguage, () {
      super.selectedLanguage = value;
    });
  }

  final _$isDarkModeAtom = Atom(name: '_AppStore.isDarkMode');

  @override
  bool get isDarkMode {
    _$isDarkModeAtom.reportRead();
    return super.isDarkMode;
  }

  @override
  set isDarkMode(bool value) {
    _$isDarkModeAtom.reportWrite(value, super.isDarkMode, () {
      super.isDarkMode = value;
    });
  }

  final _$isFilteringAtom = Atom(name: '_AppStore.isFiltering');

  @override
  bool get isFiltering {
    _$isFilteringAtom.reportRead();
    return super.isFiltering;
  }

  @override
  set isFiltering(bool value) {
    _$isFilteringAtom.reportWrite(value, super.isFiltering, () {
      super.isFiltering = value;
    });
  }

  final _$setLoadingAsyncAction = AsyncAction('_AppStore.setLoading');

  @override
  Future<void> setLoading(bool val) {
    return _$setLoadingAsyncAction.run(() => super.setLoading(val));
  }

  final _$setLoginAsyncAction = AsyncAction('_AppStore.setLogin');

  @override
  Future<void> setLogin(bool val, {bool isInitializing = false}) {
    return _$setLoginAsyncAction
        .run(() => super.setLogin(val, isInitializing: isInitializing));
  }

  final _$setUserEmailAsyncAction = AsyncAction('_AppStore.setUserEmail');

  @override
  Future<void> setUserEmail(String val, {bool isInitialization = false}) {
    return _$setUserEmailAsyncAction
        .run(() => super.setUserEmail(val, isInitialization: isInitialization));
  }

  final _$setAllUnreadCountAsyncAction =
      AsyncAction('_AppStore.setAllUnreadCount');

  @override
  Future<void> setAllUnreadCount(int val) {
    return _$setAllUnreadCountAsyncAction
        .run(() => super.setAllUnreadCount(val));
  }

  final _$setLanguageAsyncAction = AsyncAction('_AppStore.setLanguage');

  @override
  Future<void> setLanguage(String aCode, {BuildContext? context}) {
    return _$setLanguageAsyncAction
        .run(() => super.setLanguage(aCode, context: context));
  }

  final _$setDarkModeAsyncAction = AsyncAction('_AppStore.setDarkMode');

  @override
  Future<void> setDarkMode(bool aIsDarkMode) {
    return _$setDarkModeAsyncAction.run(() => super.setDarkMode(aIsDarkMode));
  }

  final _$setFilteringAsyncAction = AsyncAction('_AppStore.setFiltering');

  @override
  Future<void> setFiltering(bool val) {
    return _$setFilteringAsyncAction.run(() => super.setFiltering(val));
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
isLoggedIn: ${isLoggedIn},
userEmail: ${userEmail},
allUnreadCount: ${allUnreadCount},
selectedLanguage: ${selectedLanguage},
isDarkMode: ${isDarkMode},
isFiltering: ${isFiltering}
    ''';
  }
}
