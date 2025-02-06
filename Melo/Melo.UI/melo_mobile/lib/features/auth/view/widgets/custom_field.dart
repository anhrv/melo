import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;
  const CustomField(
      {super.key,
      required this.hintText,
      required this.controller,
      this.isObscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        constraints: const BoxConstraints(minHeight: 30),
      ),
      style: const TextStyle(
        fontSize: 14,
      ),
      obscureText: isObscureText,
    );
  }
}
