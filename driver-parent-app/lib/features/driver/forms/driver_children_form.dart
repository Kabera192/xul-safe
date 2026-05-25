import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import '../pages/driver_child_profile_page.dart';
import '../models/child_model.dart';
import '../models/stop_model.dart';

class DriverChildrenForm extends StatefulWidget {
  final List<ChildModel> children;
  final List<StopModel> stops;
  final bool loading;
  final String? error;

  const DriverChildrenForm({
    super.key,
    required this.children,
    required this.stops,
    required this.loading,
    required this.error,
  });

  @override
  State<DriverChildrenForm> createState() => _DriverChildrenFormState();
}

class _DriverChildrenFormState extends State<DriverChildrenForm> {

  final _searchCtrl = TextEditingController();
  int? _selectedStopId; // null = All

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _stopLabel(int? stopId) {
    if (stopId == null) return 'Not assigned';

    final index = widget.stops.indexWhere((s) => s.id == stopId);
    if (index == -1) return 'Unknown stop';

    return 'Bus stop ${index + 1}';
  }

  List<ChildModel> get _filteredChildren {
    final query = _searchCtrl.text.trim().toLowerCase();

    return widget.children.where((child) {
      final matchesSearch = query.isEmpty ||
          child.fullName.toLowerCase().contains(query) ||
          child.firstName.toLowerCase().contains(query) ||
          child.lastName.toLowerCase().contains(query);

      final matchesStop =
          _selectedStopId == null || child.pickupStopId == _selectedStopId;

      return matchesSearch && matchesStop;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final children = _filteredChildren;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchBox(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          _StopFilterRow(
            stops: widget.stops,
            selectedStopId: _selectedStopId,
            onSelected: (stopId) {
              setState(() {
                _selectedStopId = stopId;
              });
            },
          ),

          const SizedBox(height: 14),

          if (widget.loading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (widget.error != null) ...[
            _MessageCard(
              text: widget.error!,
              color: Colors.red,
            ),
          ] else if (children.isEmpty) ...[
            const _MessageCard(
              text: 'No children found',
              color: Colors.black54,
            ),
          ] else ...[
            SizedBox(
  height: MediaQuery.of(context).size.height * 0.58,
  child: ListView.separated(
    physics: const ClampingScrollPhysics(),
    itemCount: children.length,
    separatorBuilder: (_, __) => const SizedBox(height: 9),
    itemBuilder: (context, index) {
      final child = children[index];

      return _ChildCard(
        child: child,
        stopLabel: _stopLabel(child.pickupStopId),
      );
    },
  ),
),],
        ],
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

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: stroke, width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            IconsaxPlusLinear.search_normal_1,
            color: blue,
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search a name',
                hintStyle: TextStyle(
                  color: Colors.black45,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                color: Colors.black87,
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

class _StopFilterRow extends StatelessWidget {
  final List<StopModel> stops;
  final int? selectedStopId;
  final ValueChanged<int?> onSelected;

  const _StopFilterRow({
    required this.stops,
    required this.selectedStopId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All',
            selected: selectedStopId == null,
            onTap: () => onSelected(null),
          ),
          ...stops.asMap().entries.map((entry) {
            return _FilterChip(
              label: 'Bus stop ${entry.key + 1}',
              selected: selectedStopId == entry.value.id,
              onTap: () => onSelected(entry.value.id),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? blue : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? blue : stroke,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final String stopLabel;

  const _ChildCard({
    required this.child,
    required this.stopLabel,
  });

  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  @override
  @override
Widget build(BuildContext context) {
  final name = child.fullName.isEmpty ? 'Unnamed child' : child.fullName;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DriverChildProfilePage(childId: child.id),
          ),
        );
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: stroke, width: 1),
        ),
        child: Row(
          children: [
            _ChildAvatar(photoUrl: child.photoUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF001B3D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              stopLabel,
              style: const TextStyle(
                color: blue,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}}

class _ChildAvatar extends StatelessWidget {
  final String? photoUrl;

  const _ChildAvatar({
    required this.photoUrl,
  });

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
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

class _MessageCard extends StatelessWidget {
  final String text;
  final Color color;

  const _MessageCard({
    required this.text,
    required this.color,
  });

  static const stroke = Color(0xFFDCE6F5);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: stroke, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}