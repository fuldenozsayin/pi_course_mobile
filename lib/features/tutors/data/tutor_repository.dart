import 'package:dio/dio.dart';
import '../../../core/api_client.dart';
import 'models/tutor.dart';

class TutorPage {
  final List<Tutor> items;
  final int? nextOffset; // null => daha yok
  TutorPage({required this.items, required this.nextOffset});
}

class TutorRepository {
  final ApiClient _api;
  TutorRepository(this._api);

  Future<Tutor> detail(int id) async {
    final r = await _api.dio.get('/tutors/$id');
    return Tutor.fromJson((r.data as Map).cast<String, dynamic>());
  }

  /// DRF LimitOffsetPagination destekli liste
  Future<TutorPage> listPaged({
    int? subjectId,
    String? search,
    String ordering = '-rating',
    int limit = 20,
    int offset = 0,
  }) async {
    final r = await _api.dio.get('/tutors', queryParameters: {
      if (subjectId != null) 'subject': subjectId,
      if (search != null && search.isNotEmpty) 'search': search,
      'ordering': ordering,
      'limit': limit,
      'offset': offset,
    });

    final data = r.data;
    List raw;
    String? nextUrl;

    if (data is Map<String, dynamic> && data['results'] is List) {
      raw = data['results'] as List;
      nextUrl = data['next'] as String?;
    } else if (data is List) {
      raw = data;
      nextUrl = null;
    } else {
      throw StateError('Unexpected /tutors payload: $data');
    }

    final items = raw
        .map((e) => Tutor.fromJson((e as Map).cast<String, dynamic>()))
        .toList(growable: false);

    int? nextOffset;
    if (nextUrl != null && nextUrl.isNotEmpty) {
      try {
        final qp = Uri.parse(nextUrl).queryParameters;
        final off = qp['offset'];
        nextOffset = off == null ? null : int.tryParse(off);
      } catch (_) {
        nextOffset = null;
      }
    }

    return TutorPage(items: items, nextOffset: nextOffset);
  }

  // ---------- Tutor özel uçlar / normalizasyon ----------

  /// /api/me cevabını tutor açısından normalize eder.
  /// Bazı backend’lerde tutor alanları `tutor_profile` altında gelir.
  Future<Map<String, dynamic>> meTutor() async {
    final r = await _api.dio.get('/me');
    final me = (r.data as Map).cast<String, dynamic>();

    final profile = (me['tutor_profile'] as Map?)?.cast<String, dynamic>();
    if (profile == null) return me;

    // Kök seviyeye yedir (subjects / hourly_rate / rating)
    return {
      ...me,
      'subjects': profile['subjects'] ?? me['subjects'],
      'hourly_rate': profile['hourly_rate'] ?? me['hourly_rate'],
      'rating': profile['rating'] ?? me['rating'],
    };
  }

  /// Sistem ders listesi – hem düz listeyi hem de {results:[...]}’ı destekler.
  Future<List<Map<String, dynamic>>> subjects() async {
    final r = await _api.dio.get('/subjects');
    final data = r.data;

    late final List list;
    if (data is Map<String, dynamic> && data['results'] is List) {
      list = data['results'] as List;
    } else if (data is List) {
      list = data;
    } else {
      throw StateError('Unexpected /subjects payload: $data');
    }

    return list
        .cast<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);
  }

  /// Tutor profilini güncelle (backend’in PATCH /api/me’yi kabul ettiğini varsayıyoruz).
  Future<void> updateTutor({
    required List<int> subjectIds,
    required int hourlyRate,
    required double rating,
  }) async {
    await _api.dio.patch('/me', data: {
      'subjects': subjectIds,
      'hourly_rate': hourlyRate,
      'rating': rating,
    });
  }
}
