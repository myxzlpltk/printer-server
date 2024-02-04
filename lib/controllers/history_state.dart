import 'package:equatable/equatable.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.notify = false,
    this.lastPrinted,
    this.htmlData,
  });

  final bool notify;
  final DateTime? lastPrinted;
  final String? htmlData;

  HistoryState copyWith({
    bool? notify,
    DateTime? lastPrinted,
    String? htmlData,
  }) {
    return HistoryState(
      notify: notify ?? this.notify,
      lastPrinted: lastPrinted ?? this.lastPrinted,
      htmlData: htmlData ?? this.htmlData,
    );
  }

  @override
  List<Object?> get props => [notify, lastPrinted, htmlData];
}
