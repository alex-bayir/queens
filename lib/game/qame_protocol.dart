import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:queens/base/base_extensions.dart';
import 'package:queens/game/auto_gamer.dart';
import 'package:queens/game/desk.dart';

class GameProtocol {
  static const String type='type';
  static const String request='request';
  static const String response='response';
  static const String action='action';
  static const String data='data';
  static const String can_goto='can goto';
  static const String change_current_player='change player';
  static const String try_join='try join';
  static const String allow='allow';
  static const String priority='priority';
  static const String position='position';
  static const String attack='attack';
  static const String col_attack='col attack';
  static const String row_attack='row attack';

  static Future<Map<String,dynamic>> join(Map<Socket,StreamSubscription> subscriptions, Desk desk, int id) async {
    Map<String,dynamic> answer;
    do{
      answer=await try_goto((socket) => (v){}, subscriptions, desk, id, id);
    }while(answer[allow]!=true);
    return answer;
  }

  static void change_player(void Function(dynamic) Function(Socket) answer_sender,Map<Socket,StreamSubscription> subscriptions, int newid){
    for(var client in subscriptions.keys){
      client.write({
        type:request,
        action:change_current_player,
        data:{
          priority:newid
        }
      }.encoded);
    }
  }

  static Future<Map<String,dynamic>> try_goto(void Function(dynamic) Function(Socket) answer_sender,Map<Socket,StreamSubscription> subscriptions, Desk desk, int id, int pos) async {
    Completer<Map<String,dynamic>> completer=Completer();
    final Map<int,Map<String,dynamic>> answers={};
    for(var client in subscriptions.keys){
      subscriptions[client]?.onData((event) {
        answer_sender(client)(event);
        final answer=(event as Uint8List).string.decoded;
        if(answer is Map<String,dynamic>){
          if(answer[type]==response && answer[action]==can_goto && answer[data][position]==pos){
            answers[answer[data][priority]]=answer[data];
            if(answers.length==subscriptions.length){
              subscriptions.values.map((e) => e.cancel());
              completer.complete({
                position:pos,
                allow:!answers.values.any((e) => e[allow]==false),
                attack:answers.values.any((e) => e[attack]==true),
                col_attack:answers.values.any((e) => e[col_attack]==true),
                row_attack:answers.values.any((e) => e[row_attack]==true),
              });
            }
          }
        }
      });
      client.write({
        type:request,
        action:can_goto,
        data:{
          priority:id,
          position:pos
        }
      }.encoded);
    }
    return completer.future;
  }


  static bool answer(dynamic event, Socket client, Desk desk, int id, AutoGamer auto){
    if(event is Map<String,dynamic>){
      if(event[type]==request){
        switch(event[action]){
          case can_goto:
          client.write({
            type:response,
            action:event[action],
            data:{
              priority:id,
              position:event[data][position],
              allow:desk.priorities[id]!=event[data][position],
              attack:desk.can_attack(desk.figures[id]!, event[data][position]),
              col_attack:desk.can_attack_vertical(desk.figures[id]!, event[data][position]),
              row_attack:desk.can_attack_horizontal(desk.figures[id]!, event[data][position])
            }
          }.encoded);
          return true;
          case change_current_player:
            auto.set_current_player(event[data][priority]);
          return true;
        }
      }else{
        
      }
    }
    return false;
  }
}