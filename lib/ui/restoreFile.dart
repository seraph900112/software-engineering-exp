import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:show_up_animation/show_up_animation.dart';

import '../utli/write_file.dart';

class RestoreFile extends StatefulWidget {
  const RestoreFile({super.key, required this.checkboxVisible});

  final bool checkboxVisible;

  @override
  State<StatefulWidget> createState() => RestoreFileState();
}

class RestoreFileState extends State<RestoreFile> {
  String path = '/home/eric/Downloads';
  String rootPath = '/';
  ScrollController scrollController = ScrollController();
  List<FileSystemEntity> file = <FileSystemEntity>[];
  late List<bool?> checkboxStatus;
  late Directory backupDir;
  bool hasInit = false;
  Future<Directory?>? _appSupportDirectory;

  @override
  void initState() {
    super.initState();
    getBackUpRoot();
    _listOfFiles();
  }

  void _listOfFiles() {
    setState(() {
      file = Directory(path).listSync();
      sortFiles(file);
    });
    checkboxStatus = List.filled(file.length, false);
  }

  Future<void> getBackUpRoot() async {
    _appSupportDirectory = getApplicationDocumentsDirectory();
    if (_appSupportDirectory != null) {
      rootPath = (await _appSupportDirectory)!.path;
    }
    path = rootPath;
  }

  void changeDirectory(String path, bool back) {
    int pos = this.path.lastIndexOf('/');
    if (back) {
      this.path = pos <= 0 ? '/' : this.path.substring(0, pos);
    } else {
      this.path = path;
    }

    try {
      setState(() {
        file = Directory(this.path).listSync();
        checkboxStatus = List.filled(file.length, false);
        sortFiles(file);
        scrollController.animateTo(0,
            duration: const Duration(milliseconds: 10), curve: Curves.elasticOut);
      });
    } catch (e) {
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

  String pathToName(String path) {
    int pos = path.lastIndexOf('/');
    return path.substring(pos + 1, path.length);
  }

  void restore() {
    List<FileSystemEntity> tmp = <FileSystemEntity>[];
    if (path == rootPath) {
      for (int i = 0; i < file.length; i++) {
        if (checkboxStatus[i]!) {
          Directory tmpDir = file[i] as Directory;
          List<FileSystemEntity> tmpList = tmpDir.listSync();
          print(tmpList.length);
          late FileSystemEntity remove;
          for (var element in tmpList) {
            if (element.path.substring(element.path.lastIndexOf('/') + 1) == 'restoreInfo.txt') {
              remove = element;
              print('remove');
            }
          }
          tmpList.remove(remove);
          print(tmpList.length);
          WriteFile().restoreFile(tmpList);
        }
      }
      return;
    }
    for (int i = 0; i < file.length; i++) {
      if (checkboxStatus[i]!) {
        tmp.add(file[i]);
      }
    }
    print('restore');
    //WriteFile().restoreFile(tmp);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _appSupportDirectory,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            if (!hasInit) {
              Directory dir = snapshot.data;
              rootPath = dir.path;
              path = rootPath;
              file = Directory(path).listSync();
              sortFiles(file);
              hasInit = true;
            }
            return build1();
          }
        }
        return const Text('noData');
      },
    );
  }

  Widget build1() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 162,
      child: ListView(
        children: <Widget>[
          if (path != rootPath) ...[
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
          if (widget.checkboxVisible) ...[
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
              style: const TextStyle(fontSize: 20),
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
                const Icon(Icons.link),
                Text(
                  pathToName(file.path),
                  style: const TextStyle(fontSize: 20),
                )
              ],
            )
          ]
        ],
      ),
    );
  }
}