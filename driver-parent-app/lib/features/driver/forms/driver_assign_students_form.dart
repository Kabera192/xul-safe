import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../models/child_model.dart';

class DriverAssignStudentsForm extends StatefulWidget {
  final int stopId;
  final List<ChildModel> children;
  final Future<void> Function(List<int> childIds) onComplete;
  final VoidCallback onCancel;

  const DriverAssignStudentsForm({
    super.key,
    required this.stopId,
    required this.children,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<DriverAssignStudentsForm> createState() =>
      _DriverAssignStudentsFormState();
}

class _DriverAssignStudentsFormState extends State<DriverAssignStudentsForm> {
  static const blue = Color(0xFF0D4896);
  // static const assignBlue = Color(0xFF145CB8);
  // static const assignBlueBg = Color(0xFFEAF2FF);
  // static const reassignYellow = Color(0xFFF8AD04);
  // static const reassignYellowBg = Color(0xFFFFF5D9);
  // static const assigningGreen = Color(0xFF21C260);
  // static const assigningGreenBg = Color(0xFFE8F9EF);
  static const stroke = Color(0xFFDCE6F5);
  static const inputBg = Color(0xFFF5F8FB);

  final _searchCtrl = TextEditingController();
  final Set<int> _selectedChildIds = {};

  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ChildModel> get _eligibleChildren {
    return widget.children.where((child) {
      final alreadyOnThisStop =
          child.pickupStopId == widget.stopId && child.dropoffStopId == widget.stopId;

      return !alreadyOnThisStop;
    }).toList();
  }

  List<ChildModel> get _filteredChildren {
    final query = _searchCtrl.text.trim().toLowerCase();

    final base = _eligibleChildren;

    if (query.isEmpty) return base;

    return base.where((child) {
      return child.fullName.toLowerCase().contains(query) ||
          child.firstName.toLowerCase().contains(query) ||
          child.lastName.toLowerCase().contains(query);
    }).toList();
  }

  bool _isReassign(ChildModel child) {
    return child.pickupStopId != null || child.dropoffStopId != null;
  }

  void _toggleChild(ChildModel child) {
    if (_saving) return;

    setState(() {
      if (_selectedChildIds.contains(child.id)) {
        _selectedChildIds.remove(child.id);
      } else {
        _selectedChildIds.add(child.id);
      }
      _error = null;
    });
  }

  Future<void> _complete() async {
    if (_selectedChildIds.isEmpty) {
      setState(() {
        _error = 'Please select at least one student';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onComplete(_selectedChildIds.toList());
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
      
    final children = _filteredChildren;
    

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: InkWell(
              onTap: _saving ? null : widget.onCancel,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF1FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Assign students',
            style: TextStyle(
              color: Color(0xFF001B3D),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _searchCtrl,
            enabled: !_saving,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: inputBg,
              hintText: 'Search a name',
              hintStyle: const TextStyle(
                color: Colors.black45,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              suffixIcon: const Icon(
                IconsaxPlusLinear.search_normal_1,
                color: blue,
                size: 18,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: stroke, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: const BorderSide(color: blue, width: 1.2),
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (_error != null) ...[
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],

          SizedBox(
  height: MediaQuery.of(context).size.height * 0.32,
  child: Stack(
    children: [
      if (children.isEmpty)
        const _EmptyStudentsCard()
      else
        ListView.separated(
          padding: const EdgeInsets.only(bottom: 34),
          physics: const ClampingScrollPhysics(),
          itemCount: children.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final child = children[index];
            final selected = _selectedChildIds.contains(child.id);
            final reassign = _isReassign(child);

            return _StudentAssignRow(
              child: child,
              selected: selected,
              reassign: reassign,
              onTap: () => _toggleChild(child),
            );
          },
        ),

      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: IgnorePointer(
          child: Container(
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0),
                  Colors.white,
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
          const SizedBox(height: 12),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _complete,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                disabledBackgroundColor: blue.withOpacity(0.45),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                _saving ? 'Saving…' : 'Complete changes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
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

class _StudentAssignRow extends StatelessWidget {
  final ChildModel child;
  final bool selected;
  final bool reassign;
  final VoidCallback onTap;

  const _StudentAssignRow({
    required this.child,
    required this.selected,
    required this.reassign,
    required this.onTap,
  });

  static const assignBlue = Color(0xFF145CB8);
  static const assignBlueBg = Color.fromARGB(255, 206, 225, 254);
  static const reassignYellow = Color(0xFFF8AD04);
  static const reassignYellowBg = Color.fromARGB(255, 255, 238, 188);
  static const assigningGreen = Color(0xFF21C260);
  static const assigningGreenBg = Color.fromARGB(255, 210, 255, 229);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    final buttonText = selected ? 'Assigning' : (reassign ? 'Re-assign' : 'Assign');
    final buttonColor = selected ? assigningGreen : (reassign ? reassignYellow : assignBlue);
    final buttonBg = selected ? assigningGreenBg : (reassign ? reassignYellowBg : assignBlueBg);
    final buttonIcon = selected ? Icons.check : IconsaxPlusLinear.add;

    return Container(
  constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: stroke, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          _StudentAvatar(photoUrl: child.photoUrl),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              child.fullName.isEmpty ? 'Unnamed student' : child.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF001B3D),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: buttonBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    buttonIcon,
                    color: buttonColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    buttonText,
                    style: TextStyle(
                      color: buttonColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  final String? photoUrl;

  const _StudentAvatar({
    required this.photoUrl,
  });

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    // Photo loading from backend can be improved later.
    // For now, use a stable fallback avatar.
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: blue,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyStudentsCard extends StatelessWidget {
  const _EmptyStudentsCard();
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: stroke, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'No students available to assign',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}