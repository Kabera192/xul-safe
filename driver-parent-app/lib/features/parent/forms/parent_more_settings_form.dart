import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../services/emergency_contact_service.dart';

class ParentMoreSettingsForm extends StatefulWidget {
  const ParentMoreSettingsForm({super.key});

  @override
  State<ParentMoreSettingsForm> createState() => _ParentMoreSettingsFormState();
}

class _ParentMoreSettingsFormState extends State<ParentMoreSettingsForm> {
  List<Map<String, dynamic>> _contacts = [];
  bool _loadingContacts = true;
  String? _contactsError;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() { _loadingContacts = true; _contactsError = null; });
    try {
      final contacts = await EmergencyContactService.getMyContacts();
      if (mounted) setState(() => _contacts = contacts);
    } catch (e) {
      if (mounted) setState(() => _contactsError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingContacts = false);
    }
  }

  Future<void> _showAddContactDialog() async {
    final formKey = GlobalKey<FormState>();
    final phoneCtrl = TextEditingController();
    final labelCtrl = TextEditingController();
    bool saving = false;
    String? dialogError;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('New Emergency Contact'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number *'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(labelText: 'Label *', hintText: 'e.g. Aunt, Uncle'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 10),
                  Text(dialogError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving ? null : () async {
                if (!formKey.currentState!.validate()) return;
                set(() { saving = true; dialogError = null; });
                try {
                  final contact = await EmergencyContactService.addContact(
                    phoneNumber: phoneCtrl.text,
                    label: labelCtrl.text,
                  );
                  if (mounted) setState(() => _contacts.add(contact));
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  set(() { saving = false; dialogError = e.toString().replaceFirst('Exception: ', ''); });
                }
              },
              child: saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteContact(Map<String, dynamic> contact) async {
    final id = contact['id'];
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove contact?'),
        content: Text('${contact['label'] ?? ''} (${contact['phoneNumber'] ?? ''}) will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await EmergencyContactService.deleteContact(int.parse(id.toString()));
      if (mounted) setState(() => _contacts.removeWhere((c) => c['id'] == id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // SECTION 1 — Emergency Contacts
          const _SectionTitle('Emergency Contacts'),
          const SizedBox(height: 8),

          if (_loadingContacts)
            const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
          else if (_contactsError != null)
            SizedBox(height: 60, child: Center(child: Text(_contactsError!, style: const TextStyle(color: Colors.red, fontSize: 13))))
          else if (_contacts.isEmpty)
            const SizedBox(height: 40, child: Center(child: Text('No emergency contact yet')))
          else
            ...(_contacts.map((c) => _ContactTile(contact: c, onDelete: () => _deleteContact(c)))),

          const SizedBox(height: 10),
          _SoftActionButton(icon: IconsaxPlusLinear.add_circle, text: 'New contact', onTap: _showAddContactDialog),

          const SizedBox(height: 22),

          // SECTION 2 — My route details
          const _SectionTitle('My route details'),
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          Center(child: Text('No routes/stops', style: TextStyle(color: onSurface.withOpacity(0.6), fontSize: 14.5, fontWeight: FontWeight.w500))),
          const SizedBox(height: 10),
          _SoftActionButton(icon: IconsaxPlusLinear.add_circle, text: 'Request a custom bus stop', onTap: null),

          const SizedBox(height: 22),

          // SECTION 3 — Journey logs
          const _SectionTitle('Journey logs'),
          const SizedBox(height: 8),
          _SoftCardButton(icon: IconsaxPlusLinear.refresh_left_square, title: "View all your kids' journeys", onTap: null),

          const SizedBox(height: 22),

          // SECTION 4 — Language & support
          const _SectionTitle('Language & support'),
          const SizedBox(height: 8),
          _WhiteOptionTile(icon: IconsaxPlusLinear.global, text: 'Language', onTap: null),
          const SizedBox(height: 8),
          _WhiteOptionTile(icon: IconsaxPlusLinear.message_question, text: 'Contact support', onTap: null),
          const SizedBox(height: 8),
          _WhiteOptionTile(icon: IconsaxPlusLinear.document_text, text: 'Send a claim', onTap: null),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Contact tile ──────────────────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onDelete;
  const _ContactTile({required this.contact, required this.onDelete});

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
    final label = contact['label']?.toString() ?? '';
    final phone = contact['phoneNumber']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor, width: 1)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: const CircleAvatar(backgroundColor: Color(0xFFEBF1FE), child: Icon(IconsaxPlusLinear.call, color: blue, size: 18)),
        title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(phone, style: TextStyle(fontSize: 13, color: onSurface.withOpacity(0.6))),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: onDelete),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 13.5, fontWeight: FontWeight.w700));
  }
}

class _SoftActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  const _SoftActionButton({required this.icon, required this.text, required this.onTap});

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final softBg = isDark ? const Color(0xFF162030) : const Color(0xFFF1F5FA);
    final borderColor = isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
    return Material(
      color: softBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor, width: 1)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: blue),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(color: blue, fontSize: 14.5, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftCardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  const _SoftCardButton({required this.icon, required this.title, required this.onTap});

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final softBg = isDark ? const Color(0xFF162030) : const Color(0xFFF1F5FA);
    final borderColor = isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
    return Material(
      color: softBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor, width: 1)),
          child: Row(
            children: [
              Icon(icon, size: 20, color: blue),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: TextStyle(color: onSurface, fontSize: 14.5, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteOptionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  const _WhiteOptionTile({required this.icon, required this.text, required this.onTap});

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final cardBg = isDark ? const Color(0xFF1A2530) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3A50) : const Color(0xFFDCE6F5);
    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor, width: 1)),
          child: Row(
            children: [
              Icon(icon, size: 18, color: blue),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: TextStyle(color: onSurface, fontSize: 14.5, fontWeight: FontWeight.w500))),
              Icon(Icons.more_vert, size: 16, color: onSurface.withOpacity(0.38)),
            ],
          ),
        ),
      ),
    );
  }
}
