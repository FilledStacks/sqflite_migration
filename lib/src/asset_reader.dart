import 'package:flutter/services.dart' show rootBundle;

/// An abstraction over the root bundle to remove hard dependency on flutter runtime
/// for unit tests
class AssetReader {
  Future<String> readFileFromBundle(String file) {
    return rootBundle.loadString('assets/sql/$file');
  }
}
