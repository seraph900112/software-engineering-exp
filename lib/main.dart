// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io' as io;
import 'dart:io';

import 'package:eyro_toast/eyro_toast.dart';
import 'package:flutter/material.dart';
import 'package:se_exp/ui/backupFile.dart';
import 'package:se_exp/ui/restoreFile.dart';
import 'package:se_exp/ui/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool checkBoxVisible = false;
  String path = '/';
  GlobalKey<BackupFileState> backupKey = GlobalKey();
  GlobalKey<RestoreFileState> restoreKey = GlobalKey();
  GlobalKey<SettingState> settingKey = GlobalKey();
  int selectIndex = 0;
  Icon floatIcon = const Icon(Icons.add);

  @override
  void initState() {
    super.initState();
  }

  void changeIndex(int index) {
    setState(() {
      selectIndex = index;
      checkBoxVisible = false;
    });
  }

  Widget bodyWidget() {
    if (selectIndex == 0) {
      return BackupFile(
        key: backupKey,
        checkboxVisible: checkBoxVisible,
        getPath: (String path) {
          setState(() {
            floatIcon = const Icon(Icons.add);
            this.path = path;
          });
        },
        changeCheckBoxStatus: () {
          setState(() {
            checkBoxVisible = false;
          });
        },
      );
    } else if (selectIndex == 1) {
      return RestoreFile(
        key: restoreKey,
        checkboxVisible: checkBoxVisible,
        changeCheckBoxStatus: () {
          setState(() {
            floatIcon = const Icon(Icons.add);
            checkBoxVisible = false;
          });
        },
      );
    }
    setState(() {
      floatIcon = const Icon(Icons.sd_card);
    });
    return Setting(
      key: settingKey,
      storeSetting: () {},
    );
  }

  Future<void> showToast() async {
    // showing short Toast
    await showToaster(
      text: 'This is a centered Toaster',
      gravity: ToastGravity.top,
      backgroundColor: Colors.red,
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
                padding: const EdgeInsets.only(bottom: 10, top: 20),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: selectIndex == 1
                          ? MaterialStateProperty.all<Color>(Colors.orange)
                          : MaterialStateProperty.all<Color>(Colors.transparent),
                    ),
                    onPressed: () {
                      changeIndex(1);
                    },
                    child: const Text('ViewRestoreFiles')),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height - 300, top: 20),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: selectIndex == 2
                          ? MaterialStateProperty.all<Color>(Colors.orange)
                          : MaterialStateProperty.all<Color>(Colors.transparent),
                    ),
                    onPressed: () {
                      changeIndex(2);
                    },
                    child: const Text(
                      'Setting',
                    )),
              ),
              ElevatedButton(
                  onPressed: () {
                    selectIndex == 0
                        ? backupKey.currentState?.count == 0
                            ? showToast()
                            : backupKey.currentState?.backUp()
                        : restoreKey.currentState?.count == 0
                            ? showToast()
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
          onPressed: () async {
            setState(() {
              checkBoxVisible = !checkBoxVisible;
            });
            if (selectIndex == 2) {
              print(settingKey.currentState);
              final prefs = await SharedPreferences.getInstance();
              if (settingKey.currentState != null) {
                if (settingKey.currentState!.backupController.text.isNotEmpty) {
                  await prefs.setString(
                      'backupPath', settingKey.currentState!.backupController.text);
                } else {
                  prefs.setString('backupPath', 'null');
                }

                if (settingKey.currentState!.backupController.text.isNotEmpty) {
                  await prefs.setString(
                      'restorePath', settingKey.currentState!.restoreController.text);
                } else {
                  prefs.setString('backPath', 'null');
                }

                if (!Directory(prefs.getString('backupPath')!).existsSync() ||
                    !Directory(prefs.getString('restorePath')!).existsSync()) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text(
                        'Warning!!!',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      content: const SizedBox(
                          width: 500, height: 100, child: Text('please check your dir')),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  prefs.setString('backupPath', 'default');
                  prefs.setString('restorePath', 'default');
                  setState(() {
                    settingKey.currentState!.backupController.text = "";
                    settingKey.currentState!.restoreController.text = "";
                  });
                }
              }
            }
          },
          child: floatIcon),
    );
  }
}
