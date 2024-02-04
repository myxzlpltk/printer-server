import 'package:equatable/equatable.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.lastPrinted,
    this.htmlData,
  });

  final DateTime? lastPrinted;
  final String? htmlData;

  HistoryState copyWith({
    DateTime? lastPrinted,
    String? htmlData,
  }) {
    return HistoryState(
      lastPrinted: lastPrinted ?? this.lastPrinted,
      htmlData: htmlData ?? this.htmlData,
    );
  }

  @override
  List<Object?> get props => [lastPrinted, htmlData];
}
