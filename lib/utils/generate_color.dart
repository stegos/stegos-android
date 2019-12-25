import 'dart:ui';

Color textToAvatarColour(String text) {
  final int c = (text.hashCode & 0xffffff) | 0xFF444444;
  return Color(c);
}
