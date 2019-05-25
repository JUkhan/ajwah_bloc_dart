import 'package:ajwah_bloc/ajwah_bloc.dart';
import 'package:ajwah_block_examples/todo/store/TodoState.dart';
import 'package:flutter_web/material.dart';

class TodoError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: store()
          .select<TodoModel>(stateName: 'todo')
          .map((tm) => tm.message)
          .distinct(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return AnimatedOpacity(
            opacity: snapshot.data.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              alignment: FractionalOffset.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Container(
                    padding: new EdgeInsets.only(top: 16.0),
                    child: Text(
                      snapshot.data,
                      style: new TextStyle(
                        color: Colors.red[300],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
