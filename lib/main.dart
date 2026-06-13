import 'package:flutter/material.dart';
import 'app.dart';
import 'config/di/injection_container.dart' as di;
import 'core/services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  await di.injector<FirebaseService>().initialize();
  runApp(const App());
}
