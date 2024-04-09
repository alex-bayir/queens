import 'package:flutter/material.dart';
import 'package:queens/game/desk.dart';
import 'package:queens/game/figure.dart';

class DeskWidget extends StatelessWidget {
  final Desk desk;
  final bool Function(int row,int col) enable;
  final void Function(int row,int col) action;
  const DeskWidget({super.key, required this.desk, required this.enable, required this.action});
  
  @override
  Widget build(BuildContext context) {
    final theme=Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints)=>Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row=0; row<desk.rows; row++) Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var col=0; col<desk.cols; col++)
                cell(desk.get(row,col), enable(row,col) ? ()=>action(row,col) : null, theme.colorScheme.primary, constraints.maxWidth/400*48)
            ]
          )
        ]
      )
    );
  }
}

Widget cell(Figure? figure, void Function()? action, Color active, double size)=>AnimatedSwitcher(
  duration: Durations.long2,
  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation,child: child)),
  child: IconButton(
    key: ValueKey(figure?.priority),
    onPressed: action,
    isSelected: figure!=null,
    padding: EdgeInsets.zero,
    icon: Stack(
      children: [
        Icon(
          size: size,
          figure==null ? Icons.radio_button_off : Icons.radio_button_on,
          color: figure!=null ? active : null
        ),
        Positioned.fill(
          child: Visibility(
            visible: figure!=null,
            child: Center(
              child: Container(
                width: size/2,
                height: size/2,
                alignment: Alignment.center,
                child: Text(
                  figure?.priority.toString() ?? "",
                  textScaler: TextScaler.linear(size/48),
                  style: const TextStyle(color: Color(0xffff0000)),
                )
              )
            )
          )
        )
      ]
    )
  )
);
