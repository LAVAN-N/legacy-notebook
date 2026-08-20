import 'dart:math';

class UuidUtils {
  static final Random _random = Random.secure();

  /// Generates a standard RFC 4122 version 4 UUID.
  static String generate() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    
    // Set the version to 4 (random)
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // Set the variant to RFC 4122
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    
    final buffer = StringBuffer();
    for (int i = 0; i < bytes.length; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
