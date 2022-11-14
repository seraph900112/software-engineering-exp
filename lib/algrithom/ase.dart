import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
//import 'aes_crypt_null_safe.dart';
class encrypt_file
{
  late String file_path;
  late String password;
  String? target_path;

  encrypt_file(String file_path,String password,[String? target_path1])
  {
    this.file_path=file_path;
    this.password=password;
    if (target_path1!=null)
    //写入用户指定的路径
    {
      String filename=file_path.split('\\').last;
      this.target_path='$target_path1'+'\\'+'$filename.aes';
    }

  }
  void encryptfile()
  {
      var crypt =AesCrypt(password);
      crypt.setOverwriteMode(AesCryptOwMode.rename);
      if (target_path!=null)
      {
        crypt.encryptFileSync(file_path,target_path!);
      }
      else
      {
        crypt.encryptFileSync(file_path);
      }
  }
}
class decrypt_file
{
  late String file_path;
  late String password;
  String? target_path;

  decrypt_file(String file_path,String password,[String? target_path1])
  {
    this.file_path=file_path;
    this.password=password;
    if (target_path1!=null)
    {
      String filename=file_path.split('\\').last;
      filename=filename.replaceAll('.aes', '');
      this.target_path='$target_path1'+'\\'+'$filename';
    }

  }
  void decryptfile()
  {
      var crypt =AesCrypt(password);
      crypt.setOverwriteMode(AesCryptOwMode.rename);
      if (target_path!=null)
      { 
        crypt.decryptFileSync(file_path,target_path!);
      }
     else
     {
        crypt.decryptFileSync(file_path);
     }
  }
}
//String file_path,String password

/*void main()
{
  var file0 = File('C:\\Users\\fander\\Desktop\\软件工程\\优化版4.dart.aes');
  var ase=decrypt_file(file0.path,'hshs');//'C:\\Users\\fander\\Desktop\\论文');
  //ase.encryptfile();
  //ase.file_path='C:\\Users\\fander\\Desktop\\软件工程\\优化版4test.dart';
  //ase.target_path='C:\\Users\\fander\\Desktop\\优化版4test.dart';
  ase.decryptfile();


}*/