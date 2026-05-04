import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  const ItemCard({super.key, required this.item, required this.onTap});

  bool get _isFound => item['item_type']?.toString().toLowerCase() == 'found';

  String get _imgUrl {
    final raw = (item['item_image'] ?? '').toString();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return 'http://10.0.2.2/kayfi2/$raw';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          Expanded(
            flex: 5,
            child: _imgUrl.isNotEmpty
                ? Image.network(_imgUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item['title']?.toString() ?? '',
                      style: GoogleFonts.nunitoSans(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primary, size: 11),
                    const SizedBox(width: 3),
                    Expanded(
                        child: Text(item['location_name']?.toString() ?? 'NSU',
                            style: GoogleFonts.nunitoSans(
                                color: AppColors.textMuted, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                  ]),
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.primary.withOpacity(0.08),
        child: Center(
            child: Icon(
                _isFound ? Icons.search_rounded : Icons.search_off_rounded,
                color: AppColors.primary.withOpacity(0.4),
                size: 32)),
      );
}
