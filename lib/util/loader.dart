import 'dart:async';
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

Future<String> loadFile({url, localPath, renewParentWidget}) async {
  final bytes = await _loadFileBytes(url,
      onError: (Exception exception) =>
          print('_loadFile => exception $exception'));

  final file = await localPath;

  await file.writeAsBytes(bytes);
  if (await file.exists()) {
    print(file.path);
    return file.path;
  } else {
    print('FILE NOT EXIST');
    return null;
  }
}
