// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_select/material_dropdown_select.dart';

import 'src/services/github_service.dart';
import 'src/services/subscription_service.dart';

const repositoriesWithInstalledHook = ['dart-lang/sdk', 'flutter/flutter'];

@Component(
  selector: 'my-app',
  styleUrls: [
    'package:angular_components/css/mdc_web/card/mdc-card.scss.css',
    'app_component.css',
  ],
  templateUrl: 'app_component.html',
  directives: [
    coreDirectives,
    MaterialAutoSuggestInputComponent,
    MaterialButtonComponent,
    MaterialIconComponent,
    MaterialDropdownSelectComponent,
  ],
  providers: [
    materialProviders,
    ClassProvider(SubscriptionsService),
    ClassProvider(GithubService)
  ],
)
class AppComponent implements OnInit {
  final SubscriptionsService _subscriptionsService;
  final GithubService _githubService;

  /// Current subscriptions grouped by repository name.
  Map<String, List<String>> subscriptions = {};

  /// List of repositories which can be subscribed to.
  List<String> supportedRepositories = repositoriesWithInstalledHook;
  String _selectedRepository = repositoriesWithInstalledHook.first;

  String get selectedRepository => _selectedRepository;
  set selectedRepository(String newValue) {
    if (_selectedRepository != newValue) {
      _selectedRepository = newValue;
      fetchLabelsForSelectedRepository();
    }
  }

  /// List of labels which exist in the currently selected repository.
  List<String> repoLabels = [];
  String selectedLabel = '';

  // Configuration of the keyword subscription to flutter/flutter repository.
  String flutterKeywordLabel = '';
  List<String> flutterKeywords = [];

  AppComponent(this._subscriptionsService, this._githubService);

  @override
  Future<Null> ngOnInit() async {
    _subscriptionsService.onAuth.listen((_) async {
      subscriptions = await _subscriptionsService.getSubscriptions();

      final subscription =
          await _subscriptionsService.getKeywordSubscription('flutter/flutter');
      if (subscription != null) {
        flutterKeywordLabel = subscription.label;
        flutterKeywords = subscription.keywords;
      }
    });
    fetchLabelsForSelectedRepository();
  }

  bool get isLoggedIn => _subscriptionsService.isLoggedIn;

  String get userEmail => _subscriptionsService.userEmail;

  Object trackByKey(int index, dynamic item) {
    return item is MapEntry<String, List<String>> ? item.key : item;
  }

  void toggleLogin() {
    if (!_subscriptionsService.isLoggedIn) {
      _subscriptionsService.logIn();
    }
  }

  void unsubscribeFrom(String repositoryName, String labelName) async {
    await _subscriptionsService.unsubscribeFrom(repositoryName, labelName);
    subscriptions = await _subscriptionsService.getSubscriptions();
  }

  void subscribe() async {
    await _subscriptionsService.subscribeTo(selectedRepository, selectedLabel);
    subscriptions = await _subscriptionsService.getSubscriptions();
  }

  void fetchLabelsForSelectedRepository() {
    final repo = selectedRepository;
    _githubService.listLabels(repo).then((labels) {
      // Only update labels list if selectedRepository is still the same.
      if (selectedRepository == repo) {
        repoLabels = labels;
      }
    });
  }
}
