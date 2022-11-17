import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Setting extends StatefulWidget {
  const Setting({super.key, required this.storeSetting});

  final Function storeSetting;

  @override
  State<StatefulWidget> createState() => SettingState();
}

class SettingState extends State<Setting> {
  TextEditingController backupController = TextEditingController();
  TextEditingController restoreController = TextEditingController();
  late final SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSP().then((value) {
      setState(() {
        backupController.text = prefs.getString('backupPath')!;
        restoreController.text = prefs.getString('restorePath')!;
      });
    });
  }

  Future<void> getSP() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width - 200,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: TextField(
                  controller: backupController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      labelText: "backup path",
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      hintText: "enter your backup path...",
                      hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black45, width: 1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black45, width: 1),
                          borderRadius: BorderRadius.circular(8.0)),
                      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 24)),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: TextField(
                  controller: restoreController,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      labelText: "restore path",
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      hintText: "enter your restore path...",
                      hintStyle: const TextStyle(fontStyle: FontStyle.italic),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black45, width: 1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black45, width: 1),
                          borderRadius: BorderRadius.circular(8.0)),
                      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 24)),
                ),
              )
            ],
          ),
        ));
  }
}
