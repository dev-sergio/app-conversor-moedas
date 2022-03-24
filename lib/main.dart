import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?key=e3cc6670";

void main() async {
  runApp( MaterialApp(
    home: const MyApp(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _realChanged(String text){
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text){
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar /euro).toStringAsFixed(2);
  }
  void _euroChanged(String text){
    double euro = double.parse(text);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    realController.text = (euro * this.euro).toStringAsFixed(2);
  }

  void _clearAll(){
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("\$ Conversor \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getDados(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      buildTextField("Reais", "R\$", realController, _realChanged, _clearAll),
                      const Divider(),
                      buildTextField("Dolares", "US\$", dolarController, _dolarChanged, _clearAll),
                      const Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged, _clearAll)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map> getDados() async {
  var url = Uri.parse(request);
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

// WIDGETS

Widget buildTextField(String label, String prefix, TextEditingController c, Function f, Function clear){
  return TextField(
    controller: c,
    onChanged: (texto){
      if (texto.isEmpty){ clear();}
      f(texto);
    },
    decoration: InputDecoration(
        labelText: label,
        labelStyle:
        const TextStyle(color: Colors.amber, fontSize: 20.0),
        border: const OutlineInputBorder(),
        prefixText: prefix
    ),
    style: const TextStyle(
        color: Colors.amber, fontSize: 25
    ),
    keyboardType: TextInputType.number,
  );
}