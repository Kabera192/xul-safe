import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../config/api_config.dart';

/// Resolves a `photoUrl` as stored by the backend/admin-frontend into an
/// [ImageProvider] Flutter can actually render.
///
/// `photoUrl` shows up in three different shapes depending on where it was
/// set:
///  - a full `data:image/...;base64,...` URI (the admin-frontend's photo
///    upload reads the file with FileReader.readAsDataURL and sends that
///    whole string as-is);
///  - an already-absolute `http(s)://...` URL;
///  - a backend-relative static path like `/uploads/driver-photos/x.jpg`
///    (what the mobile app's own photo uploads produce), which needs the
///    API host prefixed before it's fetchable.
///
/// A bare [NetworkImage] on any of the first or third forms either throws
/// (data: isn't a supported scheme) or 404s (no host), which is why photos
/// using this field were rendering as blank/broken.
ImageProvider? resolvePhotoProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;

  if (photoUrl.startsWith('data:')) {
    final commaIndex = photoUrl.indexOf(',');
    if (commaIndex == -1) return null;
    try {
      final bytes = base64Decode(photoUrl.substring(commaIndex + 1));
      return MemoryImage(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }

  if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) {
    return NetworkImage(photoUrl);
  }

  final path = photoUrl.startsWith('/') ? photoUrl : '/$photoUrl';
  return NetworkImage('${ApiConfig.baseUrl}$path');
}
