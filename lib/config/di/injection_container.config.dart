// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../core/services/firebase_service.dart' as _i778;
import '../../features/todo/data/datasources/todo_remote_data_source.dart'
    as _i262;
import '../../features/todo/data/repositories/todo_repository_impl.dart'
    as _i767;
import '../../features/todo/domain/repositories/todo_repository.dart' as _i136;
import '../../features/todo/domain/usecases/create_todo_usecase.dart' as _i226;
import '../../features/todo/domain/usecases/delete_todo_usecase.dart' as _i137;
import '../../features/todo/domain/usecases/get_todos_usecase.dart' as _i991;
import '../../features/todo/domain/usecases/update_todo_usecase.dart' as _i135;
import '../../features/todo/presentation/bloc/todo_bloc.dart' as _i453;
import 'firebase_module.dart' as _i616;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i778.FirebaseService>(() => _i778.FirebaseService());
    gh.lazySingleton<_i262.TodoRemoteDataSource>(
      () => _i262.TodoRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i136.TodoRepository>(
      () => _i767.TodoRepositoryImpl(gh<_i262.TodoRemoteDataSource>()),
    );
    gh.lazySingleton<_i226.CreateTodoUseCase>(
      () => _i226.CreateTodoUseCase(gh<_i136.TodoRepository>()),
    );
    gh.lazySingleton<_i137.DeleteTodoUseCase>(
      () => _i137.DeleteTodoUseCase(gh<_i136.TodoRepository>()),
    );
    gh.lazySingleton<_i991.GetTodosUseCase>(
      () => _i991.GetTodosUseCase(gh<_i136.TodoRepository>()),
    );
    gh.lazySingleton<_i135.UpdateTodoUseCase>(
      () => _i135.UpdateTodoUseCase(gh<_i136.TodoRepository>()),
    );
    gh.factory<_i453.TodoBloc>(
      () => _i453.TodoBloc(
        gh<_i226.CreateTodoUseCase>(),
        gh<_i991.GetTodosUseCase>(),
        gh<_i135.UpdateTodoUseCase>(),
        gh<_i137.DeleteTodoUseCase>(),
      ),
    );
    return this;
  }
}

class _$FirebaseModule extends _i616.FirebaseModule {}
