class HistoryItem {
  const HistoryItem({
    required this.type,
    required this.amount,
    required this.counterParty,
    required this.timestamp,
    required this.date,
    required this.txHash,
    required this.blockNumber,
  });

  final String type;
  final String amount;
  final String counterParty;
  final int timestamp;
  final String date;
  final String txHash;
  final String blockNumber;

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    final createdAt = (json['date'] ?? json['createdAt'] ?? '').toString();
    final parsedDate = DateTime.tryParse(createdAt);

    return HistoryItem(
      type: (json['type'] ?? 'unknown').toString(),
      amount: (json['amount'] ?? '0').toString(),
      counterParty: (json['counterParty'] ?? json['counterparty'] ?? '0x...').toString(),
      timestamp: (json['timestamp'] as num?)?.toInt() ?? parsedDate?.millisecondsSinceEpoch ?? 0,
      date: createdAt,
      txHash: (json['txHash'] ?? json['id'] ?? '').toString(),
      blockNumber: (json['blockNumber'] ?? '').toString(),
    );
  }
}

class HistoryResponse {
  const HistoryResponse({
    required this.page,
    required this.hasMore,
    required this.history,
  });

  final int page;
  final bool hasMore;
  final List<HistoryItem> history;
}
