import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

import '../../firebase_options.dart';

@lazySingleton
class FirebaseService {
  Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    if (!DefaultFirebaseOptions.isConfigured) {
      throw StateError(
        'Firebase is not configured. Run `flutterfire configure` and update '
        'lib/firebase_options.dart before running the production app.',
      );
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
