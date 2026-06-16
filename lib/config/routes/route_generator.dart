import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/ui/dashboard_page.dart';
import '../../features/home/presentation/ui/home_page.dart';
import '../../features/todo/domain/entities/todo_entity.dart';
import '../../features/todo/presentation/ui/add_todo_page.dart';
import '../../features/todo/presentation/ui/edit_todo_page.dart';
import '../../features/todo/presentation/ui/todo_page.dart';
import 'app_routes.dart';

class RouteGenerator {
  static GoRouter createRouter({String? initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: AppRoutes.splash, redirect: (_, _) => AppRoutes.todo),
        GoRoute(path: AppRoutes.todo, builder: (_, _) => const TodoPage()),
        GoRoute(
          path: AppRoutes.addTodo,
          builder: (context, _) => AddTodoPage(
            onCancel: () => context.replace(AppRoutes.todo),
            onSaved: () => context.replace(AppRoutes.todo),
          ),
        ),
        GoRoute(
          path: AppRoutes.editTodo,
          redirect: (_, state) =>
              state.extra is TodoEntity ? null : AppRoutes.todo,
          builder: (context, state) {
            final todo = state.extra as TodoEntity;
            return EditTodoPage(
              todo: todo,
              onCancel: () => context.replace(AppRoutes.todo),
              onSaved: () => context.replace(AppRoutes.todo),
            );
          },
        ),
        GoRoute(
          path: AppRoutes.dashboardPage,
          builder: (_, _) => const DashboardPage(),
        ),
        GoRoute(path: AppRoutes.homePage, builder: (_, _) => const HomePage()),
      ],
      errorBuilder: (_, _) => _errorPage('Route not found.'),
    );
  }

  static Widget _errorPage(String message) {
    return Scaffold(body: Center(child: Text(message)));
  }
}
