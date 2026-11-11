import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget buildFoodPhoto(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  if (path.startsWith('assets/')) {
    return Image.asset(path, fit: fit, width: width, height: height);
  }

  if (path.startsWith('data:image/')) {
    final separator = path.indexOf(',');
    if (separator > 0) {
      try {
        return Image.memory(
          base64Decode(path.substring(separator + 1)),
          fit: fit,
          width: width,
          height: height,
        );
      } on FormatException {
        return _invalidPhoto();
      }
    }
  }

  if (kIsWeb) {
    return Image.network(path, fit: fit, width: width, height: height);
  }
  return Image.file(File(path), fit: fit, width: width, height: height);
}

Widget _invalidPhoto() {
  return const ColoredBox(
    color: Color(0xFFF2E8DF),
    child: Center(child: Icon(Icons.broken_image_outlined)),
  );
}
