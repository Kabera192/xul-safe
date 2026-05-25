import 'package:flutter/material.dart';
import 'mobile_form_controller.dart';

class MobileAnimatedFormHost extends StatefulWidget {
  final MobileFormController controller;
  final double height;
  final Duration duration;
  final double bottomSafeGap;

  // ✅ NEW: allow some pages to ignore keyboard inset
  final bool respectKeyboard;

  const MobileAnimatedFormHost({
    super.key,
    required this.controller,
    required this.height,
    this.duration = const Duration(milliseconds: 350),
    this.bottomSafeGap = 0,
    this.respectKeyboard = true, // ✅ default keeps old behavior
  });

  @override
  State<MobileAnimatedFormHost> createState() => _MobileAnimatedFormHostState();
}

class _MobileAnimatedFormHostState extends State<MobileAnimatedFormHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<Offset> _slide;

  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(vsync: this, duration: widget.duration);

    _slide = Tween<Offset>(
      begin: const Offset(0, 1), // from bottom (off-screen)
      end: Offset.zero,          // to normal position
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

    widget.controller.addListener(_handleController);
  }

  @override
  void didUpdateWidget(covariant MobileAnimatedFormHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _anim.duration = widget.duration;
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleController);
      widget.controller.addListener(_handleController);
    }
  }

  Future<void> _handleController() async {
    // show requested
    if (widget.controller.showing && !_visible) {
      setState(() => _visible = true);
      _anim.value = 0;
      await _anim.forward();
      return;
    }

    // hide requested
    if (!widget.controller.showing && _visible) {
      await _anim.reverse();
      if (!mounted) return;
      setState(() => _visible = false);
      return;
    }

    // swap requested while visible:
    // if controller is showing AND already visible,
    // just rebuild with new child (no slide).
    // For a true "swap animation", use swapForm() helper below.
    setState(() {});
  }

  /// Call this from the page to animate swap:
  /// old slides down, new slides up.
  Future<void> swapForm(Widget newChild) async {
    if (!_visible) {
      widget.controller.show(newChild);
      return;
    }

    await _anim.reverse();
    if (!mounted) return;

    widget.controller.setChildInternal(newChild);

    _anim.value = 0;
    await _anim.forward();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleController);
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || widget.controller.child == null) {
      return const SizedBox.shrink();
    }

    final media = MediaQuery.of(context);
    final keyboard = widget.respectKeyboard
        ? media.viewInsets.bottom
        : 0.0;
    final screenH = media.size.height;

    // How much vertical space is left when keyboard is up
    final availableH = screenH - keyboard - widget.bottomSafeGap;

    // If requested height is bigger than available, shrink it
    final effectiveH = widget.height > availableH
        ? availableH
        : widget.height;

    return Positioned(
      left: 0,
      right: 0,
      bottom: keyboard + widget.bottomSafeGap,
      child: SlideTransition(
        position: _slide,
        child: SizedBox(
          height: effectiveH,
          child: widget.controller.child!,
        ),
      ),
    );
  }
}