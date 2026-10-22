import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'services/push_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PvsApp()));
  // In the background, so startup is never delayed (and nothing breaks without a Firebase config).
  unawaited(PushNotifications.start(AppConfig.fromEnvironment()));
}
