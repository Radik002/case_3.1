import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pizza',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlutterDemo(
        storage: CounterStorage(),
      ),
    );
  }
}

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    return file.writeAsString('$counter');
  }
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({Key? key, required this.storage}) : super(key: key);

  final CounterStorage storage;

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 0;
  int _counterShared = 0;

  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
    _loadCounter();
  }

  void _loadCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counterShared = (prefs.getInt('counterSharedPrefs') ?? 0);
    });
  }

  void _sharedCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counterShared = (prefs.getInt('counterSharedPrefs') ?? 0) + Random().nextInt(30);
      prefs.setInt('counterSharedPrefs', _counterShared);
    });
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter += Random().nextInt(30);
    });

    return widget.storage.writeCounter(_counter);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child:
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  child: const Text('Прибавить рандом'),
                  onPressed: () {
                    setState(() {
                      _incrementCounter();
                    });
                  }),
              Text(
                'Результат $_counter',
                textAlign: TextAlign.center,
              ),
            ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                  child: const Text('Прибавить рнадом (SharedP)'),
                  onPressed: () {
                    setState(() {
                      _sharedCounter();
                      _loadCounter();
                    });
                  }),
              Text(
                'Результат $_counterShared',
                textAlign: TextAlign.center,
              ),
            ],
        ),

        ElevatedButton(
              child: const Text('Очистить'),
              onPressed: () {
                setState(() {
                  _removeShared();
                  _clearFile();
                  _loadCounter();
                });
              }),
      ]),
          ),
    ));
  }

  Future _clearFile() {
    setState(() {
      _counter = 0;
    });
    return widget.storage.writeCounter(_counter);
  }

  Future _removeShared() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove('counterSharedPrefs');
  }
}
