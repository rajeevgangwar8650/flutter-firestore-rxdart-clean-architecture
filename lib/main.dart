import 'package:flutter/material.dart';
import 'app.dart';
import 'config/di/injection_container.dart' as di;
import 'core/services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.injector<FirebaseService>().initialize();
  await di.initDependencies();
  runApp(const App());
}
