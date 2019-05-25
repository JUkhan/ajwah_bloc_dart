import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:ajwah_block_examples/todo/store/TodoState.dart';
import 'package:flutter_web/material.dart';

class TodoListView extends StatelessWidget {
  const TodoListView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: StreamBuilder<List<Todo>>(
            stream: store()
                .select<TodoModel>(stateName: 'todo')
                .map((todo) => todo.todoList)
                .distinct(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
              if (snapshot.hasData) {
                final list = snapshot.data;
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
                              dispatch(
                                  actionType: ActionTypes.UpdateTodo,
                                  payload: todo);
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
                                  onPressed: () => dispatch(
                                      actionType: ActionTypes.RemoveTodo,
                                      payload: todo),
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
