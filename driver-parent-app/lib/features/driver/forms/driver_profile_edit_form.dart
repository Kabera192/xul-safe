import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/driver_profile_edit_mode.dart';
import '../models/driver_profile_model.dart';

class DriverProfileEditForm extends StatefulWidget {
  final DriverProfileEditMode mode;
  final DriverProfileModel profile;
  final Future<void> Function({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) onSave;
  final VoidCallback onCancel;

  const DriverProfileEditForm({
    super.key,
    required this.mode,
    required this.profile,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<DriverProfileEditForm> createState() => _DriverProfileEditFormState();
}

class _DriverProfileEditFormState extends State<DriverProfileEditForm> {
  static const blue = Color(0xFF0D4896);
  static const cancelBg = Color(0xFFEBF1FE);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.profile.firstName);
    _lastNameCtrl = TextEditingController(text: widget.profile.lastName);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.phoneNumber);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.mode) {
      case DriverProfileEditMode.fullName:
        return 'Edit Full Name';
      case DriverProfileEditMode.email:
        return 'Edit Email';
      case DriverProfileEditMode.phoneNumber:
        return 'Edit Phone Number';
      case DriverProfileEditMode.photo:
        return 'Edit Profile Picture';
    }
  }

  bool _isValidEmail(String value) {
    final emailRegex =
        RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
    return emailRegex.hasMatch(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      switch (widget.mode) {
        case DriverProfileEditMode.fullName:
          await widget.onSave(
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
          );
          break;

        case DriverProfileEditMode.email:
          await widget.onSave(email: _emailCtrl.text);
          break;

        case DriverProfileEditMode.phoneNumber:
          await widget.onSave(phoneNumber: _phoneCtrl.text);
          break;

        case DriverProfileEditMode.photo:
          break;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cancelBgColor = isDark ? const Color(0xFF1E3050) : cancelBg;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: _saving ? null : widget.onCancel,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cancelBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Image.asset(
                    'assests/backgrounds/mobile/edit_pen.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 2),
                SvgPicture.asset(
                  'assests/backgrounds/mobile/edit_pen_shadow.svg',
                  height: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                  Text(
                    _title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_error != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  Form(
                    key: _formKey,
                    child: Column(
                      children: _buildFields(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _saving ? 'Saving…' : 'Save changes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFields() {
    switch (widget.mode) {
      case DriverProfileEditMode.fullName:
        return [
          _EditInput(
            label: 'First name',
            controller: _firstNameCtrl,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'First name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _EditInput(
            label: 'Last name',
            controller: _lastNameCtrl,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
          ),
        ];

      case DriverProfileEditMode.email:
        return [
          _EditInput(
            label: 'Email',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Email is required';
              }
              if (!_isValidEmail(v.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ];

      case DriverProfileEditMode.phoneNumber:
        return [
          _EditInput(
            label: 'Phone number',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
        ];

      case DriverProfileEditMode.photo:
        return const [];
    }
  }
}

class _EditInput extends StatelessWidget {
  static const stroke = Color(0xFFDCE6F5);

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _EditInput({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0D4896);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final inputFill = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : stroke;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.done,
          scrollPadding: const EdgeInsets.only(bottom: 24),
          style: TextStyle(
            color: onSurface,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: blue,
                width: 1.3,
              ),
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
          validator: validator,
        ),
      ],
    );
  }
}