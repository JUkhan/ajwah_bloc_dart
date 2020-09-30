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

## 1.0.3

updating doc and param type changed in `select()` function

## 1.5.0

param type changed in dispatch() function and exposed select() and select2() functions into the global scope

## 1.6.0

`T reduce(T state, Action action)` function has been replaced with `Stream<T> mapActionToState(T state, Action action)` into the `BaseState<T>` class.

## 1.7.0

Remove dependency `async`

## 1.8.0

improve performance

## 1.8.1

sync with rxDart version: >=0.23.0

## 1.8.2

update sdk version

## 1.8.3

update sdk version

## 1.8.4

fixed: Prefer using if null operators.
fixed: Omit type annotations for local variables.
fixed: The method dispose should have a return type but doesn't.

## 1.8.5

code refactoring and removed meta dependency

## 1.8.6

added minor functionallty and also select retuen distinct value(s)

## 1.8.7

update api: latestStateValue(BaseState obj)

## 1.8.8

update api: crateStore(...) rerurn Store instance

## 1.8.9

update api: crateStore(...) rerurn Store instance
removed [block] param and added [enableGlobalApi] by default it is `false`. If you pass `true` then global functions like dispatch(), select() etc should be exposed.

## 1.8.10

update api: crateStore(...) rerurn Store instance
removed [block] param and added [enableGlobalApi] by default it is `false`. If you pass `true` then global functions like dispatch(), select() etc should be exposed.
also updated doc

## 1.8.10+1

doc updated

## 1.9.0

expose actions, dispatcher api.
bug fix: some minor bug fixing.

## 1.9.1

refactor createStore() function - all params are optional

## 2.0.0

from 2.0.0 it is totally new style of ajwah_bloc.

## 2.0.0+1

removed: shadowing type parameters.

## 2.0.0+2

fixed: meta version issue

## 2.0.0+3

now you can filter actions when you register state.
store.registerState(filterActions:(action)=>action is TodoAction)

## 2.0.0+4

[filterActions] was missing in global api
registerState(filterActions:(action)=>action is TodoAction)

## 2.0.0+5

- typo and added actions api - where

## 2.0.1

- readme updated

## 2.0.1+1

- readme updated

## 2.0.2

- readme updated
