import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/actionTypes.dart';
import 'package:flutter_web/material.dart';

class PopupMemu extends StatelessWidget {
  const PopupMemu({Key key}) : super(key: key);

  menuSelect(BuildContext context, String path) {
    if (path == '/todo') {
      dispatch(actionType: ActionTypes.LoadingTodos);
    }
    Navigator.pushReplacementNamed(context, path);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) {
        menuSelect(context, value);
      },
      itemBuilder: (ctx) => [
            PopupMenuItem(
              value: '/',
              child: ListTile(
                title: Text('Counter'),
              ),
            ),
            PopupMenuItem(
              value: '/search',
              child: ListTile(
                title: Text('Search'),
              ),
            ),
            PopupMenuItem(
              value: '/todo',
              child: ListTile(
                title: Text('Todo'),
              ),
            )
          ],
    );
  }
}