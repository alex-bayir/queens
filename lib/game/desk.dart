import 'dart:math';

import 'package:queens/base/base_extensions.dart';
import 'package:queens/game/figure.dart';

class Desk {
  final int cols;
  final int rows;
  Map<int,Figure> positions;

  Desk(this.positions,[this.cols=8,this.rows=8]);

  Map<int,Figure> get figures=>positions.map((key, value) => MapEntry(value.priority, value));

  Map<Figure,int> get reverse=>positions.map((key, value) => MapEntry(value, key));

  Map<int,int> get priorities=>positions.map((key, value) => MapEntry(value.priority, key));

  int convert(int row, int col)=>row*rows+col;

  (int,int) unconvert(int position)=>(position~/rows,position%cols);

  (int,int) position(Figure figure)=>unconvert(reverse[figure]!);

  Figure? get(int row, int col)=>this[convert(row, col)];

  bool set(int position, Figure figure){
    if(this[position]==null){
      positions[position]=positions.remove(reverse[figure]) ?? figure;
      return true;
    }else{
      return false;
    }
  }



  Figure? operator [](int index) => positions[index];

  void operator []=(int index, Figure value) => positions[index]=value;

  int get length => cols*rows;

  dynamic serialize()=>positions.map((key, value) => MapEntry(key, value.serialize()));

  Desk? deserialize(dynamic value) => value is Map ? Desk(
    value.map(
      (key, value) => MapEntry(key is String ? int.parse(key) : key, Figure.deserialize(value))
    ).whereType<int,Figure>()
  ) : null;

  int random_position()=>Random().nextInt(rows*cols);

  bool can_attack(Figure figure, int pos){
    final (row,col)=position(figure);
    final (ar,ac)=unconvert(pos);
    return figure.can_attack(row, col, ar, ac);
  }

  bool can_attack_horizontal(Figure figure, int pos){
    final (row,col)=position(figure);
    final (ar,ac)=unconvert(pos);
    return figure.can_attack(row, col, ar, ac) && row-ar==0;
  }
  bool can_attack_vertical(Figure figure, int pos){
    final (row,col)=position(figure);
    final (ar,ac)=unconvert(pos);
    return figure.can_attack(row, col, ar, ac) && col-ac==0;
  }
}