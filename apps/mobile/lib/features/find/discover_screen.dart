import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'discover_mock.dart';
import 'discover_models.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _search = TextEditingController();

  final Set<String> _keywords = {};
  final Set<String> _topics = {};
  final Set<DiscoverLength> _lengths = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _search.text.trim().isNotEmpty ||
      _keywords.isNotEmpty ||
      _topics.isNotEmpty ||
      _lengths.isNotEmpty;

  List<DiscoverContentItem> get _filtered {
    return discoverCatalog.where(_matches).toList();
  }

  bool _matches(DiscoverContentItem item) {
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      final inTitle = item.title.toLowerCase().contains(q);
      final inRef = item.reference.toLowerCase().contains(q);
      final inTags = item.allTags.any((t) => t.toLowerCase().contains(q));
      if (!inTitle && !inRef && !inTags) return false;
    }
    for (final k in _keywords) {
      if (!item.keywordTags.contains(k)) return false;
    }
    for (final t in _topics) {
      if (!item.topicTags.contains(t)) return false;
    }
    if (_lengths.isNotEmpty && !_lengths.contains(item.length)) {
      return false;
    }
    return true;
  }

  bool _tagHighlighted(DiscoverContentItem item, String tag) {
    if (_keywords.contains(tag) || _topics.contains(tag)) return true;
    if (!_hasActiveFilters && tag == item.highlightTag) return true;
    return false;
  }

  void _clearAll() {
    setState(() {
      _search.clear();
      _keywords.clear();
      _topics.clear();
      _lengths.clear();
    });
  }

  void _removeKeyword(String k) => setState(() => _keywords.remove(k));
  void _removeTopic(String t) => setState(() => _topics.remove(t));
  void _removeLength(DiscoverLength l) => setState(() => _lengths.remove(l));

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text('Discover', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Browse by what you need today.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Search verses, topics, content...',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedInk.withAlpha(153),
                  ),
              prefixIcon: const Icon(Icons.search, color: AppTheme.mutedInk),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.ink, width: 1.5),
              ),
            ),
          ),

          if (_hasActiveFilters) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final k in _keywords)
                        _ActiveFilterChip(
                          label: k,
                          onRemove: () => _removeKeyword(k),
                        ),
                      for (final t in _topics)
                        _ActiveFilterChip(
                          label: t,
                          onRemove: () => _removeTopic(t),
                        ),
                      for (final l in _lengths)
                        _ActiveFilterChip(
                          label: l.label,
                          onRemove: () => _removeLength(l),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _clearAll,
                  child: Text(
                    'Clear all',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.ink,
                        ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),
          _SectionLabel(title: 'BY KEYWORD'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final label in discoverKeywordOptions)
                _KeywordChip(
                  label: label,
                  selected: _keywords.contains(label),
                  onTap: () => setState(() {
                    if (_keywords.contains(label)) {
                      _keywords.remove(label);
                    } else {
                      _keywords.add(label);
                    }
                  }),
                ),
            ],
          ),

          const SizedBox(height: 28),
          _SectionLabel(title: 'BY SITUATION / TOPIC'),
          const SizedBox(height: 12),
          for (final topic in discoverTopicOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TopicTile(
                title: topic,
                count: discoverTopicCount(topic),
                selected: _topics.contains(topic),
                onTap: () => setState(() {
                  if (_topics.contains(topic)) {
                    _topics.remove(topic);
                  } else {
                    _topics.add(topic);
                  }
                }),
              ),
            ),

          const SizedBox(height: 20),
          _SectionLabel(title: 'BY LENGTH'),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < discoverLengthOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: _LengthCard(
                    length: discoverLengthOptions[i],
                    count: discoverLengthCount(discoverLengthOptions[i]),
                    selected: _lengths.contains(discoverLengthOptions[i]),
                    onTap: () => setState(() {
                      final l = discoverLengthOptions[i];
                      if (_lengths.contains(l)) {
                        _lengths.remove(l);
                      } else {
                        _lengths.add(l);
                      }
                    }),
                  ),
                ),
              ],
            ],
          ),

          if (_hasActiveFilters) ...[
            const SizedBox(height: 28),
            _SectionLabel(title: 'RESULTS (${filtered.length})'),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No matches. Try clearing a filter or search.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mutedInk,
                        ),
                  ),
                ),
              )
            else
              for (final item in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ResultCard(
                    item: item,
                    tagHighlighted: (t) => _tagHighlighted(item, t),
                  ),
                ),
          ],

          const SizedBox(height: 28),
          _SectionLabel(title: 'ALL CONTENT'),
          const SizedBox(height: 12),
          for (final item in discoverCatalog)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ResultCard(
                item: item,
                tagHighlighted: (t) => _tagHighlighted(item, t),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            letterSpacing: 1.0,
            fontWeight: FontWeight.w700,
            color: AppTheme.mutedInk,
          ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.ink,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.close, size: 16, color: Colors.white.withAlpha(230)),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.ink : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.ink),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? Colors.white : AppTheme.ink,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.title,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.ink : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppTheme.ink,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withAlpha(38)
                      : AppTheme.softSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: selected ? Colors.white : AppTheme.ink,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LengthCard extends StatelessWidget {
  const _LengthCard({
    required this.length,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final DiscoverLength length;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.ink : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                length.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppTheme.ink,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                length.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? Colors.white70 : AppTheme.mutedInk,
                    ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentYellow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.item,
    required this.tagHighlighted,
  });

  final DiscoverContentItem item;
  final bool Function(String tag) tagHighlighted;

  @override
  Widget build(BuildContext context) {
    final tags = item.allTags.toList()..sort();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.reference,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mutedInk,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.softSurface,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppTheme.mutedInk),
                    const SizedBox(width: 4),
                    Text(
                      item.durationLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final t in tags)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: tagHighlighted(t)
                        ? AppTheme.accentYellow
                        : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: tagHighlighted(t) ? AppTheme.ink : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    t,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
