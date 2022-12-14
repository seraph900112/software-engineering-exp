import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../algrithom/ase.dart';

//import '../algrithom/decode_haffman.dart';
import '../algrithom/decode2.dart';

//import '../algrithom/encode_haffman.dart';
import '../algrithom/encode_haffman2.dart';
import '../algrithom/tar_file_decode.dart';
import '../algrithom/tar_file_encode.dart';

class WriteFile {
  bool restorefinish = false;

  Future<bool> backUpFile(List<FileSystemEntity> files, String pwd) async {
    final pref = await SharedPreferences.getInstance();
    String backUpDir = (await getApplicationSupportDirectory()).path;
    //create a backup dir
    if (pref.getString('backupPath') != 'default' && pref.getString('backupPath') != null) {
      backUpDir = pref.getString('backupPath')!;
    }

    print('this is write file: $backUpDir');
    String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    String time = DateFormat("hh-mm-ss").format(DateTime.now());
    Directory originDir = files[0].parent;

    late String newDirPath;
    if (Platform.isLinux) {
      newDirPath = '$backUpDir/$date$time';
    }
    if (Platform.isWindows) {
      newDirPath = '$backUpDir\\$date$time';
    }

    Directory backupDir = Directory(newDirPath);
    if (!backupDir.existsSync()) {
      backupDir.createSync();
    }
    String? restorePath = pref.getString('restorePath');

    //record restore path;
    if (Platform.isWindows) {
      File restoreInfo = File('${backupDir.path}\\restoreInfo.txt');
      if (restorePath == 'default' || restorePath == null) {
        restorePath = files[0].path.substring(0, files[0].path.lastIndexOf('\\'));
      }
      restoreInfo.writeAsString(restorePath);
    }
    if (Platform.isLinux) {
      File restoreInfo = File('${backupDir.path}/restoreInfo.txt');
      if (restorePath == 'default' || restorePath == null) {
        restorePath = files[0].path.substring(0, files[0].path.lastIndexOf('/'));
      }
      restoreInfo.writeAsString(restorePath);
    }
    //write to backUp dir
    bool res = await writeFile(files, backupDir, originDir);
    if(!res){
      return false;
    }
    //path = newDirPath
    print('start encode');

    //??????
    var rat = encode_tarfile(newDirPath);
    await rat.encodetarfile();
    while (!rat.finished) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    //?????? ??????
    var haffman = haffman_encode('$newDirPath.tar');
    haffman.haffmanencode();
    print('finish haffman');

    /*while (!haffman.finished) {
      await Future.delayed(Duration(milliseconds: 500));
      print(haffman.finished);
    }*/
    var ase = encrypt_file('$newDirPath.tar.haffman', pwd);
    print('start aes');
    ase.encryptfile();
    print('finish aes');
    //delete dir
    backupDir.delete(recursive: true);
    File('$newDirPath.tar.haffman').deleteSync();
    File('$newDirPath.tar').deleteSync();
    //File('$newDirPath.tar').deleteSync();
    return true;
  }

  Future<int> restoreFile(List<FileSystemEntity> files, String pwd) async {
//find restoreInfo
    if (files.isEmpty) {
      return 0;
    }
    for (int i = 0; i < files.length; i++) {
      String temp = files[i].path;
      int length = temp.length;
      if (length < 11) {
        return 1;
      }
      if (temp.substring(length - 11, length) != 'haffman.aes') {
        return 1;
      }
    }
    for (int i = 0; i < files.length; i++) {
//??????
      try {
        print('start aes___' + files[i].path);
        var ase = decrypt_file(files[i].path, pwd);
        ase.decryptfile();
      } catch (exception) {
        print('11111111');
        return 2;
      }
//?????????
      var tst = haffman_decode(files[i].path.replaceAll('.aes', ''));
      tst.haffmandecode();
      print('finish haffman');
//??????
      var decode = decode_tarfile(files[i].path.replaceAll('.haffman.aes', ''));
      await decode.decodetarfile();

      RegExp regexp = RegExp(r'(\d{4}-\d{2}-\d{4}-\d{2}-\d{2})');
      FileSystemEntity file = files[i];
      int pos = file.path.indexOf(regexp) + 18;
      String prefix = file.path.substring(0, pos);
      print('prefix' + prefix);
      late File restoreInfo;
      if (Platform.isWindows) {
        restoreInfo = File('$prefix\\restoreInfo.txt');
      }
      if (Platform.isLinux) {
        restoreInfo = File('$prefix/restoreInfo.txt');
      }

      String originPath = restoreInfo.readAsStringSync();
      print(restoreInfo.lengthSync());
      print('origin' + originPath);
      String writePath = originPath;
      print(files[i].path.substring(0, files[i].path.length - 16));
      Directory mainDir = Directory(files[i].path.substring(0, files[i].path.length - 16));
//write file
      await writeFile(mainDir.listSync(), Directory(writePath), Directory(files[0].path));

      File('$prefix.tar.haffman').delete();
      File('$prefix.tar').delete();
      mainDir.deleteSync(recursive: true);
      if (Platform.isWindows) {
        File('$writePath\\restoreInfo.txt').delete();
      }
      if (Platform.isLinux) {
        File('$writePath/restoreInfo.txt').delete();
      }
    }
    print('finish restore');
    restorefinish = true;
    return 3;
  }

  Future<bool> writeFile(
      List<FileSystemEntity> files, Directory writeDir, Directory sourceDir) async {
    for (int i = 0; i < files.length; i++) {
      //backup Dir
      if (files[i] is Directory) {
        Directory tmp = files[i] as Directory;
        late String tmpName;
        if (Platform.isWindows) {
          tmpName = tmp.path.substring(tmp.path.lastIndexOf('\\'));
        }
        if (Platform.isLinux) {
          tmpName = tmp.path.substring(tmp.path.lastIndexOf('/'));
        }
        Directory newDir = Directory('${writeDir.path}$tmpName');
        if (!newDir.existsSync()) {
          newDir.createSync(recursive: true);
        }
        Directory nextBackUpDir = Directory('${writeDir.path}$tmpName');
        Directory nextOriginDir = Directory('${sourceDir.path}$tmpName');
        await writeFile(tmp.listSync(), nextBackUpDir, nextOriginDir);
      }

      //backup File
      if (files[i] is File) {
        File tmp = files[i] as File;
        Uint8List tmpString = await tmp.readAsBytes();
        late String fileName;
        if (Platform.isWindows) {
          fileName = tmp.path.substring(tmp.path.lastIndexOf('\\'), tmp.path.length);
        }
        if (Platform.isLinux) {
          fileName = tmp.path.substring(tmp.path.lastIndexOf('/'), tmp.path.length);
        }
        File newFile = File('${writeDir.path}$fileName');
        newFile.writeAsBytesSync(tmpString);
        if (!check(files[i] as File, newFile)) {
          return false;
        }
      }
    }
    print('write finish');
    return true;
  }

  bool check(File origin, File newFile) {
    if (origin.lengthSync() != newFile.lengthSync()) {
      return false;
    }
    Uint8List origin8 = origin.readAsBytesSync();
    Uint8List new8 = origin.readAsBytesSync();
    for (int i = 0; i < origin8.length; i++) {
      if (origin8[i] != new8[i]) {
        return false;
      }
    }
    return true;
  }
}
