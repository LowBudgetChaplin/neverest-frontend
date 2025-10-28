
/// It formats the big numbers in such way that after 1000 it will use 'empty space' as separator (ex: 100 000)
String manualFormatingWithSpace(int n) {
  final numberStr = n.toString();
  final formatted = StringBuffer();
  for (int i = 0; i < numberStr.length; i++) {
    final remainingDigits = numberStr.length - i;
    formatted.write(numberStr[i]);
    if (remainingDigits > 1 && remainingDigits % 3 == 1) formatted.write(' ');
  }
  return formatted.toString();
}

/// It formats the big numbers in such way that after 1000 it will use 'empty space' as separator (ex: 100.000)
String manualFormatingWithDot(int n) {
  final numberStr = n.toString();
  final formatted = StringBuffer();
  for (int i = 0; i < numberStr.length; i++) {
    final remainingDigits = numberStr.length - i;
    formatted.write(numberStr[i]);
    if (remainingDigits > 1 && remainingDigits % 3 == 1) formatted.write('.');
  }
  return formatted.toString();
}

/// It formats the big numbers in such way that after 1000 it will use 'empty space' as separator (ex: 100,000)
String manualFormatingWithComma(int n) {
  final numberStr = n.toString();
  final formatted = StringBuffer();
  for (int i = 0; i < numberStr.length; i++) {
    final remainingDigits = numberStr.length - i;
    formatted.write(numberStr[i]);
    if (remainingDigits > 1 && remainingDigits % 3 == 1) formatted.write(',');
  }
  return formatted.toString();
}