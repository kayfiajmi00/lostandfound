import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/session_service.dart';
import 'chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  const ItemDetailScreen({super.key, required this.item});
  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int? _myId;
  bool _verified = false;
  String? _verifyErr;
  final Map<String, TextEditingController> _ctrls = {};

  // ── Item type helpers ─────────────────────────────────────────────────────
  bool get _isFound =>
      widget.item['item_type']?.toString().toLowerCase() == 'found';
  bool get _isLost =>
      widget.item['item_type']?.toString().toLowerCase() == 'lost';
  bool get _isEmergency => widget.item['is_emergency']?.toString() == '1';
  bool get _isMine =>
      _myId != null && _myId.toString() == widget.item['user_id'].toString();

  // Lost OR Emergency → skip verification, show contact directly
  bool get _showDirectContact => _isLost || _isEmergency;

  String get _imgUrl {
    final raw = (widget.item['item_image'] ?? '').toString();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return 'http://10.0.2.2/kayfi2/$raw';
  }

  // ── Quiz questions (only used for FOUND items) ────────────────────────────
  List<Map<String, String>> get _quiz {
    if (!_isFound) return []; // Lost/Emergency → no questions
    try {
      final meta = widget.item['metadata']?.toString() ?? '';
      if (meta.isNotEmpty) {
        final d = jsonDecode(meta) as Map<String, dynamic>;
        final q = d['quiz'] as List<dynamic>? ?? [];
        return q
            .map<Map<String, String>>((e) => {
                  'question': e['question']?.toString() ?? '',
                  'answer': e['answer']?.toString() ?? '',
                })
            .toList();
      }
    } catch (_) {}
    // Fallback: q1-q4 columns
    final qs = <Map<String, String>>[];
    for (int i = 1; i <= 4; i++) {
      final q = widget.item['q$i']?.toString() ?? '';
      final a = widget.item['ans$i']?.toString() ?? '';
      if (q.isNotEmpty) qs.add({'question': q, 'answer': a});
    }
    return qs;
  }

  Map<String, String> get _specs {
    try {
      final meta = widget.item['metadata']?.toString() ?? '';
      if (meta.isNotEmpty) {
        final d = jsonDecode(meta) as Map<String, dynamic>;
        final s = d['specs'];
        if (s is Map)
          return s.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }

  @override
  void initState() {
    super.initState();
    SessionService.getUserId().then((v) => setState(() => _myId = v));
    // Only build controllers for FOUND item quiz questions
    for (final q in _quiz) {
      _ctrls[q['question']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _ctrls.values) c.dispose();
    super.dispose();
  }

  // ── Verify answers (FOUND items only) ────────────────────────────────────
  void _verify() {
    final qs = _quiz;
    if (qs.isEmpty) {
      // Found item with no questions set → allow direct contact
      setState(() {
        _verified = true;
        _verifyErr = null;
      });
      return;
    }
    final ok = qs.every((q) {
      final user = _ctrls[q['question']]?.text.trim().toLowerCase() ?? '';
      final correct = q['answer']!.toLowerCase();
      return user == correct;
    });
    setState(() {
      _verified = ok;
      _verifyErr = ok ? null : 'Some answers are incorrect. Please try again.';
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        // ── Hero image app bar ────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.background,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: AppColors.surface,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary, size: 17),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _imgUrl.isNotEmpty
                ? Image.network(_imgUrl,
                    fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imgPh())
                : _imgPh(),
          ),
        ),

        // ── Content ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + type badge row
                Row(children: [
                  Expanded(
                    child: Text(
                      widget.item['title']?.toString() ?? '',
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _typeBadge(),
                ]),
                const SizedBox(height: 8),

                // Emergency banner
                if (_isEmergency) _emergencyBanner(),

                const SizedBox(height: 8),

                // Location
                Row(children: [
                  const Icon(Icons.location_on_rounded,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    widget.item['location_name']?.toString() ?? 'NSU Campus',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                ]),
                const SizedBox(height: 20),

                // Description
                if ((widget.item['description'] ?? '')
                    .toString()
                    .isNotEmpty) ...[
                  _sec('Description'),
                  const SizedBox(height: 8),
                  Text(widget.item['description'].toString(),
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.6)),
                  const SizedBox(height: 20),
                ],

                // Specs
                if (_specs.isNotEmpty) ...[
                  _sec('Item Details'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: _specs.entries
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(children: [
                                  Text(e.key,
                                      style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 13)),
                                  const Spacer(),
                                  Text(e.value,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                ]),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Action area ───────────────────────────────────────────
                if (_isMine)
                  _myPostBadge()
                else if (_showDirectContact)
                  // LOST or EMERGENCY → no verification, direct contact
                  _directContactBox()
                else if (_verified)
                  // FOUND + verified
                  _successBox()
                else
                  // FOUND + not yet verified
                  _verificationForm(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _typeBadge() {
    final color = _isFound ? AppColors.green : AppColors.red;
    final label = _isFound ? 'Found' : 'Lost';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 13, fontWeight: FontWeight.w700)),
    );
  }

  Widget _emergencyBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.red.withOpacity(0.4)),
        ),
        child: const Row(children: [
          Text('🚨', style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Emergency — contact info is shown directly to help reunite ASAP.',
              style: TextStyle(
                  color: Color(0xFFFCA5A5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ]),
      );

  // Shown for LOST items and EMERGENCY items (no verification needed)
  Widget _directContactBox() {
    final name = widget.item['full_name']?.toString() ?? 'Reporter';
    final email = widget.item['email']?.toString() ?? '';
    final ownerId = widget.item['user_id'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sec(_isEmergency ? 'Emergency Contact' : 'Reporter Info'),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.green.withOpacity(0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Name row
          _contactRow(Icons.person_rounded, 'Name', name),
          const Divider(color: Color(0xFF1F2937), height: 16),
          // Email row
          _contactRow(Icons.email_rounded, 'Email', email),
        ]),
      ),
      const SizedBox(height: 14),
      // Message button
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            if (ownerId != null && _myId != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      myUserId: _myId!,
                      contactId: int.tryParse(ownerId.toString()) ?? 0,
                      contactName: name,
                      itemId:
                          int.tryParse(widget.item['item_id'].toString()) ?? 0,
                    ),
                  ));
            }
          },
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Send Message',
              style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    ]);
  }

  Widget _contactRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, color: AppColors.green, size: 16),
          const SizedBox(width: 8),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  // Shown after successful verification of a FOUND item
  Widget _successBox() {
    final ownerId = widget.item['user_id'];
    final ownerName = widget.item['full_name']?.toString() ?? 'Reporter';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.green.withOpacity(0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.check_circle_rounded, color: AppColors.green, size: 20),
            SizedBox(width: 8),
            Text('Verification Successful!',
                style: TextStyle(
                    color: AppColors.green, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text('Finder: $ownerName',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            if (ownerId != null && _myId != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      myUserId: _myId!,
                      contactId: int.tryParse(ownerId.toString()) ?? 0,
                      contactName: ownerName,
                      itemId:
                          int.tryParse(widget.item['item_id'].toString()) ?? 0,
                    ),
                  ));
            }
          },
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Send Message',
              style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    ]);
  }

  // Shown for FOUND items that have not been verified yet
  Widget _verificationForm() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sec('Security Verification'),
          const SizedBox(height: 6),
          const Text(
            'Answer the questions below to contact the finder.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          // No questions set → allow directly
          if (_quiz.isEmpty)
            const Text(
              'No specific questions set. Tap Verify to proceed.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            )
          else
            ..._quiz.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q['question']!,
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _ctrls[q['question']],
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Your answer...',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )),
          if (_verifyErr != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.red.withOpacity(0.3)),
              ),
              child: Text(_verifyErr!,
                  style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _verify,
              icon: const Icon(Icons.verified_user_rounded, size: 18),
              label: const Text('Verify Identity',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      );

  Widget _myPostBadge() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: const Row(children: [
          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Text('This is your post',
              style: TextStyle(color: AppColors.primary, fontSize: 13)),
        ]),
      );

  Widget _sec(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700));

  Widget _imgPh() => Container(
      color: AppColors.surfaceLight,
      child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              color: AppColors.textMuted, size: 60)));
}
