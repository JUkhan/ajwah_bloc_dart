import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/instance_manager.dart';

import '../states/todo.dart';

class AddTodo extends HookWidget {
  const AddTodo();

  @override
  Widget build(BuildContext context) {
    final newTodoController = useTextEditingController();
    final tsCtrl = Get.find<TodoState>();
    final isSearchEnable = useState(false);

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              onChanged: (txt) {
                if (isSearchEnable.value)
                  tsCtrl.dispatch(SearchInputAction(txt));
              },
              autofocus: true,
              controller: newTodoController,
              decoration: InputDecoration(
                labelText: isSearchEnable.value
                    ? 'Search Todo'
                    : 'What needs to be done?',
              ),
              onSubmitted: (value) {
                if (!isSearchEnable.value) {
                  tsCtrl.add(value);
                  newTodoController.clear();
                }
              },
            ),
          ),
          FloatingActionButton(
            onPressed: () {
              isSearchEnable.value = !isSearchEnable.value;
              tsCtrl.dispatch(SearchInputAction(''));
              newTodoController.clear();
            },
            child: const Icon(Icons.search),
            mini: true,
          ),
        ],
      ),
    );
  }
}
