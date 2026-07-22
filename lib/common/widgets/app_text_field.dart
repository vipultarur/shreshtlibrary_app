import 'package:flutter/material.dart';
import 'package:shreshtlibrary/core/theme/app_dimensions.dart';

enum AppTextFieldType { regular, password, search, multiline }

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.type = AppTextFieldType.regular,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final AppTextFieldType type;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget? buildSuffix() {
      if (widget.type == AppTextFieldType.password) {
        return IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        );
      }
      return widget.suffix;
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.type == AppTextFieldType.password && _obscureText,
      maxLines: widget.type == AppTextFieldType.multiline ? 3 : 1,
      validator: widget.validator,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.type == AppTextFieldType.search 
            ? const Icon(Icons.search) 
            : widget.prefix,
        suffixIcon: buildSuffix(),
      ),
    );
  }
}
