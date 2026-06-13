import 'package:firebase_core/firebase_core.dart';
import 'package:injectable/injectable.dart';

import '../../firebase_options.dart';

@lazySingleton
class FirebaseService {
  Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}