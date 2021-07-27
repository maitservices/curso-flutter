import 'dart:convert';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null || _search.isEmpty) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=zi4OzUNYw7f2Xz9GSSUJmdcil0y0WBz0&limit=19&rating=g");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=zi4OzUNYw7f2Xz9GSSUJmdcil0y0WBz0&q=$_search&limit=19&offset=$_offset&rating=g&lang=en");
    }
    return json.decode(response.body);
  }

  int _getCount(List data){
    if(_search == null || _search.isEmpty){
        return data.length;
    }else{
      return data.length+1;
    }
  }

  Widget _createGifTable(BuildContext context,AsyncSnapshot snapshot){
      return GridView.builder(
        padding: EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0
          ),
          itemCount: _getCount(snapshot.data["data"]),
          itemBuilder: (contect, index){
            if(_search==null || index < snapshot.data["data"].length){
              return GestureDetector(
                onTap: (){
                  Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>GifPage(snapshot.data["data"][index]))
                  );
                },
                onLongPress: (){
                  Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
                },
                child: Image.network(snapshot.data["data"][index]["images"]["fixed_height"]["url"], height: 300.0, fit:BoxFit.cover ,),
              );
            }else{
              return Container(
                child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.white,size: 70.0,),
                      Text("mais...", style: TextStyle(color: Colors.white,fontSize: 22.0),)
                    ],
                  ),
                  onTap: (){
                    setState(() {
                      _offset+=19;
                    });
                  },
                ),
              );
            }
          });
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black12,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquisar",
                labelStyle: TextStyle(color: Colors.white, fontSize: 25.0),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted:(text){
                setState(() {
                  _search=text;
                  _offset=0;
                });
              } ,
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 5.0,
                          ),
                        );
                      default:
                        if(snapshot.hasError) return Container();
                        else return _createGifTable(context, snapshot);
                    }
            }),
          )
        ],
      ),
    );
  }
}
