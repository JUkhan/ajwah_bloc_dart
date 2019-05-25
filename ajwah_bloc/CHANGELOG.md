## 0.1.0
Rx based state management library for Dart. Manage your application's states, effects, and actions easy way.

## 0.1.1
Fix lib/src/effectSubscription.dart. (-0.50 points)

Analysis of lib/src/effectSubscription.dart reported 1 hint:

line 10 col 19: The class 'Stream' was not exported from 'dart:core' until version 2.1, but this code is required to be able to run on earlier versions.

## 1.0.0
added testing and update doc

## 1.0.1
Fix lib/src/storeHelper.dart. (-0.50 points)

Analysis of lib/src/storeHelper.dart reported 1 hint:

line 39 col 19: Avoid empty catch blocks.

## 1.0.2
Added **select2(...)** method. This method takes a callback which has a single **Map<String, dynamic>** type arg.
If you pass Map key as a state name then you will get corresponding model instance
as value.
  
**Example**
```dart
final _message$ = store()
    .select2<TodoModel>((states) => states['todo'])
    .map((tm) => tm.message)
    .distinct();
 ```