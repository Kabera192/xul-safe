import 'dart:io';

import 'package:flutter/material.dart';

import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/child_service.dart';
import '../forms/parent_my_children_form.dart';

class ParentMyChildrenPage extends StatefulWidget {
  final bool isActive;

  const ParentMyChildrenPage({
    super.key,
    required this.isActive,
  });

  @override
  State<ParentMyChildrenPage> createState() => _ParentMyChildrenPageState();
}

class _ParentMyChildrenPageState extends State<ParentMyChildrenPage> {
  final MobileFormController _formCtrl = MobileFormController();
  bool _alreadyScheduled = false;
  Key _formKey = UniqueKey();

  @override
  void didUpdateWidget(covariant ParentMyChildrenPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _scheduleShow();
    }

    if (!widget.isActive && oldWidget.isActive) {
      _formCtrl.hide();
      _alreadyScheduled = false;
    }
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;
    _alreadyScheduled = true;

    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1));
      if (!mounted || !widget.isActive) return;

      final h = MediaQuery.of(context).size.height * 0.8;

      _formCtrl.show(
        MobileFormShell(
          height: h,
          child: ParentMyChildrenForm(
            key: _formKey,
            onRequestRefresh: _refreshForm,
          ),
          floatingActionButton: _AddChildFab(
            onTap: _showAddChildDialog,
          ),
        ),
      );
    });
  }

  // Swaps the form in-place with a new key so initState re-runs and reloads the list.
  // Does NOT hide first — avoids the 400ms animation race condition.
  void _refreshForm() {
    if (!mounted) return;
    setState(() => _formKey = UniqueKey());
    final h = MediaQuery.of(context).size.height * 0.8;
    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: ParentMyChildrenForm(
          key: _formKey,
          onRequestRefresh: _refreshForm,
        ),
        floatingActionButton: _AddChildFab(
          onTap: _showAddChildDialog,
        ),
      ),
    );
  }

  Future<void> _showAddChildDialog() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();
    String? selectedGender;
    DateTime? selectedBirthDate;
    File? selectedPhoto;
    bool saving = false;
    String? sheetError;
    bool added = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final surface = Theme.of(ctx).colorScheme.surface;
          final onSurface = Theme.of(ctx).colorScheme.onSurface;
          final inputFill =
              isDark ? const Color(0xFF1A2530) : const Color(0xFFF6F9FE);
          final borderColor =
              isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
          final backBg =
              isDark ? const Color(0xFF1E3050) : const Color(0xFFEBF1FE);
          final keyboard = MediaQuery.of(ctx).viewInsets.bottom;

          Widget inputBox({
            required TextEditingController controller,
            required String label,
            String? hint,
            String? Function(String?)? validator,
          }) {
            return TextFormField(
              controller: controller,
              validator: validator,
              style: TextStyle(color: onSurface, fontSize: 14.5),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                filled: true,
                fillColor: inputFill,
                labelStyle: TextStyle(color: onSurface.withOpacity(0.55)),
                hintStyle: TextStyle(color: onSurface.withOpacity(0.35)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF0D4896), width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
              ),
            );
          }

          return Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(22, 0, 22, keyboard + 16),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header row ──────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 16),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: saving
                                    ? null
                                    : () => Navigator.of(ctx).pop(),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: backBg,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 16,
                                    color: onSurface,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Container(
                                    width: 36,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: onSurface.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 34),
                            ],
                          ),
                        ),
                        // ── Icon ────────────────────────────────────────
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D4896).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            IconsaxPlusLinear.user_add,
                            color: Color(0xFF0D4896),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add a child',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: onSurface),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Fill in the details below to register your child.',
                          style: TextStyle(
                              color: onSurface.withOpacity(0.5),
                              fontSize: 13),
                        ),
                        const SizedBox(height: 22),
                        // ── Photo (optional) ─────────────────────────────
                        GestureDetector(
                          onTap: saving
                              ? null
                              : () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 85);
                                  if (picked != null) {
                                    set(() =>
                                        selectedPhoto = File(picked.path));
                                  }
                                },
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1A2530)
                                  : const Color(0xFFF1F5FA),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: borderColor.withOpacity(0.8),
                                  width: 1.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: selectedPhoto != null
                                  ? Image.file(selectedPhoto!,
                                      fit: BoxFit.cover,
                                      width: double.infinity)
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                            IconsaxPlusLinear.gallery_add,
                                            size: 32,
                                            color:
                                                onSurface.withOpacity(0.35)),
                                        const SizedBox(height: 8),
                                        Text('Add photo (optional)',
                                            style: TextStyle(
                                                color: onSurface
                                                    .withOpacity(0.45),
                                                fontSize: 13)),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // ── Full name ────────────────────────────────────
                        inputBox(
                          controller: nameCtrl,
                          label: 'Full name *',
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        // ── Date of birth ────────────────────────────────
                        FormField<DateTime>(
                          initialValue: selectedBirthDate,
                          validator: (_) => selectedBirthDate == null
                              ? 'Date of birth is required'
                              : null,
                          builder: (field) {
                            final hasDate = selectedBirthDate != null;
                            return InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: DateTime(2015),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  set(() => selectedBirthDate = picked);
                                  field.didChange(picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 14),
                                decoration: BoxDecoration(
                                  color: inputFill,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: field.errorText != null
                                        ? Colors.red
                                        : borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        hasDate
                                            ? '${selectedBirthDate!.year}-'
                                                '${selectedBirthDate!.month.toString().padLeft(2, '0')}-'
                                                '${selectedBirthDate!.day.toString().padLeft(2, '0')}'
                                            : 'Date of birth *',
                                        style: TextStyle(
                                          color: hasDate
                                              ? onSurface
                                              : onSurface.withOpacity(0.45),
                                          fontSize: 14.5,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      IconsaxPlusLinear.calendar_1,
                                      size: 18,
                                      color: onSurface.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        // ── Gender picker ────────────────────────────────
                        Container(
                          decoration: BoxDecoration(
                            color: inputFill,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              for (final g in ['MALE', 'FEMALE'])
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        set(() => selectedGender = g),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 11),
                                      decoration: BoxDecoration(
                                        color: selectedGender == g
                                            ? const Color(0xFF0D4896)
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(9),
                                      ),
                                      child: Center(
                                        child: Text(
                                          g == 'MALE' ? 'Male' : 'Female',
                                          style: TextStyle(
                                            color: selectedGender == g
                                                ? Colors.white
                                                : onSurface.withOpacity(0.6),
                                            fontWeight: selectedGender == g
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // ── Grade ────────────────────────────────────────
                        inputBox(
                          controller: gradeCtrl,
                          label: 'Grade *',
                          hint: 'e.g. Grade 3',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Required';
                            }
                            final match = RegExp(
                              r'^Grade\s+(\d+)$',
                            ).firstMatch(v.trim());
                            if (match == null) {
                              return 'Use format: Grade 3';
                            }
                            final n = int.parse(match.group(1)!);
                            if (n < 1 || n > 13) {
                              return 'Grade must be between 1 and 13';
                            }
                            return null;
                          },
                        ),
                        if (sheetError != null) ...[
                          const SizedBox(height: 12),
                          Text(sheetError!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13)),
                        ],
                        const SizedBox(height: 22),
                        // ── Buttons ──────────────────────────────────────
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: saving
                                ? null
                                : () async {
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }
                                    set(() {
                                      saving = true;
                                      sheetError = null;
                                    });
                                    final birthDateStr =
                                        selectedBirthDate != null
                                            ? '${selectedBirthDate!.year}-'
                                                '${selectedBirthDate!.month.toString().padLeft(2, '0')}-'
                                                '${selectedBirthDate!.day.toString().padLeft(2, '0')}'
                                            : null;
                                    try {
                                      final newChild =
                                          await ChildService.addChild(
                                        fullName: nameCtrl.text,
                                        birthDate: birthDateStr,
                                        gender: selectedGender,
                                        grade: gradeCtrl.text.trim(),
                                      );
                                      // Upload photo if selected
                                      if (selectedPhoto != null) {
                                        final childId =
                                            newChild['id']?.toString() ?? '';
                                        if (childId.isNotEmpty) {
                                          try {
                                            await ChildService
                                                .uploadChildPhoto(
                                              childId: childId,
                                              imageFile: selectedPhoto!,
                                            );
                                          } catch (_) {
                                            // Photo upload failure is non-fatal
                                          }
                                        }
                                      }
                                      added = true;
                                      if (ctx.mounted) {
                                        Navigator.of(ctx).pop();
                                      }
                                    } catch (e) {
                                      set(() {
                                        saving = false;
                                        sheetError = e
                                            .toString()
                                            .replaceFirst('Exception: ', '');
                                      });
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D4896),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Text(
                                    'Add child',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          );
        },
      ),
    );

    if (added && mounted) {
      _refreshForm();
    }
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formHeight = MediaQuery.of(context).size.height * 0.8;
    final media = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            children: [
              const Positioned(
                top: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'My Children',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // ✅ ignores keyboard like notifications
              MediaQuery(
                data: media.copyWith(viewInsets: EdgeInsets.zero),
                child: MobileAnimatedFormHost(
                  controller: _formCtrl,
                  height: formHeight,
                  duration: const Duration(milliseconds: 400),
                  respectKeyboard: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChildFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddChildFab({required this.onTap});

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: blue,
      elevation: 6,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Center(
            child: Icon(
              IconsaxPlusLinear.user_add,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}