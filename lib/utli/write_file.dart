import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class WriteFile {
  Future<void> backUpFile(List<FileSystemEntity> files) async {
    //create a backup dir
    String backUpDir = (await getApplicationDocumentsDirectory()).path;
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String time = DateFormat("hh:mm:ss").format(DateTime.now());
    Directory originDir = files[0].parent;
    Directory backupDir = Directory('$backUpDir/$date$time');
    if (!backupDir.existsSync()) {
      backupDir.createSync();
    }
    //record restore path;
    File restoreInfo = File('${backupDir.path}/restoreInfo.txt');
    String restorePath = files[0].path.substring(0, files[0].path.lastIndexOf('/'));
    restoreInfo.writeAsString(restorePath);

    //write to backUp dir
    writeFile(files, backupDir, originDir);
  }

  Future<void> writeFile(
      List<FileSystemEntity> files, Directory writeDir, Directory sourceDir) async {
    for (int i = 0; i < files.length; i++) {
      //backup Dir
      if (files[i] is Directory) {
        Directory tmp = files[i] as Directory;
        String tmpName = tmp.path.substring(tmp.path.lastIndexOf('/'));
        Directory newDir = Directory('${writeDir.path}$tmpName');
        if (!newDir.existsSync()) {
          newDir.createSync(recursive: true);
        }
        Directory nextBackUpDir = Directory('${writeDir.path}$tmpName');
        Directory nextOriginDir = Directory('${sourceDir.path}$tmpName');
        writeFile(tmp.listSync(), nextBackUpDir, nextOriginDir);
      }
      //backup File
      if (files[i] is File) {
        File tmp = files[i] as File;
        Uint8List tmpString = await tmp.readAsBytes();
        String fileName = tmp.path.substring(tmp.path.lastIndexOf('/'), tmp.path.length);
        File newFile = File('${writeDir.path}$fileName');
        newFile.writeAsBytesSync(tmpString);
      }
    }
  }

  Future<void> restoreFile(List<FileSystemEntity> files) async {
    //find restoreInfo
    if (files.isEmpty) {
      return;
    }
    RegExp regexp = RegExp(r'(\d{4}-\d{2}-\d{4}:\d{2}:\d{2})');
    FileSystemEntity file = files[0];
    int pos = file.path.indexOf(regexp) + 18;
    String prefix = file.path.substring(0, pos);
    File restoreInfo = File('$prefix/restoreInfo.txt');
    String originPath = restoreInfo.readAsStringSync();
    String suffix = file.path.substring(pos);
    String writePath = originPath + suffix;
    print('origin: $originPath');
    print('suffix: $suffix');
    print(writePath);
    print(files[0].path);
    writeFile(files, Directory(writePath).parent, Directory(files[0].path));
  }
}
