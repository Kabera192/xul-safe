import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/profile_service.dart';
import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';

import '../forms/driver_profile_form.dart';
import '../forms/driver_profile_edit_form.dart';
import '../forms/driver_profile_photo_form.dart';
import 'driver_bus_route_page.dart';
import '../models/driver_profile_edit_mode.dart';
import '../models/driver_profile_model.dart';

class DriverProfilePage extends StatefulWidget {
  final bool isActive;

  const DriverProfilePage({
    super.key,
    required this.isActive,
  });

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  final MobileFormController _formCtrl = MobileFormController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _alreadyScheduled = false;

  DriverProfileModel? _profile;
  Uint8List? _photoBytes;
  File? _selectedPhotoFile;

  bool _loading = false;
  bool _photoSaving = false;
  String? _error;
  String? _photoError;

  DriverProfileEditMode? _editMode;

  @override
  void didUpdateWidget(covariant DriverProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _scheduleShow();
      _loadProfile();
    }

    if (!widget.isActive && oldWidget.isActive) {
      _formCtrl.hide();
      _alreadyScheduled = false;
      _editMode = null;
      _selectedPhotoFile = null;
      _photoError = null;
    }
  }

  Future<void> _loadProfile() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profileJson = await ProfileService.getMyProfile();
      final profile = DriverProfileModel.fromApiResponse(profileJson);

      Uint8List? photoBytes;
      try {
        photoBytes = await ProfileService.getMyPhotoBytes();
      } catch (_) {
        photoBytes = null;
      }

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _photoBytes = photoBytes;
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

      if (!mounted || !widget.isActive) return;
      _showCurrentForm();
    });
  }

  void _refreshShownForm() {
    if (!mounted || !_alreadyScheduled || !widget.isActive) return;
    _showCurrentForm();
  }

  void _openEditForm(DriverProfileEditMode mode) {
    if (_profile == null) return;

    setState(() {
      _editMode = mode;
      if (mode != DriverProfileEditMode.photo) {
        _selectedPhotoFile = null;
        _photoError = null;
      }
    });

    _showCurrentForm();
  }

  void _closeEditForm() {
    setState(() {
      _editMode = null;
      _selectedPhotoFile = null;
      _photoError = null;
    });

    _showCurrentForm();
  }

  Future<void> _saveProfileChanges({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) async {
    final updatedJson = await ProfileService.updateMyProfile(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
    );

    final updated = DriverProfileModel.fromApiResponse(updatedJson);

    if (!mounted) return;

    setState(() {
      _profile = updated;
      _error = null;
      _editMode = null;
    });

    _showCurrentForm();
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null || !mounted) return;

      setState(() {
        _selectedPhotoFile = File(picked.path);
        _photoError = null;
      });

      _showCurrentForm();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _photoError = 'Could not pick image';
      });

      _showCurrentForm();
    }
  }

  Future<void> _savePhoto() async {
    final file = _selectedPhotoFile;

    if (file == null) {
      setState(() {
        _photoError = 'Please choose an image first';
      });
      _showCurrentForm();
      return;
    }

    setState(() {
      _photoSaving = true;
      _photoError = null;
    });

    _showCurrentForm();

    try {
      final updatedProfileJson = await ProfileService.uploadMyPhoto(file.path);
      final updatedProfile =
          DriverProfileModel.fromApiResponse(updatedProfileJson);

      Uint8List? updatedPhotoBytes;
      try {
        updatedPhotoBytes = await ProfileService.getMyPhotoBytes();
      } catch (_) {
        updatedPhotoBytes = null;
      }

      if (!mounted) return;

      setState(() {
        _profile = updatedProfile;
        _photoBytes = updatedPhotoBytes;
        _photoSaving = false;
        _selectedPhotoFile = null;
        _photoError = null;
        _editMode = null;
      });

      _showCurrentForm();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _photoSaving = false;
        _photoError = e.toString().replaceFirst('Exception: ', '');
      });

      _showCurrentForm();
    }
  }

  double _currentFormHeight() {
    final screenHeight = MediaQuery.of(context).size.height;

    if (_editMode == null) {
      return screenHeight * 0.55;
    }

    switch (_editMode!) {
      case DriverProfileEditMode.fullName:
        return screenHeight * 0.62;
      case DriverProfileEditMode.email:
        return screenHeight * 0.5;
      case DriverProfileEditMode.phoneNumber:
        return screenHeight * 0.5;
      case DriverProfileEditMode.photo:
        return screenHeight * 0.58;
    }
  }

  void _showCurrentForm() {
    final h = _currentFormHeight();

    final Widget child;

    if (_editMode == DriverProfileEditMode.photo) {
      child = DriverProfilePhotoForm(
        selectedImage: _selectedPhotoFile,
        saving: _photoSaving,
        error: _photoError,
        onPickPhoto: _pickPhoto,
        onSave: _savePhoto,
        onCancel: _closeEditForm,
      );
    } else if (_editMode != null && _profile != null) {
      child = DriverProfileEditForm(
        mode: _editMode!,
        profile: _profile!,
        onSave: ({
          String? firstName,
          String? lastName,
          String? email,
          String? phoneNumber,
        }) {
          return _saveProfileChanges(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
          );
        },
        onCancel: _closeEditForm,
      );
    } else {
      child = DriverProfileForm(
        profile: _profile,
        loading: _loading,
        error: _error,
        onEditTap: _openEditForm,
        onBusRouteTap: () {

          Navigator.of(context).push(

            MaterialPageRoute(

              builder: (_) => const DriverBusRoutePage(),

            ),

          );

        },
      );
    }

    _formCtrl.show(
      MobileFormShell(
        height: h,
        child: child,
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
    final formHeight = _currentFormHeight();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        svgAsset: 'assests/backgrounds/mobile/mobile_background_profile.svg',
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 40,
                child: _ProfilePictureCard(
                  photoBytes: _photoBytes,
                  onTap: () => _openEditForm(DriverProfileEditMode.photo),
                ),
              ),
              MobileAnimatedFormHost(
                controller: _formCtrl,
                height: formHeight,
                duration: const Duration(milliseconds: 400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilePictureCard extends StatelessWidget {
  static const blue = Color(0xFF0D4896);

  final Uint8List? photoBytes;
  final VoidCallback onTap;

  const _ProfilePictureCard({
    required this.photoBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoBytes != null && photoBytes!.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            children: [
              ClipRRect(
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
                  ),
                ),
              ),
              Center(
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
            ],
          ),
        ),
        Positioned(
          bottom: -22,
          child: Material(
            color: Colors.white,
            elevation: 4,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: const Text(
                  'Change photo',
                  style: TextStyle(
                    color: blue,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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