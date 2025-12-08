import 'package:flutter/material.dart';

// Renk sabitleri
const Color mainGreen = const Color(0xFF2FB335);
const Color inputGrey = const Color(0xFFE0E0E0);

Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 5),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
  );
}

Widget buildInputBox({
  required TextEditingController controller,
  String? hint,
  IconData? icon,
  bool isNumber = false,
  bool readOnly = false,
  VoidCallback? onTap, // Tıklama eventi
}) {
  return Container(
    decoration: BoxDecoration(
      color: inputGrey,
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        hintText: hint,
        suffixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
      ),
      validator: (val) => (val == null || val.isEmpty) ? "Zorunlu alan" : null,
    ),
  );
}

Widget buildCheckbox(String title, bool value, Function(bool?) onChanged) {
  return Column(
    children: [
      Transform.scale(
        scale: 0.8,
        child: Checkbox(
          value: value,
          activeColor: mainGreen,
          onChanged: onChanged,
          visualDensity: VisualDensity.compact,
        ),
      ),
      Text(title, style: const TextStyle(fontSize: 11)),
    ],
  );
}