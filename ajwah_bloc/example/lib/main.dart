import 'package:example/states/counter.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';

import './states/todo.dart';
import './pages/counterPage.dart';
import './pages/todoPage.dart';
import './states/searchCategory.dart';

void main() {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    getPages: [
      GetPage(
          name: '',
          page: () => CounterPage(),
          binding: BindingsBuilder(() {
            Get.put<CounterState>(CounterState());
          })),
      GetPage(
          name: '/todo',
          page: () => TodoPage(),
          transition: Transition.zoom,
          binding: BindingsBuilder(() {
            Get.put<TodoState>(TodoState());
            Get.put<SearchCategoryState>(SearchCategoryState());
          }))
    ],
    initialRoute: '',
    home: CounterPage(),
  ));
}
