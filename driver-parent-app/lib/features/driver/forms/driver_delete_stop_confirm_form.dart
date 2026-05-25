import 'package:flutter/material.dart';

class DriverDeleteStopConfirmForm extends StatefulWidget {
  final Future<void> Function(String reason) onConfirm;
  final VoidCallback onCancel;

  const DriverDeleteStopConfirmForm({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<DriverDeleteStopConfirmForm> createState() =>
      _DriverDeleteStopConfirmFormState();
}

class _DriverDeleteStopConfirmFormState
    extends State<DriverDeleteStopConfirmForm> {
  static const blue = Color(0xFF0D4896);
  static const stroke = Color(0xFFDCE6F5);

  final _otherReasonCtrl = TextEditingController();

  String? _selectedReason;
  bool _saving = false;
  String? _error;

  static const otherReason = 'Other reason';

  final reasons = const [
    'Students have moved to another place',
    'Students are no longer in this school',
    otherReason,
  ];

  @override
  void dispose() {
    _otherReasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_selectedReason == null) {
      setState(() => _error = 'Please select a reason');
      return;
    }

    final reason = _selectedReason == otherReason
        ? _otherReasonCtrl.text.trim()
        : _selectedReason!;

    if (reason.isEmpty) {
      setState(() => _error = 'Please enter the reason');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await widget.onConfirm(reason);
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
                child: const Icon(Icons.arrow_back_ios_new, size: 16),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Image.asset(
              'assests/backgrounds/mobile/confused.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Are you sure?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF001B3D),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Are you sure you want to delete this bus stop? If so, can you clarify why below.',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),

          ...reasons.map((reason) {
            final selected = _selectedReason == reason;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: _saving
                    ? null
                    : () {
                        setState(() {
                          _selectedReason = reason;
                          _error = null;
                        });
                      },
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  constraints: BoxConstraints(

                    minHeight: reason == otherReason ? 102 : 48,

                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: stroke, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: reason == otherReason
                      ? TextField(
                          controller: _otherReasonCtrl,
                          enabled: !_saving,
                          maxLines: 3,
                          onTap: () {
                            setState(() {
                              _selectedReason = otherReason;
                              _error = null;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Other reason',
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF233A5A),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Text(
                                reason,
                                style: const TextStyle(
                                  color: Color(0xFF233A5A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: blue, width: 1),
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          color: blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                ),
              ),
            );
          }),

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

          const Spacer(),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                disabledBackgroundColor: blue.withOpacity(0.45),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                _saving ? 'Deleting…' : 'Confirm',
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