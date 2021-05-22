import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:get/instance_manager.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import '../api/todoApi.dart';
import './searchCategory.dart';

var _uuid = Uuid();

class Todo {
  Todo({
    required this.description,
    this.completed = false,
    String? id,
  }) : id = id ?? _uuid.v4();

  final String id;
  final String description;
  final bool completed;

  Todo copyWith({
    String? id,
    String? description,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      description: description ?? this.description,
      completed: completed ?? this.completed,
    );
  }
}

class TodoState extends StateController<List<Todo>> with GetLifeCycleBase {
  TodoState() : super([]) {
    $configureLifeCycle();
  }

  @override
  void onClose() {
    dispose();
    super.onClose();
  }

  @override
  void onInit() {
    loadTodos();

    registerEffects([
      action$
          .isA<SearchInputAction>()
          .debounceTime(const Duration(milliseconds: 320))
          .map((action) => SearchTodoAction(action.searchText))
    ]);
  }

  void loadTodos() {
    getTodos().listen((todos) {
      emit(todos);
    });
  }

  void add(String description) {
    addTodo(Todo(description: description))
        .listen((todo) => emit([...state, todo]));
  }

  void update(Todo todo) {
    updateTodo(todo).listen(
        (todo) => emit([
              for (var item in state)
                if (item.id == todo.id) todo else item,
            ]), onError: (error) {
      dispatch(TodoErrorAction(error));
    });
  }

  void remove(Todo todo) {
    removeTodo(todo).listen(
        (todo) => emit(state.where((item) => item.id != todo.id).toList()));
  }

  Stream<String> get activeTodosInfo$ => stream$
      .map((todos) => todos.where((todo) => !todo.completed).toList())
      .map((todos) => '${todos.length} items left');

  Stream<List<Todo>> get todo$ =>
      Rx.combineLatest3<List<Todo>, SearchCategory, String, List<Todo>>(
          stream$,
          remoteStream<SearchCategoryState, SearchCategory>(),
          action$
              .isA<SearchTodoAction>()
              .map<String>((action) => action.searchText)
              .doOnData((event) {
            print('searchText: ' + event);
          }).startWith(''), (todos, category, searchText) {
        if (searchText.isNotEmpty)
          todos = todos
              .where((todo) => todo.description
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
              .toList();
        switch (category) {
          case SearchCategory.Active:
            return todos.where((todo) => !todo.completed).toList();
          case SearchCategory.Completed:
            return todos.where((todo) => todo.completed).toList();
          default:
            return todos;
        }
      });
}

class TodoErrorAction extends Action {
  final dynamic error;
  TodoErrorAction(this.error);
}

class SearchTodoAction extends Action {
  final String searchText;
  SearchTodoAction(this.searchText);
}

class SearchInputAction extends Action {
  final String searchText;
  SearchInputAction(this.searchText);
}
