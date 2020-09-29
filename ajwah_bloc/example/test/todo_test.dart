import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_test/ajwah_bloc_test.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  AjwahStore store;
  setUp(() {
    store = createStore(exposeApiGlobally: true);
    registerTodoStates();
  });
  tearDown(() {
    store.dispose();
  });
  ajwahTest<List<Todo>>(
    'Render the default todos',
    build: () => getFilteredTodos(),
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect(3, models[0].length);
    },
  );
  ajwahTest<List<Todo>>(
    'Editing the todo on done',
    build: () => getFilteredTodos(),
    act: () =>
        store.dispatch(TodoAction(type: TodoActionTypes.toggle, id: 'todo-0')),
    skip: 1,
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect(true, models[0][0].completed);
    },
  );
  ajwahTest<List<Todo>>(
    'Add new todo',
    build: () => getFilteredTodos(),
    act: () => store.dispatch(
        TodoAction(type: TodoActionTypes.add, description: 'new todo')),
    skip: 1,
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect('new todo', models[0][3].description);
    },
  );
  ajwahTest<List<Todo>>(
    'removing the first todo',
    build: () => getFilteredTodos(),
    act: () =>
        store.dispatch(TodoAction(type: TodoActionTypes.remove, id: 'todo-0')),
    skip: 1,
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect('todo-1,todo-2', models[0].map((e) => e.id).join(','));
    },
  );

  ajwahTest<List<Todo>>(
    'show only uncomplete todos',
    build: () => getFilteredTodos(),
    act: () {
      store.dispatch(TodoAction(type: TodoActionTypes.toggle, id: 'todo-0'));
      store.dispatch(TodoFilterAction(type: TodoActionTypes.active));
    },
    skip: 2,
    expect: [isA<List<Todo>>()],
    verify: (models) {
      expect(2, models[0].length);
    },
  );
}
