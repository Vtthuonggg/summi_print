import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sunmi/sunmi.dart';

class SunmiScreen extends StatefulWidget {
  const SunmiScreen({Key? key}) : super(key: key);

  @override
  State<SunmiScreen> createState() => _SunmiScreenState();
}

class _SunmiScreenState extends State<SunmiScreen> {
  Map<String, String>? imagePath;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunmi Flutter Demo'),
      ),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(
              child: Text('Sunmi pos printer'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                Sunmi printer = Sunmi();
                imagePath = await printer.printReceipt();
                setState(() {
                  loading = false;
                });
              },
              child: !loading ? Text('Print') : CircularProgressIndicator(),
            ),
            if (imagePath != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(File(imagePath!['imagePath'] ?? '')),
              ),
            if (imagePath != null) Text(imagePath!['text'] ?? ''),
          ],
        ),
      ),
    );
  }
}
