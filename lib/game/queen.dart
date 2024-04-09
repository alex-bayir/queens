import 'package:queens/game/figure.dart';

class Queen extends Figure{
  Queen(super.priority);
  bool can_move(int nr,int nc,int or,int oc)=>(nr-or).abs()==(nc-oc).abs() || nr-or==0 || nc-oc==0;

  bool can_attack(int pr, int pc, int ar, int ac)=>can_move(ar, ac, pr, pc);

}