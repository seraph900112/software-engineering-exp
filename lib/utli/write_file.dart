import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../algrithom/ase.dart';
import '../algrithom/decode_haffman.dart';
import '../algrithom/encode_haffman.dart';
import '../algrithom/tar_file_decode.dart';
import '../algrithom/tar_file_encode.dart';

class WriteFile {
  Future<void> backUpFile(List<FileSystemEntity> files) async {
    //create a backup dir
    String backUpDir = (await getApplicationSupportDirectory()).path;
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
    //record restore path;
    if (Platform.isWindows) {
      File restoreInfo = File('${backupDir.path}\\restoreInfo.txt');
      String restorePath =
          files[0].path.substring(0, files[0].path.lastIndexOf('\\'));
      restoreInfo.writeAsString(restorePath);
    }
    if (Platform.isLinux) {
      File restoreInfo = File('${backupDir.path}/restoreInfo.txt');
      String restorePath =
          files[0].path.substring(0, files[0].path.lastIndexOf('/'));
      restoreInfo.writeAsString(restorePath);
    }

    //write to backUp dir
    await writeFile(files, backupDir, originDir);
    //path = newDirPath
    print('start encode');

    //打包
    var rat = encode_tarfile(newDirPath);
    await rat.encodetarfile();
    while (!rat.finished) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    //压缩 加密
    var haffman = haffman_encode('$newDirPath.tar');
    await haffman.haffmanencode();
    print('finish haffman');
    while (!haffman.finished) {
      await Future.delayed(Duration(milliseconds: 500));
    }
    var ase = encrypt_file('$newDirPath.tar.haffman', 'hshs');
    ase.encryptfile();
    //delete dir
    //backupDir.delete(recursive: true);
    File('$newDirPath.tar').deleteSync();
    File('$newDirPath.tar.haffman').deleteSync();
  }

  Future<void> restoreFile(List<FileSystemEntity> files) async {
    //find restoreInfo
    if (files.isEmpty) {
      return;
    }
    for (int i = 0; i < files.length; i++) {
      //解密
      var ase=decrypt_file(files[i].path,'hshs');
      ase.decryptfile();
      //反压缩
      var tst=haffman_decode(files[i].path.replaceAll('.aes',''));
      await tst.haffmandecode();
      //解包
      var decode=decode_tarfile(files[i].path.replaceAll('.haffman.aes',''));
      await decode.decodetarfile();

      RegExp regexp = RegExp(r'(\d{4}-\d{2}-\d{4}-\d{2}-\d{2})');
      FileSystemEntity file = files[i];
      int pos = file.path.indexOf(regexp) + 18;
      String prefix = file.path.substring(0, pos);
      print('prefix'+ prefix);
      late File restoreInfo;
      if(Platform.isWindows){
        restoreInfo = File('$prefix\\restoreInfo.txt');
      }
      if(Platform.isLinux){
        restoreInfo = File('$prefix/restoreInfo.txt');
      }

      String originPath = restoreInfo.readAsStringSync();
      print(restoreInfo.lengthSync());
      print('origin'+originPath);
      String writePath = originPath;
      List<FileSystemEntity> tmpList = <FileSystemEntity>[];
      print(files[i].path.substring(0 , files[i].path.length -16));
      Directory mainDir = Directory(files[i].path.substring(0 , files[i].path.length -16));
      //write file
      await writeFile(mainDir.listSync(), Directory(writePath), Directory(files[0].path));
    }

    /*

    */
  }

  Future<void> writeFile(List<FileSystemEntity> files, Directory writeDir,
      Directory sourceDir) async {
    for (int i = 0; i < files.length; i++) {
      //backup Dir
      if (files[i] is Directory) {
        Directory tmp = files[i] as Directory;
        late String tmpName;
        if(Platform.isWindows){
          tmpName = tmp.path.substring(tmp.path.lastIndexOf('\\'));
        }
        if(Platform.isLinux){
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
          fileName =
              tmp.path.substring(tmp.path.lastIndexOf('\\'), tmp.path.length);
        }
        if (Platform.isLinux) {
          fileName =
              tmp.path.substring(tmp.path.lastIndexOf('/'), tmp.path.length);
        }
        File newFile = File('${writeDir.path}$fileName');
        newFile.writeAsBytesSync(tmpString);
      }
    }
    print('write finish');
  }
}
