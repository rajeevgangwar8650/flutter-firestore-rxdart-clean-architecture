import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'app.dart';
import 'config/di/injection_container.dart' as di;
import 'core/services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await di.initDependencies();
  await di.injector<FirebaseService>().initialize();
  runApp(const App());
}
