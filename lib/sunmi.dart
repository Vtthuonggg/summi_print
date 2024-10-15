import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

class Sunmi {
  String image = 'http://103.72.98.44:3005/image';
  String error = 'xxx';
  // initialize sunmi printer
  Future<void> initialize() async {
    await SunmiPrinter.bindingPrinter();
    await SunmiPrinter.initPrinter();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
  }

  // print image
  Future<Map<String, String>> printLogoImage() async {
    await SunmiPrinter.lineWrap(1); // creates one line space
    String imagePath = await readFileBytesAibat(image);
    Uint8List byte1 = await readFileBytes(imagePath);
    await SunmiPrinter.printImage(byte1);
    await SunmiPrinter.lineWrap(1); // creates one line space
    return {'imagePath': imagePath, 'text': error};
  }

  Future<Uint8List> readFileBytes(String path) async {
    File file = File(path);
    Uint8List fileUnit8List = await file.readAsBytes();
    return fileUnit8List;
  }

  Future<String> readFileBytesAibat(String apiUrl) async {
    Map<String, dynamic> data = {
      "orderId": 9860,
      "userType": 2,
      "temp": 0,
      "width": 546
    };
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        // Extract the base64 string from the response body
        String base64String =
            response.body.toString().replaceAll("data:image/png;base64,", "");
        log(base64String.toString());

        Uint8List decodedBytes = base64Decode(base64String);

        // Get the application documents directory path
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String appDocPath = appDocDir.path;

        // Create a new file in the application documents directory
        String filePath = path.join(appDocPath, 'public', 'image.png');
        Directory publicDir = Directory(path.join(appDocPath, 'public'));
        if (!await publicDir.exists()) {
          await publicDir.create(recursive: true);
        }
        File file = File(filePath);

        // Write the decoded image data to the file
        await file.writeAsBytes(decodedBytes);

        log(filePath);
        return filePath;
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      log(e.toString());
      error = e.toString();
      return '';
    }
  }

  Future<void> openImage(String filePath) async {
    final result = await OpenFile.open(filePath);
    log(result.message);
  }

  Future<Uint8List> _getImageFromAsset(String iconPath) async {
    return await readFileBytes(iconPath);
  }

  // print text passed as parameter
  Future<void> printText(String text) async {
    await SunmiPrinter.lineWrap(1); // creates one line space
    await SunmiPrinter.printText(text,
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ));
    await SunmiPrinter.lineWrap(1); // creates one line space
  }

  // print text as qrcode
  Future<void> printQRCode(String text) async {
    // set alignment center
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.lineWrap(1); // creates one line space
    await SunmiPrinter.printQRCode(text);
    await SunmiPrinter.lineWrap(4); // creates one line space
  }

  // print row and 2 columns
  Future<void> printRowAndColumns(
      {String? column1 = "column 1",
      String? column2 = "column 2",
      String? column3 = "column 3"}) async {
    await SunmiPrinter.lineWrap(1); // creates one line space

    // set alignment center
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    // prints a row with 3 columns
    // total width of columns should be 30
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: "$column1",
        width: 10,
        align: SunmiPrintAlign.LEFT,
      ),
      ColumnMaker(
        text: "$column2",
        width: 10,
        align: SunmiPrintAlign.CENTER,
      ),
      ColumnMaker(
        text: "$column3",
        width: 10,
        align: SunmiPrintAlign.RIGHT,
      ),
    ]);
    await SunmiPrinter.lineWrap(1); // creates one line space
  }

  /* its important to close the connection with the printer once you are done */
  Future<void> closePrinter() async {
    await SunmiPrinter.unbindingPrinter();
  }

  // print one structure
  Future<Map<String, String>> printReceipt() async {
    await initialize();
    Map<String, String> imagePath = await printLogoImage();
    // await printText("Flutter is awesome");
    // await printRowAndColumns(
    //     column1: "Column 1", column2: "Column 2", column3: "Column 3");
    // await printQRCode("Dart is powerful");
    await SunmiPrinter.cut();
    await closePrinter();
    return imagePath;
  }
}
