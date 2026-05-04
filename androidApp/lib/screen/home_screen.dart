import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/item_card.dart';
import '../widgets/nsu_logo.dart';
import 'item_detail_screen.dart';
import 'explore_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _lost  = [];
  List<dynamic> _found = [];
  bool _loading = true;
  String _name  = '';

  static const _cats = [
    {'id': 1, 'name': 'Electronics', 'icon': Icons.smartphone_outlined,             'color': Color(0xFF3B5BDB)},
    {'id': 2, 'name': 'Documents',   'icon': Icons.article_outlined,                'color': Color(0xFF0CA678)},
    {'id': 3, 'name': 'Wallets',     'icon': Icons.account_balance_wallet_outlined, 'color': Color(0xFFF5A623)},
    {'id': 4, 'name': 'Books',       'icon': Icons.menu_book_outlined,              'color': Color(0xFF1971C2)},
    {'id': 5, 'name': 'Cash',        'icon': Icons.payments_outlined,               'color': Color(0xFF2B9348)},
    {'id': 6, 'name': 'Others',      'icon': Icons.category_outlined,               'color': Color(0xFF9C36B5)},
  ];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final n = await SessionService.getName();
    setState(() => _name = n ?? '');
    try {
      final l = await ApiService.getItems(type: 'lost');
      final f = await ApiService.getItems(type: 'found');
      setState(() {
        _lost  = l.take(6).toList();
        _found = f.take(6).toList();
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  void _go(Map<String, dynamic> item) => Navigator.push(context,
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _banner(context)),
            SliverToBoxAdapter(child: _secTitle('Categories', null)),
            SliverToBoxAdapter(child: _catRow(context)),
            SliverToBoxAdapter(child: _secTitle('Lost Items', () =>
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ExploreScreen(initialType: 'lost'))))),
            _grid(_lost),
            SliverToBoxAdapter(child: _secTitle('Found Items', () =>
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ExploreScreen(initialType: 'found'))))),
            _grid(_found, bottom: 100),
          ]),
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Row(children: [
      const NsuLogo(size: 36),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('NSU Recovery',
          style: GoogleFonts.nunitoSans(
            color: AppColors.textPrimary,
            fontSize: 16, fontWeight: FontWeight.w800)),
        Text('Hi, ${_name.isNotEmpty ? _name.split(" ").first : "Student"}!',
          style: GoogleFonts.nunitoSans(
            color: AppColors.textMuted, fontSize: 12)),
      ]),
      const Spacer(),
      // Search icon
      IconButton(
        icon: const Icon(Icons.search_outlined,
            color: AppColors.textSecondary, size: 22),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ExploreScreen()))),
      // Notification icon
      IconButton(
        icon: const Icon(Icons.notifications_outlined,
            color: AppColors.textSecondary, size: 22),
        onPressed: () {}),
    ]),
  );

  Widget _banner(BuildContext ctx) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Lost something?',
          style: GoogleFonts.nunitoSans(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text('Post it and get it back quickly.',
          style: GoogleFonts.nunitoSans(
            color: Colors.white70, fontSize: 12)),
      ])),
      TextButton(
        onPressed: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => const ReportScreen())),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('SEE ALL',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w800, fontSize: 11)),
      ),
    ]),
  );

  Widget _secTitle(String t, VoidCallback? seeAll) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(t, style: GoogleFonts.nunitoSans(
        color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
      if (seeAll != null)
        GestureDetector(onTap: seeAll,
          child: Text('SEE ALL',
            style: GoogleFonts.nunitoSans(
              color: AppColors.primary, fontSize: 11,
              fontWeight: FontWeight.w700))),
    ]),
  );

  Widget _catRow(BuildContext ctx) => SizedBox(
    height: 84,
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      scrollDirection: Axis.horizontal,
      itemCount: _cats.length,
      itemBuilder: (_, i) {
        final c   = _cats[i];
        final col = c['color'] as Color;
        return GestureDetector(
          onTap: () => Navigator.push(ctx, MaterialPageRoute(
              builder: (_) => ExploreScreen(initialCategoryId: c['id'] as int))),
          child: Container(
            width: 70,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: col.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: col.withOpacity(0.15)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(c['icon'] as IconData, color: col, size: 22),
              const SizedBox(height: 5),
              Text(c['name'] as String,
                style: GoogleFonts.nunitoSans(
                  color: AppColors.textSecondary, fontSize: 9.5,
                  fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            ]),
          ),
        );
      },
    ),
  );

  Widget _grid(List<dynamic> items, {double bottom = 0}) {
    if (_loading) {
      return SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10,
            mainAxisSpacing: 10, childAspectRatio: 0.80),
          itemCount: 4,
          itemBuilder: (_, __) => Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12))),
        ),
      ));
    }
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox());
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, i) => ItemCard(item: items[i] as Map<String, dynamic>,
              onTap: () => _go(items[i] as Map<String, dynamic>)),
          childCount: items.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 10,
          mainAxisSpacing: 10, childAspectRatio: 0.80),
      ),
    );
  }
}
