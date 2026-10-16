import 'package:flutter/material.dart';

/// Labeled, required-marked text field shared by the login and signup forms.
class AuthFieldInput extends StatefulWidget {
  final String label;
  final bool obscure;
  final bool showEye;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  const AuthFieldInput({
    super.key,
    required this.label,
    this.obscure = false,
    this.showEye = false,
    this.validator,
    this.controller,
  });

  @override
  State<AuthFieldInput> createState() => _AuthFieldInputState();
}

class _AuthFieldInputState extends State<AuthFieldInput> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inputFill = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2A3A50) : const Color(0xFFE0E0E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: TextStyle(
              color: onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _hidden,
          keyboardType: widget.label.toLowerCase().contains('email')
              ? TextInputType.emailAddress
              : TextInputType.text,
          style: TextStyle(color: onSurface, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            suffixIcon: widget.showEye
                ? IconButton(
                    icon: Icon(
                      _hidden
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: onSurface.withOpacity(0.5),
                    ),
                    onPressed: () => setState(() => _hidden = !_hidden),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: Color(0xFF0D4896), width: 1.3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
