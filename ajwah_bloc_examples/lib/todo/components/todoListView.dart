import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_bloc_examples/actionTypes.dart';
import 'package:ajwah_bloc_examples/store/states/TodoState.dart';
import 'package:flutter/material.dart';

class TodoListView extends StatelessWidget {
  TodoListView({Key key}) : super(key: key);

  final _todoList$ =
      select<TodoModel>('todo').map((todo) => todo.todoList).distinct();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<List<Todo>>(
            stream: _todoList$,
            builder:
                (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
              if (snapshot.hasData) {
                final list = snapshot.data;
                if (list.isEmpty) {
                  dispatch(ActionTypes.LoadingTodos);
                }
                return Expanded(
                    child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, index) {
                          final todo = list[index];
                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            value: todo.completed,
                            onChanged: (value) {
                              todo.completed = value;
                              dispatch(ActionTypes.UpdateTodo, todo);
                            },
                            title: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text(
                                  todo.title,
                                  overflow: TextOverflow.ellipsis,
                                )),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      dispatch(ActionTypes.RemoveTodo, todo),
                                )
                              ],
                            ),
                          );
                        }));
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }));
  }
}
