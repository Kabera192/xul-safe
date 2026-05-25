import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../services/child_service.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_splash_gradient.dart';

import '../forms/driver_child_profile_form.dart';
import '../models/child_model.dart';

class DriverChildProfilePage extends StatefulWidget {
  final int childId;

  const DriverChildProfilePage({
    super.key,
    required this.childId,
  });

  @override
  State<DriverChildProfilePage> createState() => _DriverChildProfilePageState();
}

class _DriverChildProfilePageState extends State<DriverChildProfilePage> {
  final MobileFormController _formCtrl = MobileFormController();

  bool _alreadyScheduled = false;
  bool _loading = false;
  String? _error;

  ChildModel? _child;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _scheduleShow();
    _loadChild();
  }

  Future<void> _loadChild() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final json = await ChildService.getMyBusChildById(widget.childId);
      final child = ChildModel.fromApiResponse(json);

      if (!mounted) return;

      setState(() {
        _child = child;
        _photoBytes = null;
      });

      _refreshShownForm();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });

      _refreshShownForm();
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _refreshShownForm();
    }
  }

  void _scheduleShow() {
    if (_alreadyScheduled) return;
    _alreadyScheduled = true;

    Future.microtask(() async {
      await Future.delayed(const Duration(milliseconds: 1));

      if (!mounted) return;
      _showCurrentForm();
    });
  }

  void _refreshShownForm() {
    if (!mounted || !_alreadyScheduled) return;
    _showCurrentForm();
  }

  void _showCurrentForm() {
    final h = MediaQuery.of(context).size.height * 0.62;

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: DriverChildProfileForm(
          child: _child,
          loading: _loading,
          error: _error,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _formCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formHeight = MediaQuery.of(context).size.height * 0.62;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 14,
                left: 12,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Positioned(
                top: 38,
                child: _ChildPictureCard(photoBytes: _photoBytes),
              ),
              MobileAnimatedFormHost(
                controller: _formCtrl,
                height: formHeight,
                duration: const Duration(milliseconds: 400),
                respectKeyboard: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildPictureCard extends StatelessWidget {
  final Uint8List? photoBytes;

  const _ChildPictureCard({
    required this.photoBytes,
  });

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoBytes != null && photoBytes!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: hasPhoto
                ? ClipOval(
                    child: Image.memory(
                      photoBytes!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackAvatar(),
                    ),
                  )
                : _fallbackAvatar(),
          ),
        ),
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: blue,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}