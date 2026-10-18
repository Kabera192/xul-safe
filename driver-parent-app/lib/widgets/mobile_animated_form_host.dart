import 'package:flutter/material.dart';
import 'mobile_form_controller.dart';

class MobileAnimatedFormHost extends StatefulWidget {
  final MobileFormController controller;
  final Duration duration;
  final double bottomSafeGap;

  const MobileAnimatedFormHost({
    super.key,
    required this.controller,
    this.duration = const Duration(milliseconds: 350),
    this.bottomSafeGap = 0,
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

    // The sheet is anchored to the actual screen bottom and sizes itself to
    // its own content (MobileFormShell caps that against the screen height
    // and scrolls internally if needed), so this host no longer needs to
    // know or constrain a height itself.
    return Positioned(
      left: 0,
      right: 0,
      bottom: widget.bottomSafeGap,
      child: SlideTransition(
        position: _slide,
        child: widget.controller.child!,
      ),
    );
  }
}
