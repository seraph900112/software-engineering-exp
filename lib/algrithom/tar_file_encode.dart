//import 'dart:typed_data';
//import 'tar/tar_file.dart';
//import 'util/output_stream.dart';
//import 'archive.dart';
//import 'archive_file.dart';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'Tarfile_wirte_disk.dart';

class encode_tarfile {
  //String
  //Directory source_dir;
  //String target_file;//需要打包的文件夹路径
  late Tarfile_wirte_disk file_write;
  late Directory source_dir;
  bool finished = false;

  encode_tarfile(String dir) {
    //将传入的源目录串实例化为一个目录对象
    source_dir = Directory(dir);
  }

  Future<void> encodetarfile([String? target_path]) async {
    //1.定义打包路径
    var source_dir_path = source_dir.path;
    if (target_path == null) {
      target_path = '$source_dir_path.tar';
    } else {
      String directory_name = source_dir_path.split('\\').last;
      target_path = '$target_path' + '\\' + '$directory_name.tar';
    }
    //print(target_path);
    //2.创建打包路径
    create(target_path);
    //3.从目录中读取文件并将文件写入到对应路径中
    write_directory();
  }

  void create(String target_path) {
    file_write = Tarfile_wirte_disk(target_path);
  }

  Future<void> write_directory() async //只能用followlinks的方法
  {
    var filelist = source_dir.listSync(recursive: true, followLinks: true);
    for (var file_or_directory in filelist) {
      if (file_or_directory is Directory) {
        var code = Utf8Encoder().convert(file_or_directory.path);
        file_write.writeInt(code.length);
        file_write.writeString(code);
        file_write.write_byte(0);
      } else if (file_or_directory is File) {
        write_file(file_or_directory);
      }
    }
    await file_write.write.close();
    finished = true;
  }

  void write_file(File file) {
    file_write.write_file(file);
  }
}

/*void main()
{
  var rat=encode_tarfile('C:\\Users\\fander\\Desktop\\aes_crypt_null_safe-master');
  rat.encodetarfile('C:\\Users\\fander\\Desktop\\新建文件夹');
}*/
