import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Ngrok URL (değişirse burayı güncelle)
  static const String baseUrl =
      'https://unlawyerlike-recollectedly-legend.ngrok-free.dev';

  /// Sunucu ayakta mı? (Backend'te /health yok)
  /// GET /analyze -> 405 dönmesi normal (çünkü sadece POST kabul ediyor),
  /// yine de server'ın cevap verdiğini gösterir.
  static Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/analyze');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      // 405: Method Not Allowed -> server var, endpoint var ama GET yasak
      if (res.statusCode == 405) return true;

      // 200 olursa da zaten ok
      if (res.statusCode == 200) return true;

      // Bazı durumlarda ngrok/servis farklı kod dönebilir, en azından ulaşılıyor mu bak
      return res.statusCode >= 200 && res.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  // NSB skoruna göre UI için kategori/renk/açıklama üret
  static Map<String, dynamic> _uiFromNsb(double nsb, String backendMessage) {
    // Backend mesajı örn: "🌑 KARANLIK / TEMİZ GÖKYÜZÜ"
    String icon = '🟡';
    String description = backendMessage;
    if (backendMessage.isNotEmpty) {
      // İlk boşluğa kadar olanı ikon varsay
      final firstSpace = backendMessage.indexOf(' ');
      if (firstSpace > 0) {
        icon = backendMessage.substring(0, firstSpace).trim();
        description = backendMessage.substring(firstSpace).trim();
      }
    }

    // Backend eşikleriyle aynı (kodundaki gibi)
    // >18.5, >17.0, >15.0, else
    if (nsb > 18.5) {
      return {
        'category': 'İyi',
        'pollution_level': 'Düşük',
        'color_code': '#4CAF50',
        'icon': icon,
        'description': description,
      };
    } else if (nsb > 17.0) {
      return {
        'category': 'Orta',
        'pollution_level': 'Orta',
        'color_code': '#FFC107',
        'icon': icon,
        'description': description,
      };
    } else if (nsb > 15.0) {
      return {
        'category': 'Orta',
        'pollution_level': 'Orta-Yüksek',
        'color_code': '#FF9800',
        'icon': icon,
        'description': description,
      };
    } else {
      return {
        'category': 'Kötü',
        'pollution_level': 'Çok Yüksek',
        'color_code': '#FF5252',
        'icon': icon,
        'description': description,
      };
    }
  }

  /// Fotoğrafı backend’e gönderir ve sonucu döndürür.
  /// Backend: POST /analyze, multipart/form-data, field: "image"
  static Future<Map<String, dynamic>> analyzeImage(
    File imageFile, {
    String? exposureTime, // sadece UI için
    String? altitude, // sadece UI için
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/analyze');
      print('📡 Request URL: $uri');

      final request = http.MultipartRequest('POST', uri);

      // ✅ Backend 'image' bekliyor
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));

      print('🚀 Request gönderiliyor...');

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Body (RAW): ${response.body}');

      if (response.statusCode != 200) {
        // Backend 400/500 döndüyse body'de genelde json error var
        String msg = response.body;
        try {
          final maybeJson = json.decode(response.body);
          if (maybeJson is Map && maybeJson['error'] != null) {
            msg = maybeJson['error'].toString();
          }
        } catch (_) {}

        return {
          'success': false,
          'error': 'API Hatası: ${response.statusCode}',
          'message': msg,
        };
      }

      // 200 OK -> JSON parse
      final Map<String, dynamic> jsonResponse =
          json.decode(response.body) as Map<String, dynamic>;

      final bool success = (jsonResponse['success'] ?? false) == true;
      if (!success) {
        return {
          'success': false,
          'error': 'API hatası',
          'message': (jsonResponse['error'] ?? 'Bilinmeyen hata').toString(),
        };
      }

      // Backend formatı:
      // { success: true, prediction: <double>, message: <string>, details: {luminance, raw_prediction} }
      final double nsb = (jsonResponse['prediction'] is num)
          ? (jsonResponse['prediction'] as num).toDouble()
          : double.tryParse(jsonResponse['prediction']?.toString() ?? '') ?? 0.0;

      final String backendMessage = (jsonResponse['message'] ?? '').toString();
      final Map<String, dynamic> details =
          (jsonResponse['details'] is Map<String, dynamic>)
              ? (jsonResponse['details'] as Map<String, dynamic>)
              : <String, dynamic>{};

      final ui = _uiFromNsb(nsb, backendMessage);

      // UI detaylarında göstermek için
      String exposureTimeStr = exposureTime?.trim().isNotEmpty == true
          ? '${exposureTime!.trim()} sn'
          : 'Belirtilmedi';

      int altitudeVal = 0;
      if (altitude != null && altitude.trim().isNotEmpty) {
        altitudeVal = int.tryParse(altitude.trim()) ?? 0;
      }

      return {
        'success': true,

        // ✅ Gerçek NSB (backend prediction)
        'nsb_score': nsb,

        // UI alanları
        'pollution_level': ui['pollution_level'],
        'color_code': ui['color_code'],
        'description': ui['description'],
        'category': ui['category'],
        'icon': ui['icon'],

        // Backend’te confidence yok; boş dönüyoruz (istersen hesaplarım)
        'confidence': <String, dynamic>{},

        // Detaylar
        'details': {
          'exposure_time': exposureTimeStr,
          'altitude': altitudeVal,
          'luminance': details['luminance'],
          'raw_prediction': details['raw_prediction'],
        },
      };
    } on SocketException {
      return {
        'success': false,
        'error': 'Ağ Bağlantı Hatası',
        'message': 'İnternet bağlantınızı kontrol edin',
      };
    } on TimeoutException {
      return {
        'success': false,
        'error': 'Zaman Aşımı',
        'message': 'İstek zaman aşımına uğradı',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Beklenmeyen Hata',
        'message': e.toString(),
      };
    }
  }
}