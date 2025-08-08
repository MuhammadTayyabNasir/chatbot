// lib/presentation/providers/platform_specific/file_handler_web.dart

import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;

/// Creates a downloadable URL from byte data and triggers a download.
String createAndDownloadFile(String fileName, Uint8List data) {
  try {
    // 1. Create a blob from the bytes
    final blob = html.Blob([data]);

    // 2. Create a URL that points to the blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 3. Create a temporary anchor element (`<a>`)
    final anchor = html.AnchorElement(href: url)
      ..style.display = 'none' // Make it invisible
      ..setAttribute('download', fileName); // Set the filename for the download

    // 4. Add it to the DOM, click it, and then remove it
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);

    // 5. Revoke the URL to free up memory
    html.Url.revokeObjectUrl(url);

    // We return the URL in case it's needed, but the primary action is the download.
    return url;
  } catch(e) {
    debugPrint("Error creating and downloading file on web: $e");
    return '';
  }
}