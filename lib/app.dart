import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config/routes/route_generator.dart';
import 'core/theme/app_theme.dart';

class App extends StatefulWidget {
  final GoRouter? router;

  const App({super.key, this.router});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;
  late final bool _ownsRouter;

  @override
  void initState() {
    super.initState();
    _ownsRouter = widget.router == null;
    _router = widget.router ?? RouteGenerator.createRouter();
  }

  @override
  void dispose() {
    if (_ownsRouter) {
      _router.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Todo CRUD',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
