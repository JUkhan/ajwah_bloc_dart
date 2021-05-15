import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/instance_manager.dart';

import '../hooks/useMonoStream.dart';
import '../states/searchCategory.dart';
import '../states/todo.dart';

class Toolbar extends HookWidget {
  const Toolbar();

  @override
  Widget build(BuildContext context) {
    final tsCtrl = Get.find<TodoState>();
    final scCtrl = Get.find<SearchCategoryState>();
    final sc = useMonoStream(scCtrl.stream$, scCtrl.state).value;

    final activeTodosInfo = useMonoStream(tsCtrl.activeTodosInfo$, '').value;

    return Material(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              activeTodosInfo,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Tooltip(
              message: 'All todos',
              child: TextButton(
                onPressed: () => scCtrl.setCategory(SearchCategory.All),
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.comfortable,
                    primary: textColorFor(SearchCategory.All, sc)),
                child: const Text('All'),
              )),
          Tooltip(
              message: 'Only uncompleted todos',
              child: TextButton(
                onPressed: () => scCtrl.setCategory(SearchCategory.Active),
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.comfortable,
                    primary: textColorFor(SearchCategory.Active, sc)),
                child: const Text('Active'),
              )),
          Tooltip(
              message: 'Only completed todos',
              child: TextButton(
                onPressed: () => scCtrl.setCategory(SearchCategory.Completed),
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.comfortable,
                    primary: textColorFor(SearchCategory.Completed, sc)),
                child: const Text('Complete'),
              )),
        ],
      ),
    );
  }

  Color? textColorFor(
      SearchCategory btnCategory, SearchCategory selectedCategory) {
    return btnCategory == selectedCategory ? Colors.blue : Colors.black;
  }
}
