import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '', _email = '', _sid = '';
  int?   _uid;
  List<dynamic> _posts = [];
  bool _loadingPosts = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid   = await SessionService.getUserId();
    final name  = await SessionService.getName();
    final email = await SessionService.getEmail();
    final sid   = await SessionService.getStudentId();
    setState(() {
      _uid = uid; _name = name ?? '';
      _email = email ?? ''; _sid = sid ?? '';
    });
    if (uid != null) _loadPosts(uid);
  }

  Future<void> _loadPosts(int uid) async {
    setState(() => _loadingPosts = true);
    try {
      final p = await ApiService.getMyPosts(uid);
      setState(() { _posts = p; _loadingPosts = false; });
    } catch (_) { setState(() => _loadingPosts = false); }
  }

  Future<void> _logout() async {
    await SessionService.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  Future<void> _delete(int itemId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Post',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text('This post will be permanently deleted.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted))),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && _uid != null) {
      await ApiService.deletePost(itemId);
      _loadPosts(_uid!);
    }
  }

  int get _activeCount    => _posts.where((p) => p['status'] == 'active').length;
  int get _recoveredCount => _posts.where((p) => p['status'] == 'recovered').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Profile', style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22, fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_outlined,
                        color: AppColors.error, size: 16),
                    label: const Text('Logout',
                        style: TextStyle(color: AppColors.error, fontSize: 13)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Avatar
            CircleAvatar(
              radius: 38,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                _name.isNotEmpty ? _name[0].toUpperCase() : 'S',
                style: const TextStyle(color: AppColors.primary,
                    fontSize: 32, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 14),
            Text(_name, style: const TextStyle(color: AppColors.textPrimary,
                fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(_email, style: const TextStyle(
                color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 8),
            if (_sid.isNotEmpty) Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('ID: $_sid',
                style: const TextStyle(color: AppColors.primary,
                    fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 28),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                _stat('Total', '${_posts.length}'),
                const SizedBox(width: 10),
                _stat('Active', '$_activeCount'),
                const SizedBox(width: 10),
                _stat('Recovered', '$_recoveredCount'),
              ]),
            ),
            const SizedBox(height: 28),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(alignment: Alignment.centerLeft,
                child: Text('My Posts', style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(height: 12),
          ])),

          if (_loadingPosts)
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))))
          else if (_posts.isEmpty)
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Column(children: [
                Icon(Icons.post_add_outlined, color: AppColors.textMuted, size: 40),
                SizedBox(height: 12),
                Text('No posts yet', style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 15,
                    fontWeight: FontWeight.w600)),
              ]))))
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) => _postTile(_posts[i] as Map<String, dynamic>),
                childCount: _posts.length,
              )),
            ),
        ]),
      ),
    );
  }

  Widget _stat(String label, String val) =>
    Expanded(child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text(val, style: const TextStyle(color: AppColors.textPrimary,
            fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(
            color: AppColors.textMuted, fontSize: 11)),
      ]),
    ));

  Widget _postTile(Map<String, dynamic> p) {
    final isFound = p['item_type']?.toString() == 'found';
    final status  = p['status']?.toString() ?? 'pending';
    Color sc = status == 'recovered' ? AppColors.success
        : status == 'active' ? AppColors.primary : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: (isFound ? AppColors.found : AppColors.lost).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12)),
          child: Icon(
            isFound ? Icons.search_outlined : Icons.search_off_outlined,
            color: isFound ? AppColors.found : AppColors.lost, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p['title']?.toString() ?? '', style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined,
                color: AppColors.textMuted, size: 11),
            const SizedBox(width: 3),
            Expanded(child: Text(p['location_name']?.toString() ?? '',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: sc.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6)),
            child: Text(status.toUpperCase(),
              style: TextStyle(color: sc, fontSize: 9,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
        ])),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
          onPressed: () => _delete(
              int.tryParse(p['item_id'].toString()) ?? 0)),
      ]),
    );
  }
}
