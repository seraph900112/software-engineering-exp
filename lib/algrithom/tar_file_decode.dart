import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'readfile.dart';

//import 'readflie.dart';
class decode_tarfile {
  //File source_tar_file;
  late File source_tar_file;
  late String splitMark;

  decode_tarfile(String filepath) {
    if (Platform.isLinux) {
      splitMark = '/';
    }
    if (Platform.isWindows) {
      splitMark = '\\';
    }
    this.source_tar_file = File(filepath);
  }

  Future<void> decodetarfile([String? decode_rar_path]) async {
    String? target_path;
    //如果用户没有提供对应解包路径，则将包解在当前同文件夹下
    if (decode_rar_path == null) {
      target_path = source_tar_file.path;
      String filename = (target_path.split(splitMark).last);
      target_path = target_path.replaceAll(filename, '');
    } else {
      target_path = decode_rar_path;
    }
    await read(target_path);
  }

  Future<void> read(String target_path) async {
    int length1 = 0;
    String name = '';
    bool file_or_not;
    late String old_path;
    var readfile = read_file(source_tar_file);
    print(readfile.file.statSync().size);
    while (readfile.position < readfile.file.statSync().size) {
      String path = '';
      if (readfile.position == 0) {
        length1 = readfile.read_int();
        name = Utf8Decoder().convert(readfile.read_bytes(length1));

        String filename = name.split(splitMark).last;
        old_path = name.replaceAll('$splitMark$filename', '');
        String filename2 = old_path.split(splitMark).last;
        old_path = old_path.replaceAll(filename2, '');
        //创建顶层目录
        create_directory('$target_path$splitMark$filename2', readfile);
      } else {
        length1 = readfile.read_int();
        //name=Utf8Decoder().convert(readfile.read_bytes(length1));
        //name= new String.fromCharCodes(readfile.read_bytes(length1));
        name = utf8.decode(readfile.read_bytes(length1));
      }
      file_or_not = (readfile.read_byte() == 1);
      if (file_or_not == false) {
        //创建目录
        path = name.replaceAll(old_path, '$target_path$splitMark');
        create_directory(path, readfile);
        print(path);
      } else {
        path = name.replaceAll(old_path, '$target_path$splitMark');
        int length2 = readfile.read_int();
        await create_and_write_file(path, length2, readfile);
        print(path);
      }
    }
  }

  void create_directory(String path, read_file readfile) {
    if (Platform.isLinux) {
      path = path.substring(1);
    }
    var dir = Directory(path);
    dir.createSync();
  }

  Future<void> create_and_write_file(String path, int length2, read_file readfile) async {
    File file_write = new File(path);
    IOSink write = file_write.openWrite();
    write.add(readfile.read_bytes(length2));
    await write.close();
    return;
  }
}

/*void main()
{
  var decode=decode_tarfile('C:\\Users\\fander\\Desktop\\新建文件夹\\aes_crypt_null_safe-master.tar');
  decode.decodetarfile('C:\\Users\\fander\\Desktop\\论文');//,
// 'C:\\Users\\fander\\Desktop\\新建文件夹');
 
}*/
