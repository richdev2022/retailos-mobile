import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'dart:async' show Timer;

/// Generic paginated list screen with search + pull-to-refresh.
/// Used as a base for products, sales, customers, suppliers, expenses.
abstract class PaginatedListScreen<T> extends ConsumerStatefulWidget {
  const PaginatedListScreen({super.key});

  String get title;
  String get searchHint;
  String get endpoint;
  T itemFromJson(Map<String, dynamic> json);
  Widget buildListItem(BuildContext context, T item);
  Widget? buildFAB(BuildContext context) => null;
  VoidCallback? get onAddTapped => null;

  @override
  ConsumerState<PaginatedListScreen<T>> createState() => _PaginatedListScreenState<T>();
}

class _PaginatedListScreenState<T> extends ConsumerState<PaginatedListScreen<T>> {
  final _scrollController = ScrollController();
  final _searchCtrl = TextEditingController();
  List<T> _items = <T>[];
  int _page = 1;
  int _total = 0;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_loadingMore && _items.length < _total) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _page = 1;
        _items = <T>[];
      }
    });
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get<dynamic>(
        widget.endpoint,
        queryParameters: <String, dynamic>{
          'page': _page.toString(),
          'limit': '20',
          if (_searchCtrl.text.trim().isNotEmpty) 'search': _searchCtrl.text.trim(),
        },
      );
      final data = api.unwrapList<T>(response, (list) => list.map((j) => widget.itemFromJson(j as Map<String, dynamic>)).toList());
      setState(() {
        _items = reset ? data.items : <T>[..._items, ...data.items];
        _total = data.total;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    _page++;
    await _load();
    if (mounted) setState(() => _loadingMore = false);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load(reset: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: widget.buildFAB(context),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => _onSearchChanged(),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(reset: true),
                child: _loading && _items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null && _items.isEmpty
                        ? _ErrorView(error: _error!, onRetry: () => _load(reset: true))
                        : _items.isEmpty
                            ? ListView(
                                children: <Widget>[
                                  const SizedBox(height: 120),
                                  Icon(Icons.inbox_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(height: 12),
                                  Text('Nothing here yet', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Text('Pull to refresh or add a new item.', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                                ],
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _items.length + (_items.length < _total ? 1 : 0),
                                itemBuilder: (BuildContext context, int index) {
                                  if (index >= _items.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                    );
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: widget.buildListItem(context, _items[index]),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text('Something went wrong', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

