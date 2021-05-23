## 2.6.5

- Updated remotData functions

## 2.6.4

introduce a new function: Stream<S> remoteStream<Controller, S>()

## 2.6.3

bug fixing for:  
Stream<Controller> remoteController<Controller>()
Future<State> remoteState<Controller, State>()

## 2.6.2

Added new functions:  
Stream<Controller> remoteController<Controller>()
Future<State> remoteState<Controller, State>()

## 2.6.1

updated readme file

## 2.6.0

removed remoteState<Controller, State>() function, initialState props

## 2.5.0

brought dispatch and action$ props into StateController class and some functiioon signature changed - onAction etc.

## 2.4.0

Removed stateName props from StateController class. Now state should be identified by the StateController Type when you call remoteState<ControllerType, Model>() method.
