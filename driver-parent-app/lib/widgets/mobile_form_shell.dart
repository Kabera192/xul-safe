import 'package:flutter/material.dart';

class MobileFormShell extends StatefulWidget {
  final double height;          // height decided by the page
  final Widget child;           // content decided by the page
  final EdgeInsets padding;     // default matches your auth forms
  final Widget? floatingActionButton;
  
  const MobileFormShell({
    super.key,
    required this.height,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
     this.floatingActionButton,
  });

  @override
  State<MobileFormShell> createState() => _MobileFormShellState();
}

class _MobileFormShellState extends State<MobileFormShell> {
  final _scrollCtrl = ScrollController();
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_updateScrollHint);

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
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF0D4896);
    final surface = Theme.of(context).colorScheme.surface;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
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

          // ===== main form panel =====
          Container(
            width: double.infinity,
            height: double.infinity,
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
                SingleChildScrollView(
                  controller: _scrollCtrl,
                  physics: const BouncingScrollPhysics(),

                  // Extra bottom padding ONLY if FAB exists
                  padding: widget.floatingActionButton != null
                      ? const EdgeInsets.only(bottom: 90)
                      : EdgeInsets.zero,

                  child: widget.child,
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