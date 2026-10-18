import 'package:flutter/material.dart';

import '../../../widgets/mobile_splash_gradient.dart';
import '../../../widgets/mobile_form_shell.dart';
import '../../../widgets/mobile_animated_form_host.dart';
import '../../../widgets/mobile_form_controller.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../forms/parent_add_child_form.dart';
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

      _formCtrl.show(
        MobileFormShell(
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
    _formCtrl.show(
      MobileFormShell(
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
    final newChild = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const ParentAddChildForm(),
    );

    if (newChild != null && mounted) {
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

              MobileAnimatedFormHost(
                controller: _formCtrl,
                duration: const Duration(milliseconds: 400),
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
