import 'dart:async';

import 'package:flutter/material.dart';

import '../data/entry_repository.dart';
import '../l10n/strings.dart';
import '../theme/tokens.dart';
import 'editor_page.dart';
import '../theme/app_icons.dart';

/// S8 Search (FEAT-005). Everything runs on the phone against the encrypted
/// journal; nothing is sent anywhere, so it works without a network.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, required this.repository});
  final EntryRepository repository;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _text = TextEditingController();
  Timer? _debounce;
  List<SearchHit> _hits = const [];
  String _searched = '';
  bool _ran = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), _run);
    setState(() {}); // the clear button
  }

  Future<void> _run() async {
    final q = _text.text;
    List<SearchHit> hits;
    try {
      hits = await widget.repository.search(q);
    } catch (_) {
      return; // the journal was closed because the app locked
    }
    if (!mounted || q != _text.text) return;
    setState(() {
      _hits = hits;
      _searched = q;
      _ran = true;
    });
  }

  Future<void> _open(SearchHit hit) async {
    final entry = await widget.repository.get(hit.id);
    if (entry == null || !mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => EditorPage(repository: widget.repository, entry: entry),
    ));
    if (mounted) await _run(); // the query and the results are kept when coming back
  }

  String _time(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hasQuery = searchQueryFor(_text.text) != null;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(
                  tooltip: S.back,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(AppIcons.back),
                  constraints: const BoxConstraints(minWidth: AppSpace.touchMin, minHeight: AppSpace.touchMin),
                ),
                Expanded(
                  child: Semantics(
                    label: S.searchLabel,
                    textField: true,
                    child: TextField(
                      key: const Key('search-field'),
                      controller: _text,
                      autofocus: true,
                      onChanged: _onChanged,
                      textInputAction: TextInputAction.search,
                      // What the user searches for is private: no suggestions, no learning.
                      enableSuggestions: false,
                      autocorrect: false,
                      enableIMEPersonalizedLearning: false,
                      style: AppType.body.copyWith(color: c.textPrimary),
                      cursorColor: c.actionBg,
                      decoration: InputDecoration(
                        hintText: S.searchHint,
                        hintStyle: AppType.body.copyWith(color: c.textSecondary),
                        filled: true,
                        fillColor: c.surfaceRaised,
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s16, vertical: AppSpace.s16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: c.borderStrong),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: c.borderStrong),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide(color: c.focusRing, width: 2),
                        ),
                        suffixIcon: _text.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: S.clearSearch,
                                onPressed: () {
                                  _text.clear();
                                  _onChanged('');
                                },
                                icon: const Icon(AppIcons.close),
                              ),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpace.s12),
              Expanded(child: _body(c, hasQuery)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AppColors c, bool hasQuery) {
    if (!hasQuery) {
      return Center(child: Text(S.typeAWord, style: AppType.body.copyWith(color: c.textSecondary), textAlign: TextAlign.center));
    }
    if (!_ran || _searched != _text.text) return const SizedBox.shrink();
    if (_hits.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(liveRegion: true, child: Text(S.noResults(_searched.trim()), style: AppType.title, textAlign: TextAlign.center)),
          const SizedBox(height: AppSpace.s8),
          Text(S.tryAnotherWord, style: AppType.body.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(liveRegion: true, child: Text(S.entryCount(_hits.length), style: AppType.caption.copyWith(color: c.textSecondary))),
        const SizedBox(height: AppSpace.s8),
        Expanded(
          child: ListView.builder(
            itemCount: _hits.length,
            itemBuilder: (context, i) {
              final h = _hits[i];
              final note = h.firstMatch;
              return Column(children: [
                Semantics(
                  button: true,
                  label: '${formatDay(h.day)}, ${_time(h.createdAtMs)}. ${S.matched(note ?? '')}',
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => _open(h),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: AppSpace.touchMin),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${formatDay(h.day)}, ${_time(h.createdAtMs)}${note == null ? '' : '  -  ${S.matched(note)}'}',
                              style: AppType.caption.copyWith(color: c.textSecondary),
                            ),
                            const SizedBox(height: AppSpace.s4),
                            Text.rich(
                              TextSpan(children: [
                                for (final (text, matched) in h.pieces)
                                  TextSpan(
                                    text: text,
                                    style: matched
                                        ? TextStyle(
                                            fontWeight: FontWeight.w700,
                                            backgroundColor: c.actionBg.withValues(alpha: 0.22),
                                          )
                                        : null,
                                  ),
                              ]),
                              style: AppType.journal.copyWith(color: c.textPrimary),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: c.borderDefault),
              ]);
            },
          ),
        ),
      ],
    );
  }
}
