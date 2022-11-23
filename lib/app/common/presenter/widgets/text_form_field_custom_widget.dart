// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart' as validator;

class TextFormFieldCustomWidget extends StatelessWidget {
  TextEditingController controller;
  String label;
  TextInputType? keyboardType;
  String? Function(String?)? validator;
  bool obscureText;

  TextFormFieldCustomWidget({
    Key? key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    required this.obscureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          label: Text(label),
        ),
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
      ),
    );
  }
}

/*
 if (validator.isEmail(value ?? '')) {
            return 'Informe o email corretamente!';
          }
          return null;
        },*/
