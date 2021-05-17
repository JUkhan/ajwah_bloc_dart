import 'dart:js';

import '../widgets/StreamConsumer.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';

import '../states/counter.dart';
import './nav.dart';

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final csCtl = Get.find<CounterState>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Counter'),
        actions: nav(),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => csCtl.inc(),
                child: const Text('Inc'),
              ),
              ElevatedButton(
                onPressed: () => csCtl.dec(),
                child: const Text('Dec'),
              ),
              ElevatedButton(
                onPressed: () => csCtl.asyncInc(),
                child: const Text('Async Inc'),
              ),
            ],
          ),
          StreamConsumer<Counter>(
            stream: csCtl.stream$,
            builder: (context, counter) => Container(
              height: 50,
              child: counter.loading
                  ? CircularProgressIndicator()
                  : Text(
                      '${counter.count}',
                      style: Theme.of(context).textTheme.headline4,
                    ),
            ),
          )
        ],
      )),
    );
  }
}
