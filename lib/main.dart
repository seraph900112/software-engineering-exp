// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io' as io;
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:se_exp/utli/write_file.dart';
import 'package:show_up_animation/show_up_animation.dart';

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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String path = "/";
  String title = "BackUp System Current Dir:  ";
  late Directory backupDir;
  List<FileSystemEntity> file = <FileSystemEntity>[];
  ScrollController scrollController = ScrollController();
  bool checkBoxVisible = true;
  late List<bool?> checkboxStatus;

  Future<void> getBackUpDir() async {
    backupDir = await getApplicationDocumentsDirectory();
  }

  void _listOfFiles() async {
    setState(() {
      file = Directory(path).listSync();
      sortFiles(file);
    });
    checkboxStatus = List.filled(file.length, false);
  }

  void changeDirectory(String path, bool back) {
    if (back) {
      int pos = this.path.lastIndexOf('/');
      this.path = pos <= 0 ? '/' : this.path.substring(0, pos);
    } else {
      this.path = path;
    }
    print(this.path);

    try {
      setState(() {
        file = Directory(this.path).listSync();
        checkboxStatus = List.filled(file.length, false);
        sortFiles(file);
        scrollController.animateTo(0,
            duration: const Duration(milliseconds: 10), curve: Curves.elasticOut);
      });
    } catch (e) {
      print(e);

      //show alert dialog
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission denied'),
          content: const Text('please try another directory'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      //roll back to path
      int pos = this.path.lastIndexOf('/');
      this.path = pos <= 0 ? '/' : this.path.substring(0, pos);
    }
  }

  String pathToName(String path) {
    int pos = path.lastIndexOf('/');
    return path.substring(pos + 1, path.length);
  }

  void sortFiles(List<FileSystemEntity> list) {
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i] is Directory) {
        FileSystemEntity tmp = list[i];
        list.removeAt(i);
        list.insert(count, tmp);
        count++;
      }
    }
  }

  @override
  void initState() {
    print('init');
    super.initState();
    _listOfFiles();
  }

  void backUp() {
    getBackUpDir();
    List<FileSystemEntity> tmp = <FileSystemEntity>[];
    for (int i = 0; i < file.length; i++) {
      if (checkboxStatus[i]!) {
        tmp.add(file[i]);
      }
    }
    WriteFile().backUpFile(tmp);
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: AppBar(
        title: Text(title + path),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Text("Data Backup"),
              const Text("Data Restore"),
              ElevatedButton(onPressed: (){
                backUp();
              }, child: const Text('backup'))
            ],
          ),
          const VerticalDivider(
            thickness: 3,
            color: Colors.black,
          ),
          allFiles(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              checkBoxVisible = !checkBoxVisible;
            });
          },
          child: const Icon(Icons.add)),
    );
  }

  Widget allFiles() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 200,
      child: ListView(
        children: <Widget>[
          if (path != '/') ...[
            InkWell(
                onDoubleTap: () {
                  changeDirectory(path, true);
                },
                child: Row(
                  children: const [Icon(Icons.keyboard_backspace), Text("back")],
                ))
          ],
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: ListView.builder(
                    controller: scrollController,
                    itemCount: file.length,
                    itemBuilder: (BuildContext context, int index) {
                      return fileBar(file[index], index);
                    }),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget fileBar(FileSystemEntity file, int index) {
    return SizedBox(
      height: 40,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (checkBoxVisible) ...[
            ShowUpAnimation(
              animationDuration: const Duration(milliseconds: 300),
              curve: Curves.linear,
              direction: Direction.horizontal,
              offset: 0.5,
              child: Checkbox(
                value: checkboxStatus[index],
                onChanged: (bool? value) {
                  setState(() {
                    checkboxStatus[index] = value;
                  });
                },
              ),
            ),
          ],
          if (file is File) ...[
            const Icon(Icons.insert_drive_file_sharp),
            Text(
              pathToName(file.path),
              style: TextStyle(fontSize: 20),
            )
          ] else if (file is Directory) ...[
            InkWell(
              onTap: () {
                changeDirectory(file.path, false);
              },
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(
                    Icons.folder,
                    color: Colors.grey,
                  ),
                  Text(
                    pathToName(file.path),
                    style: const TextStyle(fontSize: 20),
                  )
                ],
              ),
            )
          ] else ...[
            Row(
              children: [
                Icon(Icons.link),
                Text(
                  pathToName(file.path),
                  style: TextStyle(fontSize: 20),
                )
              ],
            )
          ]
        ],
      ),
    );
  }
}
