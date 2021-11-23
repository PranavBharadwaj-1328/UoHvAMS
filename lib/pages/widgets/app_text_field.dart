import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  AppTextField(
      {Key key,
      @required this.labelText,
      @required this.controller,
      this.keyboardType = TextInputType.text,
      this.autofocus = false,
      this.isPassword = false})
      : super(key: key);

  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool autofocus;
  final bool isPassword;

  validate(String text) {
    if (text.length == 0 || text.isEmpty) {
      return "Field cannot be empty.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      autofocus: this.autofocus,
      cursorColor: Color(0xFF5BC8AA),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field cannot be empty';
        }
        return null;
      },
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: labelText,

        border: InputBorder.none,
        // errorText: validate(this.controller.text),
        filled: true,
        fillColor: Colors.grey[200],
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: const BorderRadius.all(
            const Radius.circular(10.0),
          ),
        ),
      ),
      obscureText: isPassword,
      keyboardType: keyboardType,
    );
  }
}
