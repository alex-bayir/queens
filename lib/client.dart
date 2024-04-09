import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queens/base/base_extensions.dart';
import 'package:queens/game/auto_gamer.dart';
import 'package:queens/game/desk.dart';
import 'package:queens/game/desk_widget.dart';
import 'package:queens/game/qame_protocol.dart';
import 'package:queens/game/queen.dart';

class Client extends StatefulWidget {
  final String title;
  final ServerSocket server;
  final int id;
  final Map<String,int> clients;
  const Client({super.key, required this.title, required this.server, required this.id, this.clients=const {}});
  

  @override
  State<Client> createState() => ClientState();
}

class ClientState extends State<Client> {

  static const Duration timeout=Duration(seconds: 2);
  
  final Desk desk=Desk({});
  final Random random=Random();
  final Map<String,Socket> clients={};
  final Map<Socket,StreamSubscription> subscriptions={};
  final ValueNotifier<int> gamers_hash=ValueNotifier(0);
  Map<String,int> gamers={};
  late final AutoGamer auto;
  String text='';

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }

  void addLog(String text){
    setState(() {this.text='${now()}: $text\n\n${this.text}';});
  }

  void walk([int? id]){
    Future.delayed(timeout,(){
      addLog('auto game was started ${id ?? widget.id}');
      auto.set_current_player(id ?? widget.id);
    });
  }

  void Function(dynamic) answer_sender(Socket client)=>(event) {
    final string=(event as Uint8List).string;
    //addLog('${client.remoteAddress.address}: $string');
    final map=string.decoded;
    if(!GameProtocol.answer(map, client, desk, widget.id, auto)){
      addLog('this: not answered on: $string');
    }
    if(map is Map<String,dynamic> && map[GameProtocol.action]!=GameProtocol.change_current_player){
      final data=map[GameProtocol.data];
      if(data[GameProtocol.priority] is int){
        gamers["${client.remoteAddress.address}:${client.port}"]=data[GameProtocol.priority];
        gamers_hash.value=gamers.toString().hashCode;
      }
    }
  };
  
  @override
  void initState() {
    auto=AutoGamer(widget.id, desk, answer_sender, subscriptions);
    if(widget.id==0){
      desk.set(widget.id, Queen(widget.id));
    }else{
      gamers=widget.clients;
      Future.wait(
        widget.clients.keys
        .map((e) => e.split(':'))
        .map((e) => Socket.connect(e[0], int.parse(e[1]), timeout: timeout))
      ).then((value) {
        clients.addAll(value.toMap((e) => e.address.address, (e) => e));
        subscriptions.addAll(value.toMap((e)=>e, (e)=>e.listen((event) { })));
        GameProtocol.join(subscriptions, desk, widget.id).then((value){
          setState(() {
            desk.set(value[GameProtocol.position], Queen(widget.id));
          });
          subscriptions.forEach((key, value) {
            value.onData(answer_sender(key));
          });
          if(value[GameProtocol.attack]==true){
            walk();
          }
        });
      });
    }
    gamers["${widget.server.address.address}:${widget.server.port}"]=widget.id;
    gamers_hash.value=gamers.toString().hashCode;
    widget.server.listen((client) {
      clients[client.remoteAddress.address]=client;
      subscriptions[client]=client.listen(answer_sender(client));
      addLog('${client.remoteAddress.address} was connected');
    },onDone: () {
      
    },onError: (error){
      print("On Error:");
      print(error);
    });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if(didPop){
          widget.server.close();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title, textScaler: const TextScaler.linear(0.75)),
          actions: [
            IconButton(
              onPressed: qr,
              icon: const Icon(Icons.qr_code_2)
            )
          ]
        ),
        body: Column(
          children: [
            DeskWidget(
              desk: desk,
              enable: (row,col)=>col==widget.id,
              action: (row, col) {
                final figure=desk.figures[widget.id];
                if(figure!=null && figure.can_move(row, col, desk.position(figure).$1, desk.position(figure).$2)){
                  GameProtocol.try_goto(answer_sender,subscriptions, desk, widget.id, desk.convert(row, col)).then((value){
                    if(value[GameProtocol.allow]){
                      setState(() {
                        desk.set(desk.convert(row, col),figure);
                      });
                      if(value[GameProtocol.attack]){
                        GameProtocol.change_player(answer_sender, subscriptions, gamers.where((key, value) => value>widget.id).values.firstOrNull ?? 0);
                      }
                    }
                  });
                }
              }
            ),
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(text, textAlign: TextAlign.start)
                )
              )
            )
          ]
        )
      )
    );
  }

  void qr(){
    showDialog(
      context: context,
      builder: (context)=>ValueListenableBuilder(
        valueListenable: gamers_hash,
        builder: (context,value,_)=> Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints)=>Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(constraints.biggest.shortestSide/400*16))
                ),
                child: QrImageView(data: gamers.encoded)
              )
            )
          )
        )
      )
    );
  }
}

Map<String,int> decode_qr_data(dynamic decoded){
  return (decoded is Map<String,dynamic>) ? decoded.whereType<String,int>() : decoded is String ? decode_qr_data(decoded.decoded) : {};
}
String now([String format='hh:mm:ss'])=>DateFormat(format).format(DateTime.now());