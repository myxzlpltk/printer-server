import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printer_server/controllers/history_state.dart';

final historyProvider = StateNotifierProvider.autoDispose<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this.ref) : super(const HistoryState());

  final Ref ref;

  /// When user add data
  void add(String result) async {
    state = state.copyWith(
      htmlData: result,
      lastPrinted: DateTime.now(),
    );
  }
}
