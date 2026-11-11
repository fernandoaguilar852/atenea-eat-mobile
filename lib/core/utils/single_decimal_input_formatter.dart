import 'package:flutter/services.dart';

/// Permite solo dígitos y un único separador decimal (. o ,).
class SingleDecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (!RegExp(r'^[0-9.,]*$').hasMatch(text)) return oldValue;
    if (RegExp(r'[.,]').allMatches(text).length > 1) return oldValue;
    return newValue;
  }
}

/// Convierte texto con coma o punto decimal a double (la coma se envía como punto).
double? parseDecimal(String text) =>
    double.tryParse(text.trim().replaceAll(',', '.'));

/// Muestra el número sin ceros sobrantes (100.0 -> 100, 100.5 -> 100.5).
String formatDecimal(double value) =>
    value == value.truncateToDouble() ? value.toInt().toString() : value.toString();
