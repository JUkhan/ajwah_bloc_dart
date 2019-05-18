import 'package:ajwah_block_examples/todo/components/addTodo.dart';
import 'package:ajwah_block_examples/todo/components/todoError.dart';
import 'package:ajwah_block_examples/todo/components/todoListView.dart';
import 'package:flutter_web/material.dart';
import '../../widgets/popupMenu.dart';

class TodoContainer extends StatelessWidget {
  const TodoContainer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo'),
        actions: <Widget>[PopupMemu()],
      ),
      body: Container(
        width: 550.0,
        margin: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10.0),
        child: Center(
          child: Column(
            children: <Widget>[
              TodoError(),
              AddTodo(),
              TodoListView(),
            ],
          ),
        ),
      ),
    );
  }
}
