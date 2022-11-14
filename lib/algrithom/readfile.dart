import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'Tarfile_wirte_disk.dart';
class read_file
{
  late File file;
  int position =0;
  late  Uint8List file_content;
  late int size;
  read_file(File file)
  {
    this.file=file;
    this.file_content=file.readAsBytesSync();
    this.size = file.statSync().size;
  }
  

  int read_byte()
  {
    position+=1;
    return (file_content[position-1]);
  }
  
  int read_int ()
  {
    int result =0;
    result=file_content[position+3] | result;
    result=result<<8;

    result=file_content[position+2] | result;
      result=result<<8;
    
    result=file_content[position+1] | result;
      result=result<<8;
    
    result=file_content[position] | result;
    position+=4;
    return result;
    }
  
  Uint8List read_bytes( int count )
  {
      var value=file_content.sublist(position,position+count);
      position+=count;
      return value;

  }






  

}
