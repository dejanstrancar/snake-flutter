import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

import 'package:flutter/services.dart';

void main() => runApp(Snake());

class Snake extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home:SnakeGame()
    );
  }
}

class SnakeGame extends StatefulWidget{
  @override
  _SnakeGameState createState() =>_SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame>{
  final int squaresPerRow=40;
  final int squaresPerCol=80;
  final fontStyle = const TextStyle(color:Colors.white, fontSize:20);
  final randomGen = Random();

  var snake = [[0,1], [0,0]];
  var food = [0,2];
  var direction = 'up';
  var isPlaying = false;

  void startGame(){
    const duration = Duration(milliseconds: 100);
    snake = [
      [
        (squaresPerRow/2).floor(), (squaresPerCol/2).floor()
      ]
    ];

    for(var i=-1;i>-2;i--){
      snake.add([snake.first[0], snake.first[1]-i]);
    }
    
    createFood();

    isPlaying = true;

    Timer.periodic(duration, (Timer timer) {
      moveSnake();
      if(checkGameOver()){
        timer.cancel();
        endGame();
      }
    });
  }

  void moveSnake(){
    setState((){
      switch(direction){
        case "up":
          snake.insert(0,[snake.first[0], snake.first[1] - 1]);
          break;
        case "down":
          snake.insert(0,[snake.first[0], snake.first[1] + 1]);
          break;
        case "left":
          snake.insert(0,[snake.first[0] - 1, snake.first[1]]);
          break;
        case "right":
          snake.insert(0,[snake.first[0] + 1, snake.first[1]]);
          break;
      }

      if(snake.first[0]!=food[0] || snake.first[1] != food[1]){
        snake.removeLast();
      }else{
        createFood();
      }
    });
  }

  void createFood(){
    food = [
      randomGen.nextInt(squaresPerRow),
      randomGen.nextInt(squaresPerCol)
    ];
  }

  bool internalCollision(){
    var duplicates = 0;
    
    for(var element in snake){
      if(element[0] == snake.first[0] && element[1] == snake.first[1]){
        duplicates++;
      }
    }
    
    return duplicates>1;
  }

  bool horizontalLimits(){
    return (snake.first[1] < 0) || (snake.first[1] > squaresPerCol);
  }
  bool verticalLimits(){
    return (snake.first[0] < 0) || (snake.first[0] > squaresPerRow);
  }

  bool checkGameOver(){
    if(
      !isPlaying
      || horizontalLimits()
      || verticalLimits()
      || internalCollision()
    ){
      return true;
    }

    for(var i=1; i < snake.length; ++i){
      if(snake[1][0] == snake.first[0] && snake[1][1] == snake.first[1]){
        return true;
      }
    }

    return false;
  }

  void endGame(){
    isPlaying=false;

    showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Game over"),
          content: Text(
            'Score: ${snake.length - 2}',
            style: const TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              }, 
              child: const Text("Close"))
          ]
        );
      }
    );
  }

  void keyGestures(RawKeyEvent event){
    if(event.isKeyPressed(LogicalKeyboardKey.arrowDown)){
      if(direction!="up"){
        direction = "down";
      }
    }
    if(event.isKeyPressed(LogicalKeyboardKey.arrowUp)){
      if(direction!="down"){
        direction = "up";
      }
    }
    if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft)){
      if(direction!="right"){
        direction = "left";
      }
    }
    if(event.isKeyPressed(LogicalKeyboardKey.arrowRight)){
      if(direction!="left"){
        direction = "right";
      }
    }
  }

  void leftRightTouchGestures(details){
    if(direction!="left" && details.delta.dx > 0){
      direction = "right"; 
    }else if(direction != "right" && details.delta.dx <0){
      direction = "left";
    }
  }

  void upDownTouchGestures(details){
    if(direction!="up" && details.delta.dy > 0){
      direction = "down"; 
    }else if(direction != "down" && details.delta.dy <0){
      direction = "up";
    }
  }

  Container itemBuilder(BuildContext context, int index){
    var color = Colors.grey[800];
    var x = index % squaresPerRow;
    var y = (index/squaresPerRow).floor();

    bool isSnakeBody = false;
    for (var pos in snake){
      if(pos[0] == x && pos[1]==y){
        isSnakeBody= true;
        break;
      }
    }

    if (snake.first[0]==x && snake.first[1]==y){
      color = Colors.green;
    }else if(isSnakeBody){
      color=Colors.green[200];
    }else if(food[0]==x&&food[1]==y){
      color=Colors.red;
    }else {
      color = Colors.grey[800];
    }
    
    return Container (
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color:color,
        shape:BoxShape.rectangle,
      )
    );
  }

  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Colors.black,
      body:Column(
        children:<Widget>[
          Expanded(
            child: RawKeyboardListener(
              focusNode:FocusNode(),
              onKey: keyGestures,
              child:GestureDetector(
                onVerticalDragUpdate: upDownTouchGestures,
                onHorizontalDragUpdate: leftRightTouchGestures,
                child:AspectRatio(
                  aspectRatio: squaresPerRow/(squaresPerCol+5),
                  child: GridView.builder(
                    itemCount: squaresPerRow*squaresPerCol,
                    itemBuilder: itemBuilder,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:squaresPerRow
                    ),
                  ),
                )
              )
            )
          ),
          Padding(
            padding: const EdgeInsets.only(bottom:20), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  style:TextButton.styleFrom(
                    backgroundColor: isPlaying ? Colors.red : Colors.blue,
                  ),
                  child: Text(isPlaying?"End":"Start",style: fontStyle),
                  onPressed: (){
                    if(isPlaying){
                      isPlaying = false;
                    }else{
                      startGame();
                    }
                  },
                ),
                Text(
                  'Score ${snake.length -2}',
                  style:fontStyle
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}