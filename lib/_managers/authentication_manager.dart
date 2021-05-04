import 'dart:async';

import 'package:donation_tracker/_managers/donation_manager.dart';
import 'package:donation_tracker/_managers/donation_manager_logged_in.dart';
import 'package:donation_tracker/_services/nhost_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:functional_listener/functional_listener.dart';
import 'package:get_it/get_it.dart';

class LoginCredentials {
  final String name;
  final String pwd;

  LoginCredentials(this.name, this.pwd);
}

class AuthenticationManager {
  late final ValueListenable<void> loginStateChanged;

  late final Command<LoginCredentials, void> loginCommand;
  late final Command<void, void> logoutCommand;

  AuthenticationManager() {
    loginCommand = Command.createAsyncNoResult((x) => loginUser(x.name, x.pwd));
    logoutCommand = Command.createAsyncNoParamNoResult(() => logout());

    loginStateChanged = loginCommand.mergeWith([logoutCommand]);

    loginCommand.thrownExceptions.listen((ex, _) => print(ex.toString()));
  }

  Future<void> loginUser(String userName, String pwd) async {
    if (await GetIt.I<NhostService>().loginUser(userName, pwd)) {
      GetIt.I.pushNewScope(scopeName: 'logged In');

      GetIt.I.registerSingleton(NhostService(true));
      GetIt.I<NhostService>();
      GetIt.I.registerSingleton<DonationManager>(DonationManagerLoggedIn());
    }
  }

  Future<void> logout() async {
    await GetIt.I.popScope();
  }
}
