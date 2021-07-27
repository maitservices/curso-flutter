import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      title: "Contador de Pessoas",
      home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _pessoas = 0;
  String _infoTexto = "Pode Entrar";
  void _contarPessoas(int quantidade){
    setState(() {
      _pessoas+=quantidade;
      if(_pessoas<0){
        _pessoas=0;
      }else if(_pessoas>10){
        _infoTexto = "Lotado";
      }else{
        _infoTexto = "Pode Entrar";
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset("imagens/restaurant.jpg",
          fit: BoxFit.cover,
          height:1000.0 ,),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Pessoas: $_pessoas",
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text(
                      "+1",
                      style: TextStyle(fontSize: 40.0, color: Colors.white),
                    ),
                    onPressed: () {
                      debugPrint("+1");
                      _contarPessoas(1);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text(
                      "-1",
                      style: TextStyle(fontSize: 40.0, color: Colors.white),
                    ),
                    onPressed: () {
                      debugPrint("-1");
                      _contarPessoas(-1);
                    },
                  ),
                ),

              ],
            ),
            Text(_infoTexto,
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 30.0)),
          ],
        )
      ],
    );
  }
}
