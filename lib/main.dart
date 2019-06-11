import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = 'https://api.hgbrasil.com/finance?key=2be5c94b';

void main() async {
  print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty){
      _clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  double dolar;
  double euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Carregando dados ...",
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    "Error ao carregar  dados ...  :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ));
                } else {
                  dolar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150, color: Colors.amber),
                        buildInputTextField(
                            "Reais", 'R\$', realController, _realChanged),
                        Divider(),
                        buildInputTextField(
                            "Dolar", 'US\$', dolarController, _dolarChanged),
                        Divider(),
                        buildInputTextField(
                            "Euro", '€', euroController, _euroChanged)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildInputTextField(String labelText, String prefixText,
    TextEditingController controller, Function changed) {
  return TextField(
      controller: controller,
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.amber),
          border: OutlineInputBorder(),
          prefixText: prefixText),
      style: TextStyle(color: Colors.amber, fontSize: 20),
      onChanged: changed,
      keyboardType: TextInputType.numberWithOptions(decimal: true));

}
