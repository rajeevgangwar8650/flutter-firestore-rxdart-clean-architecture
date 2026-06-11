import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/ui/dashboard_page.dart';
import '../../features/home/presentation/ui/home_page.dart';
import '../../features/todo/domain/entities/todo_entity.dart';
import '../../features/todo/presentation/bloc/todo_bloc.dart';
import '../../features/todo/presentation/ui/add_todo_page.dart';
import '../../features/todo/presentation/ui/edit_todo_page.dart';
import '../../features/todo/presentation/ui/todo_page.dart';
import '../di/injection_container.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
      case AppRoutes.todo:
        return MaterialPageRoute(builder: (_) => const TodoPage());
      case AppRoutes.addTodo:
        return MaterialPageRoute(
          builder: (_) => AddTodoPage(bloc: injector<TodoBloc>()),
        );
      case AppRoutes.editTodo:
        final todo = settings.arguments;
        if (todo is TodoEntity) {
          return MaterialPageRoute(
            builder: (_) =>
                EditTodoPage(bloc: injector<TodoBloc>(), todo: todo),
          );
        }
        return _errorRoute('Todo data is required.');
      case AppRoutes.dashboardPage:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case AppRoutes.homePage:
        return MaterialPageRoute(builder: (_) => HomePage());
      default:
        return _errorRoute('Route not found.');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text(message))),
    );
  }
}
