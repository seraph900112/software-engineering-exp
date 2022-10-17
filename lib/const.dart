import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Const{
  static Future<Directory> backupDir = getApplicationDocumentsDirectory() ;
}