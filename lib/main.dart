// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io' as io;
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:se_exp/ui/backupFile.dart';
import 'package:se_exp/ui/restoreFile.dart';
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
  String title = "BackUp System Current Dir:  ";
  late Directory backupDir;
  bool checkBoxVisible = false;
  String path = '/';
  GlobalKey<BackupFileState> backupKey = GlobalKey();
  GlobalKey<RestoreFileState> restoreKey = GlobalKey();
  int selectIndex = 0;

  Future<void> getBackUpDir() async {
    backupDir = await getApplicationDocumentsDirectory();
  }

  @override
  void initState() {
    super.initState();
  }

  void changeIndex(int index) {
    setState(() {
      selectIndex = index;
    });
  }

  Widget bodyWidget() {
    if (selectIndex == 0) {
      return BackupFile(
          key: backupKey,
          checkboxVisible: checkBoxVisible,
          getPath: (String path) {
            setState(() {
              this.path = path;
            });
          });
    }
    return RestoreFile(
      key: restoreKey,
      checkboxVisible: checkBoxVisible,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title + path),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 20),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: selectIndex == 0
                          ? MaterialStateProperty.all<Color>(Colors.orange)
                          : MaterialStateProperty.all<Color>(Colors.transparent),
                    ),
                    onPressed: () {
                      changeIndex(0);
                    },
                    child: const Text('ViewBackUpFiles')),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 200),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: selectIndex == 1
                          ? MaterialStateProperty.all<Color>(Colors.orange)
                          : MaterialStateProperty.all<Color>(Colors.transparent),
                    ),
                    onPressed: () {
                      changeIndex(1);
                    },
                    child: const Text(
                      'ViewRestoreFiles',
                    )),
              ),
              ElevatedButton(
                  onPressed: () {
                    selectIndex == 0
                        ? backupKey.currentState?.backUp()
                        : restoreKey.currentState?.restore();
                  },
                  child: Text(
                    selectIndex == 0 ? 'BackUp' : 'Restore',
                  )),
            ],
          ),
          const VerticalDivider(
            thickness: 3,
            color: Colors.black,
          ),
          bodyWidget()
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
}
