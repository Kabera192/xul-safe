import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/child_model.dart';



class DriverIncidentStudentSelectionForm extends StatefulWidget {
  final String incidentType;
  final List<ChildModel> children;
  final bool loading;
  final String? error;
  final VoidCallback onClose;
  final void Function(Set<String> childIds) onContinue;

  const DriverIncidentStudentSelectionForm({
    super.key,
    required this.incidentType,
    required this.children,
    required this.loading,
    required this.error,
    required this.onClose,
    required this.onContinue,
  });

  @override
  State<DriverIncidentStudentSelectionForm> createState() =>
      _DriverIncidentStudentSelectionFormState();
}

class _DriverIncidentStudentSelectionFormState
    extends State<DriverIncidentStudentSelectionForm> {
  static const _blue = Color(0xFF0D4896);
  static const _stroke = Color(0xFFDCE6F5);
  static const _closeBackground = Color(0xFFEBF1FE);

  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ChildModel> get _filteredChildren {
    final query = _searchCtrl.text.trim().toLowerCase();

    final children = [...widget.children]
      ..sort(
        (a, b) => _displayName(a)
            .toLowerCase()
            .compareTo(_displayName(b).toLowerCase()),
      );

    if (query.isEmpty) {
      return children;
    }

    return children
        .where(
          (child) => _displayName(child)
              .toLowerCase()
              .contains(query),
        )
        .toList();
  }

  String get _title {
    switch (widget.incidentType) {
      case 'MEDICAL':
        return 'Select affected students';

      case 'CHILD_BEHAVIOR':
        return 'Select involved students';

      default:
        return 'Select students';
    }
  }

  String get _subtitle {
    switch (widget.incidentType) {
      case 'MEDICAL':
        return 'Choose the student or students affected by the medical incident.';

      case 'CHILD_BEHAVIOR':
        return 'Choose the student or students involved in the behavior incident.';

      default:
        return 'Choose the affected students.';
    }
  }

  IconData get _titleIcon {
    switch (widget.incidentType) {
      case 'MEDICAL':
        return IconsaxPlusLinear.health;

      case 'CHILD_BEHAVIOR':
        return IconsaxPlusLinear.people;

      default:
        return IconsaxPlusLinear.people;
    }
  }

  String _displayName(ChildModel child) {
    if (child.fullName.trim().isNotEmpty) {
      return child.fullName.trim();
    }

    final fallback =
        '${child.firstName} ${child.lastName}'.trim();

    return fallback.isEmpty ? 'Unnamed child' : fallback;
  }

  void _toggleChild(String childId) {
    setState(() {
      if (_selectedIds.contains(childId)) {
        _selectedIds.remove(childId);
      } else {
        _selectedIds.add(childId);
      }
    });
  }

  void _continue() {
    if (_selectedIds.isEmpty) return;

    widget.onContinue(
      Set<String>.from(_selectedIds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final onSurface =
        Theme.of(context).colorScheme.onSurface;

    final children = _filteredChildren;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Close ────────────────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: _closeBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: widget.onClose,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: _blue,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Heading ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _titleIcon,
                color: _blue,
                size: 26,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Search ───────────────────────────────────────────────────
          _SearchBox(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 12),

          // ── Selected count ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              _selectedIds.isEmpty
                  ? 'Select at least one student'
                  : '${_selectedIds.length} selected',
              style: TextStyle(
                color: _selectedIds.isEmpty
                    ? onSurface.withValues(alpha: 0.45)
                    : _blue,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── List ─────────────────────────────────────────────────────
          if (widget.loading)
            const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (widget.error != null)
            SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  widget.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else if (children.isEmpty)
            SizedBox(
              height: 300,
              child: Center(
                child: Text(
                  widget.children.isEmpty
                      ? 'No children are assigned to this bus'
                      : 'No matching children',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.45),
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 300,
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                itemCount: children.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final child = children[index];
                  final selected =
                      _selectedIds.contains(child.id);

                  return _StudentRow(
                    child: child,
                    selected: selected,
                    onTap: () => _toggleChild(child.id),
                  );
                },
              ),
            ),

          const SizedBox(height: 18),

          // ── Continue ─────────────────────────────────────────────────
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed:
                  _selectedIds.isEmpty ? null : _continue,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    _blue.withValues(alpha: 0.35),
                disabledForegroundColor:
                    Colors.white.withValues(alpha: 0.75),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final ChildModel child;
  final bool selected;
  final VoidCallback onTap;

  const _StudentRow({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  static const _blue = Color(0xFF0D4896);
  static const _stroke = Color(0xFFDCE6F5);

  String get _name {
    if (child.fullName.trim().isNotEmpty) {
      return child.fullName.trim();
    }

    final fallback =
        '${child.firstName} ${child.lastName}'.trim();

    return fallback.isEmpty ? 'Unnamed child' : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final onSurface =
        Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? _blue.withValues(
                    alpha: isDark ? 0.18 : 0.06,
                  )
                : isDark
                    ? const Color(0xFF1A2530)
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? _blue
                  : isDark
                      ? const Color(0xFF2A3A50)
                      : _stroke,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _Avatar(
                photoUrl: child.photoUrl,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  _name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color:
                      selected ? _blue : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? _blue
                        : onSurface.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
  });

  static const _blue = Color(0xFF0D4896);
  static const _stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final onSurface =
        Theme.of(context).colorScheme.onSurface;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A2530)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A3A50)
              : _stroke,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            IconsaxPlusLinear.search_normal_1,
            color: _blue,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search a child',
                hintStyle: TextStyle(
                  color:
                      onSurface.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? photoUrl;

  const _Avatar({
    required this.photoUrl,
  });

  static const _blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    // Keep the same current avatar treatment as the attendance list.
    // Actual child-photo rendering can remain a separate improvement.
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: _blue,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}