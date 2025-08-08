// lib/presentation/providers/platform_specific/file_handler_interface.dart

// This is a conditional export.
// It tells the compiler to use 'file_handler_web.dart' if 'dart.library.html'
// is available (i.e., when compiling for web), otherwise use 'file_handler_stub.dart'.
export 'file_handler_stub.dart' if (dart.library.html) 'file_handler_web.dart';