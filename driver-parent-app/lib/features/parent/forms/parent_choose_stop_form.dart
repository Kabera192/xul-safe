import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../core/l10n/app_localizations.dart';
import '../models/child_model.dart';

class ParentChooseStopForm extends StatefulWidget {
  final List<ChildModel> children;
  final List<Map<String, dynamic>> routes;
  final Future<List<Map<String, dynamic>>> Function(int routeId) loadStops;
  final Future<void> Function({
    required String childId,
    required String busStopId,
  }) onSelectStop;
  final VoidCallback onRequestNewStop;

  const ParentChooseStopForm({
    super.key,
    required this.children,
    required this.routes,
    required this.loadStops,
    required this.onSelectStop,
    required this.onRequestNewStop,
  });

  @override
  State<ParentChooseStopForm> createState() => _ParentChooseStopFormState();
}

class _ParentChooseStopFormState extends State<ParentChooseStopForm> {
  static const blue = Color(0xFF0D4896);

  String? _selectedChildId;
  int? _expandedRouteId;
  bool _loadingStops = false;
  bool _saving = false;
  String? _error;

  final Map<int, List<Map<String, dynamic>>> _stopsCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.children.length == 1) {
      _selectedChildId = widget.children.first.id;
    }
  }

  Future<void> _toggleRoute(int routeId) async {
    if (_expandedRouteId == routeId) {
      setState(() => _expandedRouteId = null);
      return;
    }

    setState(() {
      _expandedRouteId = routeId;
      _error = null;
    });

    if (_stopsCache.containsKey(routeId)) return;

    setState(() => _loadingStops = true);
    try {
      final stops = await widget.loadStops(routeId);
      if (!mounted) return;
      setState(() {
        _stopsCache[routeId] = stops;
        _loadingStops = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loadingStops = false;
      });
    }
  }

  Future<void> _pickStop(String busStopId) async {
    if (_selectedChildId == null) {
      setState(() => _error = AppLocalizations.of(context).parSelectChildFirst);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onSelectStop(
        childId: _selectedChildId!,
        busStopId: busStopId,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.parChooseStopIntro,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.children.length > 1) ...[
            Text(
              l10n.parChildLabel,
              style: TextStyle(
                color: onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.children.map((c) {
                final selected = c.id == _selectedChildId;
                return GestureDetector(
                  onTap: () => setState(() => _selectedChildId = c.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? blue : blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c.fullName,
                      style: TextStyle(
                        color: selected ? Colors.white : blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
          ],
          Text(
            l10n.parAvailableRoutes,
            style: TextStyle(
              color: onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.routes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.parNoRoutesYet,
                style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
              ),
            )
          else
            ...widget.routes.map((route) {
              final routeId = route['id'] as int;
              final expanded = _expandedRouteId == routeId;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => _toggleRoute(routeId),
                      title: Text(
                        (route['name'] as String?) ?? l10n.parRouteFallback,
                        style: TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: (route['description'] as String?)?.isNotEmpty ==
                              true
                          ? Text(route['description'] as String)
                          : null,
                      trailing: Icon(
                        expanded
                            ? IconsaxPlusLinear.arrow_up_2
                            : IconsaxPlusLinear.arrow_down_1,
                        size: 18,
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    if (expanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _loadingStops
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              )
                            : _buildStopsList(routeId, onSurface, l10n),
                      ),
                  ],
                ),
              );
            }),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: TextButton.icon(
                onPressed: widget.onRequestNewStop,
                icon: const Icon(IconsaxPlusLinear.add_circle, size: 18),
                label: Flexible(
                  child: Text(
                    l10n.parCantFindStopRequestNew,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
          if (_saving) ...[
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStopsList(int routeId, Color onSurface, AppLocalizations l10n) {
    final stops = _stopsCache[routeId] ?? [];

    if (stops.isEmpty) {
      return Text(
        l10n.parNoStopsOnRoute,
        style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 13),
      );
    }

    return Column(
      children: stops.map((stop) {
        final id = stop['id'] as String;
        final name = (stop['name'] as String?) ?? l10n.parStopFallback;
        final address = stop['address'] as String?;

        return InkWell(
          onTap: _saving ? null : () => _pickStop(id),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(IconsaxPlusBold.location, size: 16, color: blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: TextStyle(
                              color: onSurface, fontWeight: FontWeight.w500)),
                      if (address != null && address.isNotEmpty)
                        Text(address,
                            style: TextStyle(
                                color: onSurface.withValues(alpha: 0.5),
                                fontSize: 12)),
                    ],
                  ),
                ),
                Icon(IconsaxPlusLinear.arrow_right_3,
                    size: 16, color: onSurface.withValues(alpha: 0.4)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
