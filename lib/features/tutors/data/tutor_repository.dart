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
    return Tutor.fromJson(r.data as Map<String, dynamic>);
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
      // Sayfalama yoksa tam liste
      raw = data;
      nextUrl = null;
    } else {
      throw StateError('Unexpected /tutors payload: $data');
    }

    final items = raw
        .map((e) => Tutor.fromJson(e as Map<String, dynamic>))
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
}
