import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:queens/base/base_extensions.dart';
import 'package:queens/game/desk.dart';
import 'package:queens/game/qame_protocol.dart';

class AutoGamer{
  int current=0;
  final int id;
  final Desk desk;
  final void Function(dynamic) Function(Socket) answer_sender;
  final Map<Socket, StreamSubscription<dynamic>> subscriptions;
  AutoGamer(this.id,this.desk,this.answer_sender,this.subscriptions);

  Map<String, dynamic> answer={};
  int drow=1;
  int moves=0;

  void change_player(int newid){
    GameProtocol.change_player(answer_sender,subscriptions,newid);
  }
 
  bool set_current_player(int current){
    this.current=current;
    if(id==current){
      final figure=desk.figures[id]!;
      final (row,col)=desk.position(figure);
      Future.delayed(Duration(milliseconds: 1000),()=>GameProtocol.try_goto(answer_sender,subscriptions, desk, id, desk.convert(row, col)).then((value) {
        if(value[GameProtocol.attack]){
          play();
        }else{
          change_player(this.current=(id+1)%(subscriptions.length+1));
        }
      })); 
    }
    return id==current;
  }

  Future play() async {
    while(await Future.delayed(const Duration(milliseconds: 1000),try_go)>=0){
      
    }
  }

  Future<int> try_go() async {
    if(id!=current){return -1;}
    final figure=desk.figures[id];
    if(figure==null){return -1;}
    var (row,col)=desk.position(figure);
    
    if(answer.isNotEmpty){
      if(answer[GameProtocol.allow]){
        if(answer[GameProtocol.attack]==false){
          GameProtocol.change_player(answer_sender,subscriptions,current=(current+1)%(subscriptions.length+1)); answer={};
          return -1;
        }else if(moves<=0){
          drow=answer[GameProtocol.row_attack] ? drow : 0;
          moves=8;
          GameProtocol.change_player(answer_sender,subscriptions,current=(current+1)%(subscriptions.length+1)); answer={};
          return -1;
        }
      }else{
        if(answer[GameProtocol.position]!=null){
          final (frow,fcol)=desk.unconvert(answer[GameProtocol.position]);
          drow=(fcol-col).normalize();
        }
      }
    }
    if(drow==0){
      drow=Random().nextBool() ? 1 : -1;
    }

    if(!(row+drow).between(-1, desk.rows)){
      drow=-drow;
    }
    row=row+drow;

    return GameProtocol.try_goto(answer_sender,subscriptions, desk, id, desk.convert(row, col)).then((value) {
      answer=value; moves--;
      if(value[GameProtocol.allow]){
        desk.set(desk.convert(row, col),figure);
        return 1;
      }else{
        return 0;
      }
    });
  }
}