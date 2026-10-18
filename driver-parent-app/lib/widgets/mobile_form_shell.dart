import 'package:flutter/material.dart';

import 'keyboard_aware_scroller.dart';

/// Sheet-style form container that sizes itself to [child]'s actual content,
/// instead of a fixed height the page has to guess. Content shorter than
/// [maxHeightFraction] of the screen fits exactly; content taller than that
/// scrolls internally instead of growing further.
class MobileFormShell extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final Widget? floatingActionButton;
  final double maxHeightFraction;
  final double minHeight;

  const MobileFormShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.floatingActionButton,
    this.maxHeightFraction = 0.86,
    this.minHeight = 160,
  });

  @override
  State<MobileFormShell> createState() => _MobileFormShellState();
}

class _MobileFormShellState extends State<MobileFormShell> {
  final _scrollCtrl = ScrollController();
  bool _canScrollDown = false;
  late final KeyboardAwareScroller _keyboardScroller;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_updateScrollHint);
    _keyboardScroller = KeyboardAwareScroller(_scrollCtrl);

    // wait one frame so scroll metrics exist
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  void _updateScrollHint() {
    if (!_scrollCtrl.hasClients) return;

    final max = _scrollCtrl.position.maxScrollExtent;
    final offset = _scrollCtrl.offset;

    final canDown = max > 0 && offset < max - 2; // small tolerance
    if (canDown != _canScrollDown) {
      setState(() => _canScrollDown = canDown);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_updateScrollHint);
    _keyboardScroller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MobileFormShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Content swapped in place (same shell instance, new child) — the
    // scroll-down hint needs re-measuring against the new content height.
    if (oldWidget.child != widget.child) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
    }
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0D4896);
    final surface = Theme.of(context).colorScheme.surface;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight =
        MediaQuery.of(context).size.height * widget.maxHeightFraction;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.minHeight,
        maxHeight: maxHeight,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // ===== glassy top shadow panel =====
          Positioned(
            top: -18,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.92,
              height: 60,
              decoration: BoxDecoration(
                color: surface.withOpacity(0.30),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 26,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),

          // ===== main form panel — sized to content, capped above =====
          Container(
            width: double.infinity,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),

            // internal scrolling only
            child: Stack(
              children: [
                // ===== scrollable content =====
                // The bottom padding shrinks this viewport by the keyboard
                // inset so focused fields can actually scroll into view
                // above the keyboard instead of behind it. ListView (unlike
                // SingleChildScrollView, whose viewport always fills its
                // parent's bound) genuinely shrink-wraps to content height,
                // up to the ConstrainedBox cap above, scrolling beyond that.
                Padding(
                  padding: EdgeInsets.only(bottom: keyboardInset),
                  child: ListView(
                    controller: _scrollCtrl,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),

                    // Extra bottom padding ONLY if FAB exists
                    padding: widget.floatingActionButton != null
                        ? const EdgeInsets.only(bottom: 90)
                        : EdgeInsets.zero,

                    children: [widget.child],
                  ),
                ),

                // ===== floating button (optional) =====
                if (widget.floatingActionButton != null)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: widget.floatingActionButton!,
                  ),
              ],
            ),
          ),

          // ===== scroll-down hint =====
          if (_canScrollDown)
            Positioned(
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Scroll down ↓",
                  style: TextStyle(
                    color: blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
