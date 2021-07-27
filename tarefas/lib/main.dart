import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _tarefasList = [];
  final _tarefaController = TextEditingController();
  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPosition;

  @override
  void initState() {
    super.initState();
    _readDados().then((value) {
      setState(() {
        _tarefasList = json.decode(value);
      });
    });
  }

  void _addTarefa() {
    setState(() {
      Map<String, dynamic> newTarefas = Map();
      newTarefas["titulo"] = _tarefaController.text;
      _tarefaController.text = "";
      newTarefas["ok"] = false;
      _tarefasList.add(newTarefas);
      _saveData();
    });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _tarefasList.sort((a,b){
        if(a["ok"] && !b["ok"]) return 1;
        if(!a["ok"] && b["ok"]) return -1;
        else return 0;
      });
      _saveData();
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _tarefaController,
                    decoration: InputDecoration(
                        labelText: "Nova tarefa",
                        labelStyle: TextStyle(color: Colors.blueAccent)),
                  ),
                ),
                RaisedButton(
                  onPressed: _addTarefa,
                  color: Colors.blueAccent,
                  child: Text("ADD"),
                  textColor: Colors.white,
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _tarefasList.length,
                itemBuilder: buildItem),
                onRefresh: _refresh
            )
          )
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_tarefasList[index]["titulo"]),
        value: _tarefasList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_tarefasList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (change) {
          setState(() {
            _tarefasList[index]["ok"] = change;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_tarefasList[index]);
          _lastRemovedPosition = index;
          _tarefasList.removeAt(index);
          _saveData();

          final snack = SnackBar(
              content:
                  Text("Tarefa \" ${_lastRemoved["titulo"]} \" removida!"),
              action: SnackBarAction(label: "Desfazer",
              onPressed: (){
                setState(() {
                  _tarefasList.insert(_lastRemovedPosition, _lastRemoved);
                  _saveData();
                });

              },
              ),
            duration: Duration(seconds: 8),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/data.json");
  }

  Future<File> _saveData() async {
    String dados = json.encode(_tarefasList);
    final file = await _getFile();
    return file.writeAsString(dados);
  }

  Future<String> _readDados() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
