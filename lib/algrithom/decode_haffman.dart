import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class haffman_decode
{

  late File file0;
  haffman_decode(String filepath)
  {
    this.file0=File(filepath);
  }

  Future <void> haffmandecode([String? target_path]) async {
  bool finished=false;
  Stopwatch stopwatch = new Stopwatch()..start();
  //根据编码树还原
  //var file_last = File('C:\\Users\\fander\\Desktop\\新建文本文档.txt.haffman');
  var file_last_0 =   file0.readAsBytesSync();
  //file_last_0.add(224);

  //1.读出解码所需信息长度
  //2.读出解码信息补0长度
  //3.读出解码所需信息
  //4.读出补0数字
  //5.根据编码表转换的二进制串还原出编码树

  int encode_length=file_last_0[0]+file_last_0[1]*256;
  int encode_zeros=file_last_0[2];
  int index_of_decompress=0;
  String decompress='';
  for (var i=3;i<3+encode_length;i++)
  {
    decompress+=file_last_0[i].toRadixString(2).padLeft(8,'0');
  }
      decompress=decompress.substring(0,decompress.length-encode_zeros);
  treenode_for_decompression node0=new treenode_for_decompression(null,null,null);
  void decompression(treenode_for_decompression node)
  {
  
  if(decompress[index_of_decompress]=='0')
    {
      var node1=new treenode_for_decompression(null,null,null);
      var node2=new treenode_for_decompression(null,null,null);
      index_of_decompress+=1;
      node.left_child=node1;
      node.right_child=node2;
      decompression(node1);
      decompression(node2);
    } 
    else
    {
      //var node3=new treenode_for_decompression(null,null,null);
      index_of_decompress+=1;
      node.treenode_key=decompress.substring(index_of_decompress,index_of_decompress+8);
      index_of_decompress+=8;
      //print(node.treenode_key);
    }
    return ;
  }
  decompression(node0);


  if (target_path!=null)
  {
    String filename =file0.path.split('\\').last;
    target_path=target_path+'\\'+filename.replaceAll('.haffman','');
  }
  else 
  {
     target_path=file0.path.replaceAll('.haffman','');
  }
  File file_write3 = new File(target_path);
  //创建写入流
  IOSink write2 = file_write3.openWrite();
  //var value3=Uint8List(1);
  int index_of_decompress2=3+encode_length;
  int bit_index_of_of_decompress=0;
  void find_code(treenode_for_decompression node){
    
    if (node.left_child==null && node.right_child==null)
    { 
      var value3=Uint8List(1);
      String code=node.treenode_key;
      for(int j= 0; j<code.length; j++){
        if(code[j] == '0'){
          (value3[0] &= (~(1 << ((j) ^ 7))));
        }
        if(code[j] == '1'){
        (value3[0] |= (1 << ((j) ^ 7)));
        }
      }
      write2.add(value3);
      //print('文件都jiya了,doSomething() executed in ${stopwatch.elapsed}');
      if (((index_of_decompress2)==file_last_0.length-2)&&(bit_index_of_of_decompress==8-file_last_0.last))
      {
        index_of_decompress2=file_last_0.length;
      }
      //if (bit_index_of_of_decompress>=8)
      //{
      //    bit_index_of_of_decompress=0;
      //    index_of_decompress2+=1;
    // }
      
    }
    else if ((((file_last_0[index_of_decompress2]) & (1 << ((bit_index_of_of_decompress) ^ 7))) != 0)==true)
    {
      bit_index_of_of_decompress+=1;
      if (bit_index_of_of_decompress>=8)
      {
          bit_index_of_of_decompress=0;
          index_of_decompress2+=1;
      }
      find_code(node.right_child);

    }
    else
    {
      bit_index_of_of_decompress+=1;
      if (bit_index_of_of_decompress>=8)
      {
          bit_index_of_of_decompress=0;
          index_of_decompress2+=1;
      }
      find_code(node.left_child);
    }
  }
  while (index_of_decompress2<file_last_0.length-1)
  {
    find_code(node0);
  }

  print('文件都jiya了,doSomething() executed in ${stopwatch.elapsed}');
  await write2.close();
  finished=true;
  }


}

class treenode
{
  var treenode_key;
  late int treenode_value;
  var left_child;
  var right_child;

  treenode(treenode_key,treenode_value,left_child,right_child)
  {
    this.treenode_key=treenode_key;
    this.treenode_value=treenode_value;
    this.left_child=left_child;
    this.right_child=right_child;
  }



  
}

//解压缩树的节点类定义
class treenode_for_decompression
{
  var treenode_key;
  var left_child;
  var right_child;

  treenode_for_decompression(treenode_key,left_child,right_child)
  {
    this.treenode_key=treenode_key;
    this.left_child=left_child;
    this.right_child=right_child;
  }
}


/*void main()
{
  var tst=haffman_decode('C:\\Users\\fander\\Desktop\\新建文本文档.txt.haffman');
  tst.haffmandecode('C:\\Users\\fander\\Desktop\\新建文件夹');
}*/