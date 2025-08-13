import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pi_course_mobile/features/auth/providers.dart';
import '../../core/api_client.dart';
import 'data/tutor_repository.dart';
import 'data/models/tutor.dart';

/// Repository provider
final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  return TutorRepository(ref.read(apiClientProvider));
});

/// Liste filtre/sıralama parametreleri
final tutorListParamsProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'subjectId': null,
  'search': '',
  'ordering': '-rating',
  'limit': 20,
});

/// Liste durum modeli
class TutorListState {
  final List<Tutor> items;
  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final String? error;

  const TutorListState({
    required this.items,
    required this.loading,
    required this.loadingMore,
    required this.hasMore,
    this.error,
  });

  factory TutorListState.initial() => const TutorListState(
    items: [],
    loading: true,
    loadingMore: false,
    hasMore: true,
  );

  TutorListState copyWith({
    List<Tutor>? items,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    String? error,
  }) {
    return TutorListState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Sonsuz kaydırma kontrolcüsü
class TutorListController extends StateNotifier<TutorListState> {
  TutorListController(this._ref) : super(TutorListState.initial()) {
    _refresh(); // ilk yükleme
  }

  final Ref _ref;
  int _nextOffset = 0;
  bool _requestInFlight = false;

  Map<String, dynamic> get _params => _ref.read(tutorListParamsProvider);

  Future<void> _refresh() async {
    state = state.copyWith(loading: true, error: null);
    _nextOffset = 0;
    try {
      final page = await _ref.read(tutorRepositoryProvider).listPaged(
        subjectId: _params['subjectId'] as int?,
        search: (_params['search'] as String?)?.trim(),
        ordering: _params['ordering'] as String,
        limit: _params['limit'] as int,
        offset: _nextOffset,
      );
      _nextOffset = page.nextOffset ?? -1;
      state = state.copyWith(
        items: page.items,
        loading: false,
        hasMore: page.nextOffset != null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> refreshWith(Map<String, dynamic> newParams) async {
    _ref.read(tutorListParamsProvider.notifier).state = newParams;
    await _refresh();
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore || _requestInFlight) return;
    if (_nextOffset < 0) return;

    _requestInFlight = true;
    state = state.copyWith(loadingMore: true, error: null);
    try {
      final page = await _ref.read(tutorRepositoryProvider).listPaged(
        subjectId: _params['subjectId'] as int?,
        search: (_params['search'] as String?)?.trim(),
        ordering: _params['ordering'] as String,
        limit: _params['limit'] as int,
        offset: _nextOffset,
      );
      _nextOffset = page.nextOffset ?? -1;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        loadingMore: false,
        hasMore: page.nextOffset != null,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    } finally {
      _requestInFlight = false;
    }
  }
}

/// StateNotifier provider
final tutorListControllerProvider =
StateNotifierProvider<TutorListController, TutorListState>(
      (ref) => TutorListController(ref),
);
