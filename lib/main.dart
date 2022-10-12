// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Provider',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Path Provider'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Directory?>? _tempDirectory;
  Future<Directory?>? _appSupportDirectory;
  Future<Directory?>? _appDocumentsDirectory;
  Future<Directory?>? _downloadsDirectory;
  late String directory;
  List<FileSystemEntity> file = <FileSystemEntity>[];
  File file123 = File("path");
  void _listOfFiles() async {
    directory = (await getExternalStorageDirectory())!.path;
    print(directory.toString());
    setState(() {
      file = io.Directory(directory).listSync();
    });
   print(file[0].toString());
  }

  @override
  void initState() {
    super.initState();
    _listOfFiles();
  }

  void _requestTempDirectory() {
    setState(() {
      _tempDirectory = getDownloadsDirectory();
    });
  }

  Widget _buildDirectory(BuildContext context, AsyncSnapshot<Directory?> snapshot) {
    Text text = const Text('');
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        text = Text('Error: ${snapshot.error}');
      } else if (snapshot.hasData) {
        text = Text('path: ${snapshot.data!.path}');
      } else {
        text = const Text('path unavailable');
      }
    }
    return Padding(padding: const EdgeInsets.all(16.0), child: text);
  }

  void _requestAppDocumentsDirectory() {
    setState(() {
      _appDocumentsDirectory = getApplicationDocumentsDirectory();
    });
  }

  void _requestAppSupportDirectory() {
    setState(() {
      _appSupportDirectory = getApplicationSupportDirectory();
    });
  }

  void _requestDownloadsDirectory() {
    setState(() {
      _downloadsDirectory = getDownloadsDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  height: 500,
                  child: ListView.builder(
                      itemCount: file.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Text(file[index].toString(), style: TextStyle(fontSize: 30),);
                      }),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
