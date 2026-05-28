import 'dart:collection';

import 'package:flutter/material.dart';

import '../l10n/translation.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';
import '../services/key_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.api,
    required this.keyService,
    required this.symbol,
    required this.token,
  });

  final ApiService api;
  final KeyService keyService;
  final String symbol;
  final String token;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final Queue<HistoryItem> _cachedHistory = Queue<HistoryItem>();

  String _walletAddress = '';
  int _nextPage = 1;
  bool _hasMore = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final address = await widget.keyService.getWalletAddress();
    if (!mounted) return;
    setState(() {
      _walletAddress = address;
      _cachedHistory.clear();
      _nextPage = 1;
      _hasMore = true;
    });
    await _loadNextPage();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 320;
    if (_scrollController.position.pixels >= threshold) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loading || !_hasMore || _walletAddress.isEmpty) return;

    setState(() {
      _loading = true;
    });

    try {
      final response = await widget.api.getHistory(
        walletAddress: _walletAddress,
        page: _nextPage,
        limit: 20,
        token: widget.token,
      );

      if (!mounted) return;
      setState(() {
        _cachedHistory.addAll(response.history);
        _nextPage = _nextPage + 1;
        _hasMore = response.hasMore;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(T.of(context, 'failure_message', [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() {
      _cachedHistory.clear();
      _nextPage = 1;
      _hasMore = true;
    });
    await _loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final history = _cachedHistory.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(T.of(context, 'transaction_history')),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: history.isEmpty && !_loading
          ? Center(
              child: Text(
                T.of(context, 'tx_no_history'),
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            )
          : ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                if (index >= history.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final item = history[index];
                final isSend = _isOutgoingHistoryType(item.type);

                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isSend
                          ? Colors.red.withValues(alpha: 0.12)
                          : Colors.green.withValues(alpha: 0.12),
                      child: Icon(
                        isSend ? Icons.north_east : Icons.south_west,
                        color: isSend ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSend ? T.of(context, 'tx_send') : T.of(context, 'tx_receive'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.counterParty,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            item.date,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isSend ? '-' : '+'} ${item.amount} ${widget.symbol}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isSend ? null : Colors.green,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemCount: history.length + (_loading ? 1 : 0),
            ),
    );
  }

  bool _isOutgoingHistoryType(String type) {
    switch (type.toLowerCase()) {
      case 'send':
      case 'transfer_out':
      case 'withdrawal':
      case 'bet':
        return true;
      default:
        return false;
    }
  }
}
