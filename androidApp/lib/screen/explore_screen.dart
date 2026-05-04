import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../services/api_service.dart';
import '../widgets/item_card.dart';
import 'item_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  final String? initialType;
  final int?    initialCategoryId;
  const ExploreScreen({super.key, this.initialType, this.initialCategoryId});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _search = TextEditingController();
  List<dynamic> _all      = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  int? _selCat;

  static const _tabs    = ['All Items', 'Lost Items', 'Found Items'];
  static const _tabKeys = ['all', 'lost', 'found'];

  @override
  void initState() {
    super.initState();
    _selCat = widget.initialCategoryId;
    int initIdx = 0;
    if (widget.initialType != null) {
      final i = _tabKeys.indexOf(widget.initialType!);
      if (i >= 0) initIdx = i;
    }
    _tab = TabController(length: 3, vsync: this, initialIndex: initIdx);
    _tab.addListener(() { if (!_tab.indexIsChanging) _filter(); });
    _search.addListener(_filter);
    _loadAll();
  }

  @override
  void dispose() { _tab.dispose(); _search.dispose(); super.dispose(); }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final items = await ApiService.getItems(catId: _selCat);
      setState(() { _all = items; _loading = false; _filter(); });
    } catch (_) { setState(() => _loading = false); }
  }

  void _filter() {
    List<dynamic> base = List.from(_all);
    final key = _tabKeys[_tab.index];
    if (key == 'lost')  base = base.where((i) => i['item_type'] == 'lost').toList();
    if (key == 'found') base = base.where((i) => i['item_type'] == 'found').toList();
    final q = _search.text.toLowerCase();
    if (q.isNotEmpty) {
      base = base.where((i) =>
        (i['title']         ?? '').toString().toLowerCase().contains(q) ||
        (i['description']   ?? '').toString().toLowerCase().contains(q) ||
        (i['location_name'] ?? '').toString().toLowerCase().contains(q)
      ).toList();
    }
    setState(() => _filtered = base);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: Text('Explore', style: TextStyle(
            color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _search,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
                onPressed: _filterSheet,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tabs
        TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),

        // Category chip
        if (_selCat != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Category filter active',
                    style: TextStyle(color: AppColors.primary, fontSize: 12)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () { setState(() => _selCat = null); _loadAll(); },
                    child: const Icon(Icons.close_rounded, color: AppColors.primary, size: 16),
                  ),
                ]),
              ),
            ]),
          ),
        const SizedBox(height: 8),

        // Grid
        Expanded(
          child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _filtered.isEmpty
              ? _empty()
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12,
                    mainAxisSpacing: 12, childAspectRatio: 0.78),
                  itemCount: _filtered.length,
                  itemBuilder: (_, i) => ItemCard(
                    item: _filtered[i] as Map<String, dynamic>,
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ItemDetailScreen(
                            item: _filtered[i] as Map<String, dynamic>))),
                  ),
                ),
        ),
      ])),
    );
  }

  Widget _empty() => const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.search_off_rounded, color: AppColors.textMuted, size: 60),
    SizedBox(height: 14),
    Text('No items found', style: TextStyle(color: AppColors.textSecondary,
        fontSize: 18, fontWeight: FontWeight.w600)),
    SizedBox(height: 4),
    Text('Try adjusting search or filters',
        style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
  ]));

  void _filterSheet() {
    final cats = [
      {'id': 0, 'name': 'All Categories'},
      {'id': 1, 'name': 'Electronics'},
      {'id': 2, 'name': 'Documents'},
      {'id': 3, 'name': 'Wallets'},
      {'id': 4, 'name': 'Books & Stationery'},
      {'id': 5, 'name': 'Cash'},
      {'id': 6, 'name': 'Other'},
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Filter by Category', style: TextStyle(
              color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...cats.map((c) {
            final cid = c['id'] as int;
            final selected = cid == 0 ? _selCat == null : _selCat == cid;
            return ListTile(
              leading: Icon(selected ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded, color: AppColors.primary),
              title: Text(c['name'] as String,
                  style: const TextStyle(color: AppColors.textPrimary)),
              onTap: () {
                setState(() => _selCat = cid == 0 ? null : cid);
                Navigator.pop(context);
                _loadAll();
              },
            );
          }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
