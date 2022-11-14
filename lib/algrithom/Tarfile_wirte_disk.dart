import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
class Tarfile_wirte_disk
{
  late IOSink write;
  late String path;

  Tarfile_wirte_disk(String path)
  {
      this.path=path;
      File file_write=new File(path);
      this.write=file_write.openWrite();
  }

  void write_file(File file)
  {
    var filename=file.path;
    var file_content = file.readAsBytesSync();
    
    var code=Utf8Encoder().convert(filename);
    writeInt(code.length);
    writeString(code);
    write_byte(1);
    writeInt(file_content.length);
    write.add(file_content);
  }

  void writeInt(int x)
  {
      write_byte(x&0xff);
      write_byte(x>>8&0xff);
      write_byte(x>>16&0xff);
      write_byte(x>>24&0xff);

  }
  void writeString(Uint8List code)
  {   
    //var code=Utf8Encoder().convert(str);
    write.add(code);
      
  }
  void write_byte(int value)
  {
      var value1=Uint8List(1);
      value1[0]=value&0xff;
      write.add(value1);
  }

}