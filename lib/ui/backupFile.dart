import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:show_up_animation/show_up_animation.dart';

import '../utli/write_file.dart';

class BackupFile extends StatefulWidget {
  const BackupFile(
      {super.key,
      required this.checkboxVisible,
      required this.getPath,
      required this.changeCheckBoxStatus});

  final bool checkboxVisible;
  final Function(String) getPath;
  final Function changeCheckBoxStatus;

  @override
  State<StatefulWidget> createState() => BackupFileState();
}

class BackupFileState extends State<BackupFile> {
  String path = '/';
  String rootPath = '/';
  ScrollController scrollController = ScrollController();
  List<FileSystemEntity> file = <FileSystemEntity>[];
  late List<bool?> checkboxStatus;
  late Directory backupDir;
  int count = 0;

  @override
  void initState() {
    super.initState();
    _listOfFiles();
  }

  Future<void> backUp() async {
    List<FileSystemEntity> tmp = <FileSystemEntity>[];
    for (int i = 0; i < file.length; i++) {
      if (checkboxStatus[i]!) {
        tmp.add(file[i]);
      }
    }
    bool res = await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Are you sure to backup?',
          style: TextStyle(color: Colors.blueAccent),
        ),
        content: SizedBox(
          width: 500,
          height: 100 + tmp.length * 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: Text(
                  'The following files or directories will be backup: ',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 20),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tmp.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(pathToName(tmp[index].path));
                    }),
              )
            ],
          ),
        ),
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
    if (res) {
      // show the loading dialog
      showDialog(
          // The user CANNOT close this dialog  by pressing outsite it
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return Dialog(
              // The background color
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    // The loading indicator
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 15,
                    ),
                    // Some text
                    Text('Loading...')
                  ],
                ),
              ),
            );
          });

      // Your asynchronous computation here (fetching data from an API, processing files, inserting something to the database, etc)
      await WriteFile().backUpFile(tmp);
      // Close the dialog programmatically
      Navigator.of(context).pop();
      checkboxStatus.fillRange(0, checkboxStatus.length, false);
      widget.changeCheckBoxStatus();
    }

    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  Icon(Icons.check,color: Colors.green,),
                  Text("backup success！！")
                ],
              ),
            ),
          );
        });
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop();
  }

  void _listOfFiles() async {
    setState(() {
      file = Directory(path).listSync();
      sortFiles(file);
    });
    checkboxStatus = List.filled(file.length, false);
  }

  void changeDirectory(String path, bool back) {
    int pos = this.path.lastIndexOf('/');
    if (back) {
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 200,
      child: ListView(
        children: <Widget>[
          if (path != rootPath) ...[
            InkWell(
                onDoubleTap: () {
                  changeDirectory(path, true);
                  widget.getPath(path);
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
                    if (value!) {
                      count++;
                    } else {
                      count--;
                    }
                    checkboxStatus[index] = value;
                    print(count);
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
                widget.getPath(file.path);
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
