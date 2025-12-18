import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Renk sabitleri
const Color mainGreen = Color(0xFF2FB335);
const Color inputGrey = Color(0xFFF5F5F5);

// Label widget
Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black87,
      ),
    ),
  );
}

// Input box widget
Widget buildInputBox({
  required TextEditingController controller,
  String? hint,
  IconData? icon,
  bool isNumber = false,
  bool readOnly = false,
  VoidCallback? onTap,
  int? maxLength,
}) {
  return Container(
    decoration: BoxDecoration(
      color: inputGrey,
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLength: maxLength,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        hintText: hint,
        suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Bu alan boş bırakılamaz';
        }
        return null;
      },
    ),
  );
}

// Checkbox widget
Widget buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Checkbox(value: value, onChanged: onChanged, activeColor: mainGreen),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
