import 'package:flutter/widgets.dart';

/// Watches app-wide focus changes and, whenever focus lands on a field
/// inside [scrollController]'s own `Scrollable`, scrolls that field into
/// view above the keyboard.
///
/// Pairs with a `Padding(bottom: viewInsets.bottom)` wrapped around the
/// scrollable so its viewport actually shrinks as the keyboard rises —
/// without that, "visible" is computed against the pre-keyboard viewport
/// and the scroll lands in the wrong place.
class KeyboardAwareScroller {
  final ScrollController scrollController;

  KeyboardAwareScroller(this.scrollController) {
    FocusManager.instance.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    final focusedContext = FocusManager.instance.primaryFocus?.context;
    if (focusedContext == null || !scrollController.hasClients) return;

    final scrollable = Scrollable.maybeOf(focusedContext);
    if (scrollable == null || scrollable.position != scrollController.position) {
      return;
    }

    // Give the keyboard-resize frame(s) a moment to settle before measuring.
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!focusedContext.mounted) return;
      Scrollable.ensureVisible(
        focusedContext,
        alignment: 0.1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void dispose() {
    FocusManager.instance.removeListener(_onFocusChanged);
  }
}
