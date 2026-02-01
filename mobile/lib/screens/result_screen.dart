import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen({Key? key, required this.result}) : super(key: key);

  Color _getColorFromHex(String? hexCode) {
    if (hexCode == null || hexCode.isEmpty) return const Color(0xFF8B7355);

    String hex = hexCode.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  String _getDetailedExplanation(String category, String description) {
    // Backend'den gelen description'ı kullan
    if (description.isNotEmpty) {
      return description;
    }

    // Fallback açıklamalar
    switch (category) {
      case 'İyi':
        return 'Harika! Bu bölge karanlık gökyüzüne sahip. '
            'Çok sayıda yıldız görülebilir ve gece gökyüzü gözlemi için ideal koşullar mevcut. '
            'Samanyolu net bir şekilde görülebilir.';
      case 'Orta':
        return 'Orta seviye ışık kirliliği var. Bazı yıldızlar görülebilir ancak '
            'daha iyi gözlem için daha karanlık bir alan bulmanız önerilir. '
            'Parlak yıldızlar ve gezegenler rahatça gözlemlenebilir.';
      case 'Kötü':
        return 'Yoğun ışık kirliliği mevcut. Yıldızları görmek zor olabilir. '
            'Şehir merkezinden uzaklaşmanız önerilir. Sadece en parlak yıldızlar görülebilir.';
      default:
        return 'Işık kirliliği seviyesi belirlendi.';
    }
  }

  List<Map<String, String>> _getRecommendations(String category) {
    switch (category) {
      case 'İyi':
        return [
          {'icon': '🌟', 'title': 'Astrofotoğraf', 'desc': 'Uzun pozlama fotoğrafları için mükemmel'},
          {'icon': '🔭', 'title': 'Teleskop Gözlemi', 'desc': 'Derin uzay nesnelerini keşfedin'},
          {'icon': '📸', 'title': 'Samanyolu Çekimi', 'desc': 'Galaksimizin tüm detaylarını yakalayın'},
        ];
      case 'Orta':
        return [
          {'icon': '🌙', 'title': 'Gece Yürüyüşü', 'desc': 'Doğal ışıkta keyifli aktiviteler'},
          {'icon': '📷', 'title': 'Yıldız İzi Fotoğrafı', 'desc': 'Uzun pozlama denemeleri yapın'},
          {'icon': '👨‍👩‍👧‍👦', 'title': 'Aile Gözlemi', 'desc': 'Çocuklarla yıldız tanıma'},
        ];
      case 'Kötü':
        return [
          {'icon': '🌃', 'title': 'Şehir Işıkları', 'desc': 'Işık kirliliğini belgeleyin'},
          {'icon': '🔦', 'title': 'Kırmızı Işık Kullanın', 'desc': 'Gece görüşünü koruyun'},
          {'icon': '🗺', 'title': 'Karanlık Alan Arayın', 'desc': 'Daha iyi gözlem noktaları bulun'},
        ];
      default:
        return [];
    }
  }

  double _readNsbScore(Map<String, dynamic> result) {
    final v = result['nsb_score'];
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final success = result['success'] ?? false;
    final category = result['category'] ?? 'Orta';
    final icon = result['icon'] ?? '🟡';
    final description = result['description'] ?? '';
    final confidence = result['confidence'] ?? {};
    final colorCode = result['color_code'] ?? '#FFC107';
    final details = result['details'] ?? {};

    final double nsbScore = _readNsbScore(result);
    final scoreColor = _getColorFromHex(colorCode);

    if (!success) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F1E8),
        appBar: AppBar(
          title: const Text('Hata'),
          backgroundColor: const Color(0xFF1B3A5F),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3A5F).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Color(0xFF1B3A5F),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Analiz başarısız oldu',
                style: TextStyle(
                  color: Color(0xFF1B3A5F),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                result['error'] ?? 'Lütfen tekrar deneyin',
                style: const TextStyle(
                  color: Color(0xFF8B7355),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        title: const Text('Analiz Sonuçları'),
        backgroundColor: const Color(0xFF1B3A5F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMainCategoryCard(category, icon, scoreColor, nsbScore),
            const SizedBox(height: 14),

            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'Sonucunuz Ne Anlama Geliyor?',
              child: Text(
                _getDetailedExplanation(category, description),
                style: const TextStyle(
                  color: Color(0xFF1B3A5F),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Confidence skorları
            if (confidence.isNotEmpty) _buildConfidenceCard(confidence),
            if (confidence.isNotEmpty) const SizedBox(height: 14),

            _buildTechnicalDetails(details, category, nsbScore),
            const SizedBox(height: 14),

            _buildRecommendationsCard(category),
            const SizedBox(height: 14),

            _buildScaleReference(),
            const SizedBox(height: 20),

            SizedBox(
              width: 180,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Yeni Analiz'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF1B3A5F), width: 2),
                  foregroundColor: const Color(0xFF1B3A5F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCategoryCard(String category, String icon, Color color, double nsbScore) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emoji icon
          Text(
            icon,
            style: const TextStyle(fontSize: 70),
          ),
          const SizedBox(height: 16),

          // Kategori adı
          Text(
            category,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          // ✅ NSB skoru
          Text(
            'NSB Skoru: ${nsbScore.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B3A5F),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Işık Kirliliği Seviyesi',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(Map<String, dynamic> confidence) {
    return _buildInfoCard(
      icon: Icons.analytics_outlined,
      title: 'Güvenilirlik Skoru',
      child: Column(
        children: confidence.entries.map((entry) {
          String categoryName = entry.key;

          double value;
          if (entry.value is int) {
            value = (entry.value as int).toDouble();
          } else if (entry.value is num) {
            value = (entry.value as num).toDouble();
          } else {
            value = double.tryParse(entry.value.toString()) ?? 0.0;
          }

          Color barColor;
          switch (categoryName) {
            case 'Kötü':
              barColor = const Color(0xFFFF5252);
              break;
            case 'Orta':
              barColor = const Color(0xFFFFC107);
              break;
            case 'İyi':
              barColor = const Color(0xFF4CAF50);
              break;
            default:
              barColor = const Color(0xFF8B7355);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      categoryName,
                      style: const TextStyle(
                        color: Color(0xFF1B3A5F),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        color: barColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFFD4C4B0),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: barColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3A5F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF1B3A5F), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B3A5F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildTechnicalDetails(Map details, String category, double nsbScore) {
    return _buildInfoCard(
      icon: Icons.analytics_outlined,
      title: 'Teknik Detaylar',
      child: Column(
        children: [
          _detailRow('Kategori', category, Icons.category_outlined),
          const Divider(height: 20, color: Color(0xFFD4C4B0)),
          _detailRow('NSB Skoru', nsbScore.toStringAsFixed(2), Icons.numbers_outlined),

          if (details['exposure_time'] != null && details['exposure_time'] != 'Belirtilmedi') ...[
            const Divider(height: 20, color: Color(0xFFD4C4B0)),
            _detailRow('Pozlama Süresi', '${details['exposure_time']}', Icons.timer_outlined),
          ],
          if (details['altitude'] != null && details['altitude'] != 0) ...[
            const Divider(height: 20, color: Color(0xFFD4C4B0)),
            _detailRow('Yükseklik', '${details['altitude']} m', Icons.terrain),
          ],
          if (details['luminance'] != null) ...[
            const Divider(height: 20, color: Color(0xFFD4C4B0)),
            _detailRow('Parlaklık (Luminance)', '${details['luminance']}', Icons.brightness_6_outlined),
          ],
          if (details['raw_prediction'] != null) ...[
            const Divider(height: 20, color: Color(0xFFD4C4B0)),
            _detailRow('Ham Tahmin', '${details['raw_prediction']}', Icons.insights_outlined),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF8B7355)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF8B7355), fontSize: 13),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1B3A5F),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard(String category) {
    final recommendations = _getRecommendations(category);

    return _buildInfoCard(
      icon: Icons.lightbulb_outline,
      title: 'Öneriler',
      child: Column(
        children: recommendations.map((rec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B3A5F).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(rec['icon']!, style: const TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B3A5F),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        rec['desc']!,
                        style: const TextStyle(
                          color: Color(0xFF8B7355),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScaleReference() {
    return _buildInfoCard(
      icon: Icons.straighten,
      title: 'Işık Kirliliği Kategorileri',
      child: Column(
        children: [
          _scaleItem('İyi', 'Karanlık gökyüzü, net yıldızlar', const Color(0xFF4CAF50)),
          const SizedBox(height: 8),
          _scaleItem('Orta', 'Orta seviye kirlilik', const Color(0xFFFFC107)),
          const SizedBox(height: 8),
          _scaleItem('Kötü', 'Yoğun ışık kirliliği', const Color(0xFFFF5252)),
        ],
      ),
    );
  }

  Widget _scaleItem(String label, String desc, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1B3A5F),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  color: Color(0xFF8B7355),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}