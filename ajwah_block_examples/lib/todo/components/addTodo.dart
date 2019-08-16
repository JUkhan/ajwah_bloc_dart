import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:ajwah_block_examples/store/states/TodoState.dart';
import 'package:flutter_web/material.dart';

class AddTodo extends StatelessWidget {
  final _textController = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) => Row(children: <Widget>[
        Expanded(
            child: TextField(
          autofocus: true,
          controller: _textController,
          decoration: const InputDecoration(
              labelText: 'Add a Todo', contentPadding: EdgeInsets.all(8)),
          onSubmitted: _onTextSubmitted,
        )),
        FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _onTextSubmitted(_textController.text);
          },
        )
      ]);

  void _onTextSubmitted(String value) {
    if (value.isNotEmpty) {
      dispatch(ActionTypes.AddTodo, Todo(completed: false, title: value));
      _textController.clear();
    }
  }
}
