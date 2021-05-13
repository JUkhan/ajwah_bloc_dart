import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

List<Widget> nav() => [
      ElevatedButton(
        onPressed: () {
          Get.toNamed('/todo');
        },
        child: const Text('Todos'),
      ),
    ];
