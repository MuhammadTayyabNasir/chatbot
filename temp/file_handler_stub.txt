// lib/presentation/providers/platform_specific/file_handler_stub.dart

import 'dart:typed_data';

/// The stub implementation for non-web platforms. Does nothing.
String createAndDownloadFile(String fileName, Uint8List data) {
  // This function is only needed for web, so it's a no-op on other platforms.
  throw UnimplementedError('createAndDownloadFile is only available on the web.');
}