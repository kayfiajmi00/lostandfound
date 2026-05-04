import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import '../services/session_service.dart';
import '../services/notification_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _title = TextEditingController();
  final _desc  = TextEditingController();
  final _loc   = TextEditingController();
  final _secQ  = TextEditingController();
  final _secA  = TextEditingController();
  String _type      = 'lost';
  int    _catId     = 1;
  bool   _emergency = false;
  File?  _image;
  bool   _loading   = false;
  String? _error;
  String? _success;

  static const _cats = [
    {'id': 1, 'name': 'Electronics'},
    {'id': 2, 'name': 'Documents'},
    {'id': 3, 'name': 'Wallets'},
    {'id': 4, 'name': 'Books & Stationery'},
    {'id': 5, 'name': 'Cash'},
    {'id': 6, 'name': 'Other Accessories'},
  ];

  @override
  void dispose() {
    _title.dispose(); _desc.dispose(); _loc.dispose();
    _secQ.dispose(); _secA.dispose();
    super.dispose();
  }

  Future<void> _pickImg() async {
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (x != null) setState(() => _image = File(x.path));
  }

  Future<void> _submit() async {
    if (_title.text.isEmpty || _loc.text.isEmpty) {
      setState(() => _error = 'Title and location are required.');
      return;
    }
    setState(() { _loading = true; _error = null; _success = null; });
    try {
      final uid = await SessionService.getUserId();
      final req = http.MultipartRequest(
          'POST', Uri.parse('$kBaseUrl/mobile_report.php'));
      req.fields.addAll({
        'user_id':       '${uid ?? 0}',
        'item_type':     _type,
        'title':         _title.text.trim(),
        'description':   _desc.text.trim(),
        'location_name': _loc.text.trim(),
        'category_id':   '$_catId',
        'main_security_question': _secQ.text.trim(),
        'security_answer': _secA.text.trim(),
        'is_emergency':  _emergency ? '1' : '0',
      });
      if (_image != null) {
        req.files.add(await http.MultipartFile.fromPath(
            'item_image', _image!.path));
      }
      final streamed = await req.send();
      final res  = await http.Response.fromStream(streamed);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        if (_emergency) {
          NotificationService.emergencyAlert(
              _title.text.trim(), _loc.text.trim());
        }
        setState(() => _success = _emergency
            ? '🚨 Emergency report submitted! Alert sent.'
            : 'Item reported successfully!');
        _title.clear(); _desc.clear(); _loc.clear();
        _secQ.clear();  _secA.clear();
        setState(() { _image = null; _type = 'lost'; _catId = 1; _emergency = false; });
      } else {
        setState(() => _error = data['message']?.toString() ?? 'Failed');
      }
    } catch (_) {
      setState(() => _error = 'Connection error — is XAMPP running?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary, size: 18),
              onPressed: () => Navigator.pop(context))
          : null,
        title: Text('Report Item',
            style: GoogleFonts.nunitoSans(
                color: AppColors.textPrimary,
                fontSize: 17, fontWeight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            if (_error   != null) _statusBox(_error!,   AppColors.error),
            if (_success != null) _statusBox(_success!, AppColors.success),

            // Type toggle
            _lbl('Report Type'),
            const SizedBox(height: 10),
            Row(children: [
              _typeChip('lost',  'Lost Item',  Icons.search_off_outlined,    AppColors.lost),
              const SizedBox(width: 12),
              _typeChip('found', 'Found Item', Icons.check_circle_outline,   AppColors.success),
            ]),
            const SizedBox(height: 20),

            // Emergency toggle
            GestureDetector(
              onTap: () => setState(() => _emergency = !_emergency),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _emergency
                      ? AppColors.error.withOpacity(0.06)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _emergency
                        ? AppColors.error.withOpacity(0.4)
                        : AppColors.border),
                ),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded,
                    color: _emergency ? AppColors.error : AppColors.textMuted,
                    size: 22),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency Alert',
                        style: GoogleFonts.nunitoSans(
                          color: _emergency
                              ? AppColors.error : AppColors.textPrimary,
                          fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('Notifies all NSU students immediately',
                        style: GoogleFonts.nunitoSans(
                          color: AppColors.textMuted, fontSize: 11)),
                    ],
                  )),
                  Switch.adaptive(
                    value: _emergency,
                    activeColor: AppColors.error,
                    onChanged: (v) => setState(() => _emergency = v),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),

            // Category
            _lbl('Category'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _catId,
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  style: GoogleFonts.nunitoSans(
                      color: AppColors.textPrimary, fontSize: 14),
                  items: _cats.map((c) => DropdownMenuItem<int>(
                    value: c['id'] as int,
                    child: Text(c['name'] as String),
                  )).toList(),
                  onChanged: (v) => setState(() => _catId = v!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photo
            _lbl('Photo (optional)'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImg,
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.inputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _image != null
                        ? AppColors.primary : AppColors.border,
                    width: _image != null ? 1.5 : 1),
                ),
                child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_image!, fit: BoxFit.cover,
                          width: double.infinity))
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: AppColors.textMuted, size: 30),
                      const SizedBox(height: 8),
                      Text('Tap to add photo',
                        style: GoogleFonts.nunitoSans(
                          color: AppColors.textMuted, fontSize: 13)),
                    ]),
              ),
            ),
            const SizedBox(height: 20),

            _lbl('Item Title'),
            const SizedBox(height: 8),
            _field(_title, 'e.g. Blue water bottle'),
            const SizedBox(height: 16),

            _lbl('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _desc,
              minLines: 3, maxLines: 5,
              style: GoogleFonts.nunitoSans(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Describe the item in detail...',
                hintStyle: GoogleFonts.nunitoSans(
                    color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),

            _lbl('Location'),
            const SizedBox(height: 8),
            _field(_loc, 'e.g. Selasar GOR, NSU',
                icon: Icons.location_on_outlined),
            const SizedBox(height: 16),

            _lbl('Security Question'),
            const SizedBox(height: 8),
            _field(_secQ, 'e.g. What color is the cover?'),
            const SizedBox(height: 16),

            _lbl('Answer'),
            const SizedBox(height: 8),
            _field(_secA, 'e.g. Red'),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _emergency
                      ? AppColors.error : AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                ),
                child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      _emergency
                          ? '🚨  SUBMIT EMERGENCY REPORT'
                          : 'SUBMIT REPORT',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w800, fontSize: 14,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _lbl(String t) => Text(t,
    style: GoogleFonts.nunitoSans(
      color: AppColors.textSecondary,
      fontSize: 12, fontWeight: FontWeight.w700));

  Widget _field(TextEditingController c, String hint, {IconData? icon}) =>
    TextField(
      controller: c,
      style: GoogleFonts.nunitoSans(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textMuted, size: 18) : null,
      ),
    );

  Widget _typeChip(String type, String label, IconData icon, Color color) {
    final sel = _type == type;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _type = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? color.withOpacity(0.08) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: sel ? color : AppColors.border,
              width: sel ? 1.5 : 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: sel ? color : AppColors.textMuted, size: 17),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.nunitoSans(
            color: sel ? color : AppColors.textMuted,
            fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ),
    ));
  }

  Widget _statusBox(String msg, Color color) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(children: [
      Icon(color == AppColors.error
          ? Icons.error_outline : Icons.check_circle_outline,
          color: color, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: GoogleFonts.nunitoSans(
          color: color, fontSize: 13))),
    ]),
  );
}
