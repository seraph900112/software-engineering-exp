//import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
//import 'dart:web_gl';
class haffman_encode
{
  late File file0;
  haffman_encode(String filepath)
  {
    file0=File(filepath);
  }




void haffmanencode ([String?target_path])
  {
    Stopwatch stopwatch = new Stopwatch()..start();
    //var file0 = File('C:\\Users\\fander\\Desktop\\okusama_ntr_cn.exe.org');
    var file =   file0.readAsBytesSync();
    var haffman_table=Map<String,treenode>();
    var str1='';
    var str2='';
    List<int> tongji=List.filled(256,0);

    //构建哈希表
    for (var i=0;i<=255;i++)
    {
      str1=i.toString();//.toRadixString(2).padLeft(8,'0');
      var node=new treenode(i,0,null,null);
      haffman_table[str1]=node;
    }

    //统计频率
    for (var i=0;i<file.length;i+=1)
    {
      /* str2=file[i].toString();//.toRadixString(2).padLeft(8,'0');
    if (haffman_table[str2]!.treenode_value!= null)
    {
      int num1=haffman_table[str2]!.treenode_value+1;
      haffman_table[str2]!.treenode_value=num1;
    }*/
      tongji[file[i]]+=1;
    }
    for (var i in haffman_table.keys)
    {
      var num=int.parse(i,radix:10);
      haffman_table[i]!.treenode_value=tongji[num];
    }

    //开始排序
    List list1=haffman_table.values.toList(growable: true);
    list1.sort((a,b)=>a.treenode_value.compareTo (b.treenode_value));
    for (var i=0;i<256;i+=1)
    {
      if (list1[0].treenode_value!=0)
      {
        break;
      }
      list1.removeAt(0);
    }

    //开始构造哈夫曼树
    do
    {
      var tempnode =new treenode(null,(list1[0].treenode_value+list1[1].treenode_value),list1[0], list1[1]);
      list1.removeAt(0);
      list1.removeAt(0);
      int templength=list1.length;
      list1.add(tempnode);
      list1.sort((a,b)=>a.treenode_value.compareTo (b.treenode_value));
    }while(list1.length>1);


    //开始建立编码表
    List list2=new List.filled(256, 0);
    void bianli (str1,treenode node)
    {
      if (node.left_child!=null &&node.right_child!=null)
      {
        String str2=str1+'0';
        String str3=str1+'1';
        bianli(str2,node.left_child);
        bianli(str3,node.right_child);
      }
      else{
        int index=node.treenode_key;//int.parse(node.treenode_key,);
        list2[index]=str1;
        return;
      }
    }
    bianli('', list1[0]);

    //将得到的编码树转换为二进制串存储
    String decompress='';
    void  tree_to_string(treenode node)
    {
      if (node.left_child!=null && node.right_child!=null)
      {
        decompress+='0';
        tree_to_string(node.left_child);
        tree_to_string(node.right_child);
      }
      else{
        decompress+='1';
        decompress+=node.treenode_key.toRadixString(2).padLeft(8,'0');
      }
    }
    tree_to_string(list1[0]);

    print('doSomething() executed in ${stopwatch.elapsed}');
    //print(file.length);
    //String tempstr1='';
    //var file2 = File('file.txt');
    //Stream<List<int>> inputStream = file0.openRead() ;

    var read_file = file0.openSync();
    int fileposition=0;
    int filelength=read_file.lengthSync();
    var read_buffer=Uint8List(4096);
    var read_bufferPosition=0;



    if  (target_path!=null)
    {
      String filename=file0.path.split('\\').last;
      target_path=target_path+'\\'+filename+'.haffman';
    }
    else
    {
      String filename=file0.path.split('\\').last;
      target_path=file0.path+'.haffman';
    }
    File file_write = new File(target_path);
    //创建写入流
    //IOSink write = file_write.openWrite();
    RandomAccessFile write_fp = file_write.openSync(mode: FileMode.write);
    var write_buffer=Uint8List(4096);
    int write_bufferPosition=0;
    //写入头信息
    //1.给编码二进制串补0
    int zero_nums=decompress.length%8;
    if (zero_nums!=0)
    {
      decompress+='0'*(8-zero_nums);
    }

    int decompress_bytelength=decompress.length>>3;

    //2.将编码信息的长度，补0数和内容以字节的形式写入文件中
    var head_length=Uint8List(2);
    var head_zero_nums=Uint8List(1);
    head_length[0]= decompress_bytelength& 0xff;
    head_length[1]=(decompress_bytelength>>8) & 0xff;
    //write.add(head_length);
    write_buffer[write_bufferPosition++] = head_length[0];
    write_buffer[write_bufferPosition++] = head_length[1];
    head_zero_nums[0]=(8-zero_nums)&0xff;
    //write.add(head_zero_nums);
    write_buffer[write_bufferPosition++] = head_zero_nums[0];
    //上面共有三次写buffer操作，一定不会超过buffer大小，故不用检查

    var encode_infor=Uint8List(decompress_bytelength);
    int index_temp=0;
    int index_temp2=0;
    for (var x =0;x<decompress.length;x++)
    {
      if (decompress[x]=='0')
      {
        encode_infor[index_temp] &= (~(1 << ((index_temp2) ^ 7)));
      }
      else{
        encode_infor[index_temp]|=(1 << ((index_temp2) ^ 7));
      }

      if(++index_temp2 >= 8){
        index_temp2 = 0;
        index_temp+=1;;
      }
    }
    //write.add(encode_infor);
    for (int num=0;num<encode_infor.length;num++)
    {
      write_buffer[write_bufferPosition++] = encode_infor[num];
      if (write_bufferPosition==write_buffer.length)
      {
        write_fp.writeFromSync(write_buffer, 0, write_bufferPosition);
        write_bufferPosition = 0;
      }
    }



    //根据读入流写入压缩数据
    var value=Uint8List(1);//
    int index_for_compress=0;
    String tempstr='';
    //var listen = inputStream.listen((event) {
    // 一次读取65536。读取大文件时，有可能会读取多次
    //print("listen(),会调用多次 ${event.length}");

    //final bytesBuilder = BytesBuilder();
    //List<int> value2=[];
    //Uint8List.fromList(value2);
    //for (var i in event)
    while (fileposition<filelength)
    {
      //读一个buffer
      read_bufferPosition+=1;
      fileposition+=1;
      if( (read_bufferPosition >= read_buffer.length) || (fileposition==filelength))
      {
        if (read_bufferPosition >= read_buffer.length)
        {
          read_bufferPosition=0;
          int readbufferSize = read_file.readIntoSync(read_buffer, 0,read_buffer.length);
          for(int num=0;num<readbufferSize;num++)
          {
            String hufCode = list2[read_buffer[num]];
            for(int j= 0; j<hufCode.length; j++)
            {
              if(hufCode[j] == '0'){
                (value[0] &= (~(1 << ((index_for_compress) ^ 7))));
              }
              if(hufCode[j] == '1'){
                (value[0] |= (1 << ((index_for_compress) ^ 7)));
              }
              if(++index_for_compress >= 8)
              {
                index_for_compress = 0;
                //value2.add(value[0]);
                write_buffer[write_bufferPosition++] = value[0];
                if (write_bufferPosition==write_buffer.length)
                {
                  write_fp.writeFromSync(write_buffer, 0, write_bufferPosition);
                  write_bufferPosition = 0;
                }
              }
            }
          }
        }
        else if (fileposition==filelength)
        {
          int readbufferSize = read_file.readIntoSync(read_buffer,0, read_bufferPosition);
          for(int num=0;num<readbufferSize;num++)
          {
            String hufCode = list2[read_buffer[num]];
            for(int j= 0; j<hufCode.length; j++)
            {
              if(hufCode[j] == '0'){
                (value[0] &= (~(1 << ((index_for_compress) ^ 7))));
              }
              if(hufCode[j] == '1'){
                (value[0] |= (1 << ((index_for_compress) ^ 7)));
              }
              if(++index_for_compress >= 8)
              {
                index_for_compress = 0;
                //value2.add(value[0]);
                write_buffer[write_bufferPosition++] = value[0];
                if (write_bufferPosition==write_buffer.length)
                {
                  write_fp.writeFromSync(write_buffer, 0, write_bufferPosition);
                  write_bufferPosition = 0;
                }
              }
            }
          }
        }
      }
    }
    //将一整个数组写入文件中
    //write.add(value2);
    print('文件都读完了,doSomething() executed in ${stopwatch.elapsed}');
    print(index_for_compress);
    if (index_for_compress!=0){
      for (var num1=index_for_compress;num1<8;num1++)
        (value[0] &= (~(1 << ((num1) ^ 7))));
      var value4=Uint8List(2);
      value4[0]=value[0];
      value4[1]=(8-index_for_compress)&0xff;
      //write.add(value4);
      //write.close();
      write_buffer[write_bufferPosition++] = value4[0];
      print(write_bufferPosition);
      if (write_bufferPosition==write_buffer.length)
      {
        write_fp.writeFromSync(write_buffer, 0, write_bufferPosition);
        write_bufferPosition = 0;
      }
      write_buffer[write_bufferPosition++] = value4[1];
      print(write_bufferPosition);
      if (write_bufferPosition==write_buffer.length)
      {
        write_fp.writeFromSync(write_buffer, 0, write_bufferPosition);
        write_bufferPosition = 0;
      }
    }
    else if (index_for_compress==0)
    {
      var value4=Uint8List(1);
      value4[0]=0&0xff;
      //write.add(value4);
      //write.close();
      write_buffer[write_bufferPosition++] = value4[0];
      print(write_bufferPosition);
      if (write_bufferPosition==write_buffer.length)
      {
        write_fp.writeFromSync(write_buffer, 0, write_bufferPosition);
        write_bufferPosition = 0;
      }
    }
    if (write_bufferPosition>0)
    {
      write_fp.writeFromSync(write_buffer, 0, write_bufferPosition);
      print(write_bufferPosition);
    }


    write_fp.closeSync();
    read_file.closeSync();
    print('文件都读完了,doSomething() executed in ${stopwatch.elapsed}');
  }
}
// onData 可以替换掉listen方法
// listen.onData((data) {
// print("onData(),替换掉listen(),会调用多次");
//});

// 文件读完毕之后的回调
// listen.onDone(() {








//哈夫曼树节点类定义
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



