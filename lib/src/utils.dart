import 'dart:html' as html;

bool get isMobile {
  final toMatch = [
    'Android',
    'webOS',
    'iPhone',
    'iPad',
    'iPod',
    'BlackBerry',
    'Windows Phone'
  ];
  return toMatch.indexWhere((device) => html.window.navigator.userAgent
          .contains(RegExp(device, caseSensitive: false))) !=
      -1;
}
