import 'dart:async';
import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:uuid/uuid.dart';

void main() {
  createStore(exposeApiGlobally: true);
  registerTodoStates();
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: TodoPage(),
    );
  }
}

class TodoPage extends StatefulWidget {
  const TodoPage({Key key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  TextEditingController newTodoController;

  @override
  void initState() {
    newTodoController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    newTodoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const TitleWidget(),
            TextField(
              key: addTodoKey,
              controller: newTodoController,
              decoration: const InputDecoration(
                labelText: 'What needs to be done?',
              ),
              onSubmitted: (value) {
                dispatch(
                    TodoAction(type: TodoActionTypes.add, description: value));
                newTodoController.clear();
              },
            ),
            const SizedBox(height: 42),
            const Toolbar(),
            StreamBuilder<List<Todo>>(
              stream: getFilteredTodos(),
              initialData: [],
              builder: (context, snapshot) {
                final todos = snapshot.data;
                return Column(
                  children: [
                    for (var i = 0; i < todos.length; i++) ...[
                      if (i > 0) const Divider(height: 0),
                      Dismissible(
                        key: ValueKey(todos[i].id),
                        onDismissed: (_) {
                          dispatch(TodoAction(
                              type: TodoActionTypes.remove, id: todos[i].id));
                        },
                        child: TodoItem(
                          //key: Key(todos[i].id),
                          todo: todos[i],
                        ),
                      )
                    ]
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'todos',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Color.fromARGB(38, 47, 47, 247),
        fontSize: 100,
        fontWeight: FontWeight.w100,
        fontFamily: 'Helvetica Neue',
      ),
    );
  }
}

class Toolbar extends StatelessWidget {
  const Toolbar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColorFor(String category, String value) {
      return category == value ? Colors.blue : null;
    }

    final searchCategory$ = select<String>('search-category');
    final activeTodo$ = select<List<Todo>>('todo')
        .map((todos) => todos.where((todo) => !todo.completed).length);

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<int>(
              stream: activeTodo$,
              initialData: 0,
              builder: (context, snapshot) {
                return Expanded(
                  child: Text(
                    '${snapshot.data} items left',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
          Tooltip(
            key: allFilterKey,
            message: 'All todos',
            child: StreamBuilder<String>(
                stream: searchCategory$,
                initialData: '',
                builder: (context, snapshot) {
                  return FlatButton(
                    onPressed: () =>
                        dispatch(TodoFilterAction(type: TodoActionTypes.all)),
                    visualDensity: VisualDensity.compact,
                    textColor: textColorFor(TodoActionTypes.all, snapshot.data),
                    child: const Text('All'),
                  );
                }),
          ),
          Tooltip(
            key: activeFilterKey,
            message: 'Only uncompleted todos',
            child: StreamBuilder<Object>(
                stream: searchCategory$,
                initialData: '',
                builder: (context, snapshot) {
                  return FlatButton(
                    onPressed: () => dispatch(
                        TodoFilterAction(type: TodoActionTypes.active)),
                    visualDensity: VisualDensity.compact,
                    textColor:
                        textColorFor(TodoActionTypes.active, snapshot.data),
                    child: const Text('Active'),
                  );
                }),
          ),
          Tooltip(
            key: completedFilterKey,
            message: 'Only completed todos',
            child: StreamBuilder<Object>(
                stream: searchCategory$,
                initialData: '',
                builder: (context, snapshot) {
                  return FlatButton(
                    onPressed: () => dispatch(
                        TodoFilterAction(type: TodoActionTypes.completed)),
                    visualDensity: VisualDensity.compact,
                    textColor:
                        textColorFor(TodoActionTypes.completed, snapshot.data),
                    child: const Text('Completed'),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class TodoItem extends StatefulWidget {
  final Todo todo;
  TodoItem({Key key, @required this.todo}) : super(key: key);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  FocusNode textFieldFocusNode;
  FocusNode itemFocusNode;
  TextEditingController textEditingController;

  @override
  void initState() {
    textFieldFocusNode = FocusNode();
    itemFocusNode = FocusNode();
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    itemFocusNode.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = widget.todo.description;
          } else {
            dispatch(TodoAction(
                type: TodoActionTypes.update,
                id: widget.todo.id,
                description: textEditingController.text));
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          leading: Checkbox(
              value: widget.todo.completed,
              onChanged: (value) => dispatch(TodoAction(
                  type: TodoActionTypes.toggle, id: widget.todo.id))),
          title: itemFocusNode.hasFocus
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              : Text(widget.todo.description),
        ),
      ),
    );
  }
}

// model and states

var _uuid = Uuid();

/// A read-only description of a todo-item
class Todo {
  Todo({
    this.description,
    this.completed = false,
    String id,
  }) : id = id ?? _uuid.v4();

  final String id;
  final String description;
  final bool completed;

  @override
  String toString() {
    return 'Todo(description: $description, completed: $completed)';
  }
}

/// Some keys used for widget testing
final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

class TodoAction extends Action {
  String description;
  String id;
  TodoAction({
    @required String type,
    this.id,
    this.description,
  }) : super(type: type);
}

class TodoFilterAction extends Action {
  TodoFilterAction({@required String type}) : super(type: type);
}

abstract class TodoActionTypes {
  static const all = 'todo-all';
  static const active = 'todo-active';
  static const completed = 'todo-completed';
  static const add = 'todo-add';
  static const update = 'todo-update';
  static const toggle = 'todo-toggle';
  static const remove = 'todo-remove';
}

void registerTodoStates() {
  //register [todo] state
  registerState<List<Todo>>(
    stateName: 'todo',
    initialState: [
      Todo(id: 'todo-0', description: 'hi'),
      Todo(id: 'todo-1', description: 'hello'),
      Todo(id: 'todo-2', description: 'learn reactive programming'),
    ],
    mapActionToState: (state, action, emit) {
      if (action is TodoAction) {
        switch (action.type) {
          case TodoActionTypes.add:
            emit([...state, Todo(description: action.description)]);
            break;
          case TodoActionTypes.update:
            emit([
              for (var item in state)
                if (item.id == action.id)
                  Todo(
                      id: item.id,
                      completed: item.completed,
                      description: action.description)
                else
                  item,
            ]);
            break;
          case TodoActionTypes.toggle:
            emit([
              for (var item in state)
                if (item.id == action.id)
                  Todo(
                      id: item.id,
                      completed: !item.completed,
                      description: item.description)
                else
                  item,
            ]);
            break;
          case TodoActionTypes.remove:
            emit(state.where((item) => item.id != action.id).toList());
            break;
        }
      }
    },
  );

//register [search-category] state
  registerState<String>(
    stateName: 'search-category',
    initialState: TodoActionTypes.all,
    mapActionToState: (state, action, emit) {
      if (action is TodoFilterAction) {
        emit(action.type);
      }
    },
  );
}

Stream<List<Todo>> getFilteredTodos() => storeInstance().selectMany((state) {
      final todos = ['todo'] as List<Todo>;
      switch (state['search-category']) {
        case TodoActionTypes.active:
          return todos.where((todo) => !todo.completed).toList();
        case TodoActionTypes.completed:
          return todos.where((todo) => todo.completed).toList();
        default:
          return todos;
      }
    });
