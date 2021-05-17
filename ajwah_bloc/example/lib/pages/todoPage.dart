import 'package:example/hooks/useMonoStream.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:get/route_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../widgets/addTodo.dart';

import '../hooks/useNotifier.dart';

import '../states/todo.dart';

import '../widgets/todoItem.dart';
import '../widgets/toolbar.dart';
import '../widgets/title.dart';

class TodoPage extends HookWidget {
  const TodoPage();

  @override
  Widget build(BuildContext context) {
    final tsCtrl = Get.find<TodoState>();

    useNotifier<String>(
        tsCtrl.action$.isA<TodoErrorAction>().map((action) => action.error),
        (error) {
      Get.snackbar('Info', error, colorText: Colors.red);
    });

    final todos = useMonoStream(tsCtrl.todo$, []).value;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Todos'),
          //actions: nav(),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            const TitleWidget(),
            const AddTodo(),
            const SizedBox(height: 42),
            const Toolbar(),
            ...[
              for (var i = 0; i < todos.length; i++) ...[
                if (i > 0) const Divider(height: 0),
                Dismissible(
                  key: ValueKey(todos[i].id),
                  onDismissed: (_) {
                    tsCtrl.remove(todos[i]);
                  },
                  child: TodoItem(
                    //key: Key(todos[i].id),
                    todo: todos[i],
                  ),
                )
              ]
            ],
          ],
        ),
      ),
    );
  }
}
