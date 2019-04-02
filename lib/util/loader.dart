import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';

typedef void OnError(Exception exception);

Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
  Uint8List bytes;
  try {
    bytes = await readBytes(url);
  } on ClientException {
    rethrow;
  }
  return bytes;
}

Future<String> loadFile({String url, String path, renewParentWidget}) async {
  final bytes = await _loadFileBytes(url,
      onError: (Exception exception) =>
          print('loadFile => exception $exception'));

  final file = File(path);

  await file.writeAsBytes(bytes);
  if (await file.exists()) {
    print(file.path);
    return file.path;
  } else {
    print('FILE NOT EXIST');
    return null;
  }
}
