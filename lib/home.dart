import 'dart:io';

import 'package:flutter/material.dart';
import 'package:queens/base/base_extensions.dart';
import 'package:queens/client.dart';
import 'package:queens/scanner.dart';

class Home extends StatelessWidget {
  const Home({super.key, required this.title});
  final String title;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title)
      ),
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: (){
                openServerSocket(4080).then((value) => {
                  if(value!=null){
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        barrierDismissible:true,
                        pageBuilder: (BuildContext _, __, ___) => Client(
                          title: "$title - ${value.address.address}:${value.port}",
                          id:0,
                          server: value
                        ),
                        transitionDuration: Durations.long2,
                        reverseTransitionDuration: Durations.long2,
                        transitionsBuilder: (context, fAnimation, sAnimation, child) => FadeTransition(opacity: fAnimation.drive(Tween(begin:0.0,end:1.0)), child: child)
                      )
                    )
                  }
                });
              },
              child: Text('Create game')
            ),
            TextButton(
              onPressed: (){
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    barrierDismissible:true,
                    pageBuilder: (BuildContext _, __, ___) => Scanner(),
                    transitionDuration: Durations.long2,
                    reverseTransitionDuration: Durations.long2,
                    transitionsBuilder: (context, fAnimation, sAnimation, child) => FadeTransition(opacity: fAnimation.drive(Tween(begin:0.0,end:1.0)), child: child)
                  )
                ).then((value){
                  if(value is String){
                    final data=decode_qr_data(value);
                    openServerSocket(4080).then((server) => {
                      if(server!=null){
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            opaque: false,
                            barrierDismissible:true,
                            pageBuilder: (BuildContext _, __, ___) => Client(
                              title: "$title - ${server.address.address}:${server.port}",
                              id:data["${server.address.address}:${server.port}"] ?? data.length,
                              server: server,
                              clients: data.where((key, value) => !key.startsWith(server.address.address))
                            ),
                            transitionDuration: Durations.long2,
                            reverseTransitionDuration: Durations.long2,
                            transitionsBuilder: (context, fAnimation, sAnimation, child) => FadeTransition(opacity: fAnimation.drive(Tween(begin:0.0,end:1.0)), child: child)
                          )
                        )
                      }
                    });
                  }
                });
              },
              child: Text('Connect to game')
            )
          ]
        )
      )
    );
  }
}

Future<ServerSocket?> openServerSocket(int port)=>NetworkInterface.list().then((value){
  for(var interface in value){
    for(var address in interface.addresses){
      if(address.isPrivate){
        return ServerSocket.bind(address.address, port);
      }
    }
  }
  print('No opened network adress');
});