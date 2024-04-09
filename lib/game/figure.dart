import 'package:queens/game/queen.dart';

abstract class Figure{
  final int priority;
  Figure(this.priority);
  bool can_move(int nr,int nc,int or,int oc);
  bool can_attack(int pr, int pc, int ar, int ac);

  @override
  int get hashCode => priority;
  
  @override
  bool operator ==(Object other) {
    return other is Figure && priority==other.priority;
  }

  dynamic serialize()=>priority;

  static Figure? deserialize(dynamic value)=>value is int ? Queen(value) : null;
}