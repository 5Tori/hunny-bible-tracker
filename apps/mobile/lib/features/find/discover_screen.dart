import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../content/data/content_api_client.dart';

class DiscoverScreen extends StatefulWidget {
  DiscoverScreen({
    super.key,
    ContentApiClient? contentApiClient,
  }) : contentApiClient = contentApiClient ?? ContentApiClient();

  final ContentApiClient contentApiClient;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _search = TextEditingController();

  List<RemoteContent> _contents = const [];
  var _loading = true;
  String? _error;
  String? _selectedType;
  String? _selectedTagKey;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    if (!widget.contentApiClient.isConfigured) {
      if (!mounted) return;
      setState(() {
        _contents = const [];
        _loading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final contents = await widget.contentApiClient.fetchPublishedContent(
        sort: 'featured',
        language: 'en',
        limit: 50,
      );
      if (!mounted) return;
      setState(() {
        _contents = contents;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load content.';
      });
    }
  }

  bool get _hasActiveFilters =>
      _search.text.trim().isNotEmpty ||
      _selectedType != null ||
      _selectedTagKey != null;

  List<String> get _contentTypes {
    final types = _contents.map((content) => content.contentType).toSet()
      ..removeWhere((type) => type.trim().isEmpty);
    final sorted = types.toList()..sort();
    return sorted;
  }

  List<RemoteContentTag> get _tags {
    final byKey = <String, RemoteContentTag>{};
    for (final content in _contents) {
      for (final tag in content.tags) {
        byKey['${tag.type}:${tag.key}'] = tag;
      }
    }
    final tags = byKey.values.toList()
      ..sort((a, b) {
        final typeCompare = a.type.compareTo(b.type);
        if (typeCompare != 0) return typeCompare;
        return a.name.compareTo(b.name);
      });
    return tags;
  }

  List<RemoteContent> get _filteredContents {
    final query = _search.text.trim().toLowerCase();
    return _contents.where((content) {
      if (_selectedType != null && content.contentType != _selectedType) {
        return false;
      }
      if (_selectedTagKey != null &&
          !content.tags
              .any((tag) => '${tag.type}:${tag.key}' == _selectedTagKey)) {
        return false;
      }
      if (query.isEmpty) return true;

      final fields = [
        content.title,
        content.subtitle,
        content.summary,
        content.body,
        content.primaryVerseReference,
        content.author?.displayName,
        ...content.tags.map((tag) => tag.name),
        ...content.relatedPlans.map((plan) => plan.title),
      ].whereType<String>().map((value) => value.toLowerCase());

      return fields.any((field) => field.contains(query));
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _search.clear();
      _selectedType = null;
      _selectedTagKey = null;
    });
  }

  void _openContent(RemoteContent content) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ContentDetailSheet(content: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredContents;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadContent,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text('Discover', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Find messages, videos, essays, and visual stories.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search topics, references, authors...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedInk.withAlpha(153),
                    ),
                prefixIcon: const Icon(Icons.search, color: AppTheme.mutedInk),
                suffixIcon: _search.text.trim().isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() => _search.clear());
                        },
                      ),
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
            const SizedBox(height: 18),
            _SectionLabel(title: 'TYPE'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedType == null,
                  onTap: () => setState(() => _selectedType = null),
                ),
                for (final type in _contentTypes)
                  _FilterChip(
                    label: _typeLabel(type),
                    selected: _selectedType == type,
                    onTap: () => setState(() => _selectedType = type),
                  ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionLabel(title: 'TAGS'),
              const SizedBox(height: 10),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tags.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _FilterChip(
                        label: 'All tags',
                        selected: _selectedTagKey == null,
                        onTap: () => setState(() => _selectedTagKey = null),
                      );
                    }
                    final tag = _tags[index - 1];
                    final key = '${tag.type}:${tag.key}';
                    return _FilterChip(
                      label: '${tag.name} · ${tag.type}',
                      selected: _selectedTagKey == key,
                      onTap: () => setState(() => _selectedTagKey = key),
                    );
                  },
                ),
              ),
            ],
            if (_hasActiveFilters) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
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
            const SizedBox(height: 24),
            _SectionLabel(title: _hasActiveFilters ? 'RESULTS' : 'ALL CONTENT'),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_error != null)
              _StatePanel(
                title: _error!,
                message: 'Pull to refresh or check the API connection.',
                actionLabel: 'Try again',
                onAction: _loadContent,
              )
            else if (!widget.contentApiClient.isConfigured)
              const _StatePanel(
                title: 'Content API is not configured.',
                message:
                    'Run the app with HUNNY_API_BASE_URL to load Discover content.',
              )
            else if (filtered.isEmpty)
              _StatePanel(
                title: 'No content found.',
                message: _hasActiveFilters
                    ? 'Try a different search or clear filters.'
                    : 'Publish content in the admin dashboard to fill this list.',
              )
            else
              for (final content in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ContentCard(
                    content: content,
                    selectedTagKey: _selectedTagKey,
                    onTap: () => _openContent(content),
                  ),
                ),
          ],
        ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppTheme.ink : AppTheme.border,
            ),
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? Colors.white : AppTheme.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.content,
    required this.selectedTagKey,
    required this.onTap,
  });

  final RemoteContent content;
  final String? selectedTagKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = content.coverImageUrl;
    final reference = content.primaryVerseReference;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ImageFallback(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypePill(type: content.contentType),
                        if (content.durationSeconds != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _durationLabel(content.durationSeconds!),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.mutedInk),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content.summary ??
                          reference ??
                          content.author?.displayName ??
                          'Open to read more.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mutedInk,
                          ),
                    ),
                    if (content.tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in content.tags.take(4))
                            _SmallTag(
                              tag: tag,
                              selected:
                                  '${tag.type}:${tag.key}' == selectedTagKey,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentDetailSheet extends StatelessWidget {
  const _ContentDetailSheet({required this.content});

  final RemoteContent content;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Row(
              children: [
                _TypePill(type: content.contentType),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (content.coverImageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  content.coverImageUrl!,
                  height: 210,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 18),
            ],
            Text(
              content.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (content.author != null) ...[
              const SizedBox(height: 6),
              Text(
                'By ${content.author!.displayName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
              ),
            ],
            if (content.primaryVerseReference != null) ...[
              const SizedBox(height: 10),
              Text(
                content.bibleVersion == null
                    ? content.primaryVerseReference!
                    : '${content.primaryVerseReference!} · ${content.bibleVersion!}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mutedInk,
                    ),
              ),
            ],
            if (content.summary != null) ...[
              const SizedBox(height: 18),
              Text(
                content.summary!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            if (content.body != null) ...[
              const SizedBox(height: 16),
              Text(
                content.body!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.ink,
                      height: 1.55,
                    ),
              ),
            ],
            if (content.assets.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionLabel(title: 'ASSETS'),
              const SizedBox(height: 10),
              for (final asset in content.assets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AssetRow(asset: asset),
                ),
            ],
            if (content.relatedPlans.isNotEmpty) ...[
              const SizedBox(height: 24),
              const _SectionLabel(title: 'RELATED PLANS'),
              const SizedBox(height: 10),
              for (final plan in content.relatedPlans)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.softSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              [
                                if (plan.totalChapters != null)
                                  '${plan.totalChapters} chapters',
                                if (plan.estimatedMinutes != null)
                                  '${plan.estimatedMinutes} min',
                              ].join(' · '),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.asset});

  final RemoteContentAsset asset;

  @override
  Widget build(BuildContext context) {
    final isImage = asset.assetType == 'image' ||
        asset.mimeType?.startsWith('image/') == true;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                asset.url,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _ImageFallback(size: 52),
              ),
            )
          else
            const _ImageFallback(size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.title ?? asset.assetRole,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  asset.caption ?? asset.assetType,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _typeLabel(type),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.ink,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({
    required this.tag,
    required this.selected,
  });

  final RemoteContentTag tag;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AppTheme.accentYellow : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: selected ? AppTheme.ink : AppTheme.border),
      ),
      child: Text(
        tag.name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.ink,
            ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Icon(Icons.auto_stories_outlined, color: AppTheme.mutedInk),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

String _typeLabel(String type) {
  return switch (type) {
    'message' => 'Message',
    'video' => 'Video',
    'essay' => 'Essay',
    'webtoon' => 'Webtoon',
    _ => type,
  };
}

String _durationLabel(int seconds) {
  final minutes = (seconds / 60).round();
  if (minutes < 1) return '<1m';
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
}
