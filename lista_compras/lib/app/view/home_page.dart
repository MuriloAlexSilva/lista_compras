import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _listaCompras = jsonDecode(data);
      });
    });
  }

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedPos;
  List _listaCompras = [];
  TextEditingController _itemCompraController = TextEditingController();
  TextEditingController _qtddCompraController = TextEditingController();

  void _addListaCompras() {
    setState(() {
      Map<String, dynamic> newItem = Map();
      newItem["title"] = _itemCompraController.text;
      newItem["quantidade"] = _qtddCompraController.text;
      _itemCompraController.clear();
      _qtddCompraController.clear();
      newItem["ok"] = false;
      _listaCompras.add(newItem);
      _saveData();
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _listaCompras.sort((a, b) {
        if (a["ok"] && !b["ok"])
          return 1;
        else if (!a["ok"] && b["ok"])
          return -1;
        else
          return 0;
      });
      _saveData();
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = jsonEncode(_listaCompras);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Compras'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Column(
                    children: [
                      TextField(
                        showCursor: false,
                        keyboardType: TextInputType.text,
                        controller: _itemCompraController,
                        decoration: InputDecoration(
                          labelText: 'Digite o nome do produto',
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: _qtddCompraController,
                        decoration: InputDecoration(
                          labelText: 'Digite a quantidade',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: _addListaCompras,
                  child: Container(
                    width: 80,
                    height: 60,
                    color: Colors.teal[500],
                    child: Center(
                      child: Text(
                        'ADD',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: _listaCompras.length,
                itemBuilder: (context, index) {
                  return buildItem(context, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      direction: DismissDirection.startToEnd,
      key: Key(Random().toString()),
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
      child: CheckboxListTile(
        value: _listaCompras[index]["ok"],
        onChanged: (check) {
          setState(() {
            _listaCompras[index]["ok"] = check;
            _saveData();
          });
        },
        secondary: CircleAvatar(
          backgroundColor: Colors.teal[500],
          foregroundColor: Colors.white,
          child: Icon(
            _listaCompras[index]["ok"] ? Icons.check : Icons.error,
          ),
        ),
        title: Text(_listaCompras[index]["title"]),
        subtitle: Text(_listaCompras[index]["quantidade"]),
      ),
      onDismissed: (direction) {
        //Seria uma função para quando for deletado a note,
        setState(() {
          _lastRemoved = Map.from(_listaCompras[index]);
          _lastRemovedPos = index;
          _listaCompras.removeAt(index);
          _saveData();

          final snack = SnackBar(
            duration: Duration(seconds: 2),
            content: Text("Tarefa ${_lastRemoved["title"]} removida!! "),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _listaCompras.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }),
          );
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }
}
