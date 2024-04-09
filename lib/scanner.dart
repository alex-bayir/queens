import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Scanner extends StatelessWidget{
  const Scanner({super.key});
  @override
  Widget build(BuildContext context) {
    bool exit=false;
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: MobileScanner(
        // fit: BoxFit.contain,
        onDetect: (capture) {
          final data=capture.barcodes.map((e) => e.rawValue).firstWhere((element) => element!=null,orElse: () => null);
          if(data!=null && !exit){
            Navigator.of(context).pop(data); exit=true;
          }
        }
      )
    );
  }
  
}