import 'dart:async';
import 'dart:ui';

class Debouncer{
  final int milliseconds;
  Timer? timer;

  Debouncer({ required this.milliseconds, this.timer});
  run(VoidCallback action){
    timer?.cancel();
    timer = Timer(Duration(milliseconds: milliseconds), action);
  }

}