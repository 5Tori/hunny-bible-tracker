import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/theme/app_theme.dart';
import '../content/data/content_api_client.dart';
import '../read/data/read_repository.dart';

class DiscoverScreen extends StatefulWidget {
  DiscoverScreen({
    super.key,
    required this.readRepository,
    ContentApiClient? contentApiClient,
    this.onPlanStarted,
  }) : contentApiClient = contentApiClient ?? ContentApiClient();

  final ReadRepository readRepository;
  final ContentApiClient contentApiClient;
  final VoidCallback? onPlanStarted;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _search = TextEditingController();

  List<RemoteContent> _contents = const [];
  var _loading = true;
  var _offline = false;
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
        _offline = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _offline = false;
      _error = null;
    });

    try {
      if (!await widget.contentApiClient.canReachApi(force: true)) {
        if (!mounted) return;
        setState(() {
          _contents = const [];
          _loading = false;
          _offline = true;
        });
        return;
      }
      final contents = await widget.contentApiClient.fetchPublishedContent(
        sort: 'featured',
        language: 'en',
        limit: 50,
        skipReachabilityCheck: true,
      );
      if (!mounted) return;
      setState(() {
        _contents = contents;
        _loading = false;
        _offline = false;
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
    final sorted = types.toList()
      ..sort((a, b) {
        final aOrder = _typeSortOrder(a);
        final bOrder = _typeSortOrder(b);
        if (aOrder != bOrder) return aOrder.compareTo(bOrder);
        return a.compareTo(b);
      });
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
        ...content.sections.map((section) => section.title),
        ...content.sections.map((section) => section.body),
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
    showContentDetailSheet(
      context,
      content: content,
      readRepository: widget.readRepository,
      onPlanStarted: widget.onPlanStarted,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Discover',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                if (!_loading && _contents.isNotEmpty)
                  Text(
                    '${filtered.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mutedInk,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
                        icon: const Icon(Icons.close, size: 20),
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
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _contentTypes.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _FilterChip(
                      label: 'All',
                      selected: _selectedType == null,
                      onTap: () => setState(() => _selectedType = null),
                    );
                  }
                  final type = _contentTypes[index - 1];
                  return _FilterChip(
                    label: _typeLabel(type),
                    selected: _selectedType == type,
                    onTap: () => setState(() => _selectedType = type),
                  );
                },
              ),
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tags.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _FilterChip(
                        label: 'Any tag',
                        selected: _selectedTagKey == null,
                        onTap: () => setState(() => _selectedTagKey = null),
                      );
                    }
                    final tag = _tags[index - 1];
                    final key = '${tag.type}:${tag.key}';
                    return _FilterChip(
                      label: tag.name,
                      selected: _selectedTagKey == key,
                      onTap: () => setState(() => _selectedTagKey = key),
                    );
                  },
                ),
              ),
            ],
            if (_hasActiveFilters) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${filtered.length} result${filtered.length == 1 ? '' : 's'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.mutedInk,
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
            const SizedBox(height: 18),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (_error != null)
              _StatePanel(
                title: _error!,
                message: 'Pull to refresh.',
                actionLabel: 'Try again',
                onAction: _loadContent,
              )
            else if (_offline)
              _StatePanel(
                title: "You're offline.",
                message:
                    'Discover search is available when you are back online.',
                actionLabel: 'Try again',
                onAction: _loadContent,
              )
            else if (!widget.contentApiClient.isConfigured)
              const _StatePanel(
                title: 'Discover unavailable.',
                message: 'API base URL is missing.',
              )
            else if (filtered.isEmpty)
              _StatePanel(
                title: 'No content found.',
                message:
                    _hasActiveFilters ? 'Clear filters and try again.' : '',
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
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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
    final subtitle = _contentSubtitle(content);
    const imageWidth = 82.0;
    const imageHeight = 116.0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: imageUrl == null
                    ? _ImageFallback(
                        size: imageWidth,
                        height: imageHeight,
                        icon: _typeIcon(content.contentType),
                      )
                    : Image.network(
                        imageUrl,
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ImageFallback(
                          size: imageWidth,
                          height: imageHeight,
                          icon: _typeIcon(content.contentType),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _contentMeta(content),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mutedInk,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mutedInk,
                            ),
                      ),
                    ],
                    if (content.tags.isNotEmpty) ...[
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final tag in content.tags.take(3))
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

class _ContentDetailSheet extends StatefulWidget {
  const _ContentDetailSheet({
    required this.content,
    required this.readRepository,
    this.onPlanStarted,
  });

  final RemoteContent content;
  final ReadRepository readRepository;
  final VoidCallback? onPlanStarted;

  @override
  State<_ContentDetailSheet> createState() => _ContentDetailSheetState();
}

class _ContentDetailSheetState extends State<_ContentDetailSheet> {
  late final PageController _slideController;
  var _slideIndex = 0;
  final Set<String> _subscribedPlanIds = {};
  final Set<String> _startingPlanIds = {};

  RemoteContent get content => widget.content;

  @override
  void initState() {
    super.initState();
    _slideController = PageController();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _startRelatedPlan(RemoteContentRelatedPlan plan) async {
    if (_startingPlanIds.contains(plan.id)) return;
    final alreadySubscribed = _subscribedPlanIds.contains(plan.id);
    setState(() => _startingPlanIds.add(plan.id));
    try {
      try {
        await widget.readRepository.addPlanFromTemplate(plan.templateKey);
      } on ArgumentError {
        await widget.readRepository.refreshPlanTemplatesFromRemote();
        await widget.readRepository.addPlanFromTemplate(plan.templateKey);
      }
      if (!mounted) return;
      setState(() => _subscribedPlanIds.add(plan.id));
      widget.onPlanStarted?.call();
      if (!alreadySubscribed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plan subscribed')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start this plan.')),
      );
    } finally {
      if (mounted) {
        setState(() => _startingPlanIds.remove(plan.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageAssets = content.assets.where(_isImageAsset).toList();
    final videoAsset = _firstVideoAsset(content.assets);
    final media = _ContentMediaBlock(
      content: content,
      imageAssets: imageAssets,
      videoAsset: videoAsset,
      slideController: _slideController,
      slideIndex: _slideIndex,
      onSlideChanged: (index) => setState(() => _slideIndex = index),
      onOpenUrl: _openUrl,
    );
    final otherAssets = content.assets
        .where((asset) => !_isImageAsset(asset) && !_isVideoAsset(asset))
        .toList();

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
                Expanded(
                  child: Text(
                    _contentDetailMeta(content),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mutedInk,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              content.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
            if (content.author != null) ...[
              const SizedBox(height: 14),
              _AuthorByline(author: content.author!),
            ],
            if (media.hasMedia) ...[
              const SizedBox(height: 18),
              media,
            ],
            if (content.summary != null) ...[
              const SizedBox(height: 18),
              Text(
                content.summary!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
            ],
            if (content.verseText != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.softSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  content.verseText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.ink,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
            if (content.contentType == 'essay' &&
                content.sections.isNotEmpty) ...[
              const SizedBox(height: 18),
              for (final section in content.sections)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _EssaySectionBlock(section: section),
                ),
            ] else if (content.body != null) ...[
              const SizedBox(height: 18),
              Text(
                content.body!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.ink,
                      height: 1.55,
                    ),
              ),
            ],
            if (otherAssets.isNotEmpty) ...[
              const SizedBox(height: 18),
              for (final asset in otherAssets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AssetRow(asset: asset),
                ),
            ],
            if (content.relatedPlans.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Want to explore the full story?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              for (final plan in content.relatedPlans)
                _RelatedPlanCard(
                  plan: plan,
                  starting: _startingPlanIds.contains(plan.id),
                  subscribed: _subscribedPlanIds.contains(plan.id),
                  onStart: () => _startRelatedPlan(plan),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _AuthorByline extends StatelessWidget {
  const _AuthorByline({required this.author});

  final RemoteContentAuthor author;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AuthorAvatar(author: author),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  author.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                ),
              ),
              if (author.isVerified) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.author});

  final RemoteContentAuthor author;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = author.avatarImageUrl;
    if (avatarUrl != null) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _AuthorInitial(author: author),
        ),
      );
    }
    return _AuthorInitial(author: author);
  }
}

class _AuthorInitial extends StatelessWidget {
  const _AuthorInitial({required this.author});

  final RemoteContentAuthor author;

  @override
  Widget build(BuildContext context) {
    final initial = author.displayName.trim().isEmpty
        ? '?'
        : String.fromCharCode(author.displayName.trim().runes.first)
            .toUpperCase();
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.accentYellow,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        initial,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.ink,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _RelatedPlanCard extends StatelessWidget {
  const _RelatedPlanCard({
    required this.plan,
    required this.starting,
    required this.subscribed,
    required this.onStart,
  });

  final RemoteContentRelatedPlan plan;
  final bool starting;
  final bool subscribed;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (plan.totalChapters != null) '${plan.totalChapters} chapters',
      if (plan.estimatedMinutes != null) '~${plan.estimatedMinutes} min/ch',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              meta,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: starting ? null : onStart,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.ink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                starting
                    ? 'Starting...'
                    : subscribed
                        ? 'Continue'
                        : 'Start this plan',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EssaySectionBlock extends StatelessWidget {
  const _EssaySectionBlock({required this.section});

  final RemoteContentSection section;

  @override
  Widget build(BuildContext context) {
    final imageUrl = section.imageUrl;
    final imageCaption = section.imageCaption;
    final title = section.title;
    final body = section.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null) ...[
          _EssaySectionImage(section: section),
          const SizedBox(height: 12),
        ],
        if (imageCaption != null && imageUrl == null) ...[
          Text(
            imageCaption,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                ),
          ),
          const SizedBox(height: 8),
        ],
        if (title != null) ...[
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
        ],
        if (body != null)
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.ink,
                  height: 1.6,
                ),
          ),
      ],
    );
  }
}

class _EssaySectionImage extends StatelessWidget {
  const _EssaySectionImage({required this.section});

  final RemoteContentSection section;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            section.imageUrl!,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImageFallback(
              size: double.infinity,
              height: 180,
              icon: Icons.image_outlined,
            ),
          ),
          if (section.imageCaption != null) ...[
            const SizedBox(height: 6),
            Text(
              section.imageCaption!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContentMediaBlock extends StatelessWidget {
  const _ContentMediaBlock({
    required this.content,
    required this.imageAssets,
    required this.videoAsset,
    required this.slideController,
    required this.slideIndex,
    required this.onSlideChanged,
    required this.onOpenUrl,
  });

  final RemoteContent content;
  final List<RemoteContentAsset> imageAssets;
  final RemoteContentAsset? videoAsset;
  final PageController slideController;
  final int slideIndex;
  final ValueChanged<int> onSlideChanged;
  final ValueChanged<String> onOpenUrl;

  bool get hasMedia {
    if (content.contentType == 'essay') {
      return false;
    }
    if (content.contentType == 'cartoon') {
      return imageAssets.isNotEmpty || content.coverImageUrl != null;
    }
    if (content.contentType == 'video') {
      return videoAsset != null ||
          content.externalUrl != null ||
          content.coverImageUrl != null;
    }
    return content.coverImageUrl != null || imageAssets.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (content.contentType == 'essay') {
      return const SizedBox.shrink();
    }

    if (content.contentType == 'cartoon') {
      final slides = imageAssets;
      if (slides.isNotEmpty) {
        return _CartoonSlider(
          slides: slides,
          controller: slideController,
          index: slideIndex,
          onChanged: onSlideChanged,
        );
      }
      if (content.coverImageUrl != null) {
        return _SquareNetworkImage(url: content.coverImageUrl!);
      }
    }

    if (content.contentType == 'video') {
      if (videoAsset == null &&
          content.externalUrl == null &&
          content.coverImageUrl != null) {
        return _CoverMedia(url: content.coverImageUrl!);
      }
      return _VideoMediaBlock(
        content: content,
        asset: videoAsset,
        onOpenUrl: onOpenUrl,
      );
    }

    if (content.coverImageUrl != null) {
      return _CoverMedia(url: content.coverImageUrl!);
    }

    if (imageAssets.isNotEmpty) {
      return _ImageAsset(asset: imageAssets.first);
    }

    return const SizedBox.shrink();
  }
}

class _CartoonSlider extends StatelessWidget {
  const _CartoonSlider({
    required this.slides,
    required this.controller,
    required this.index,
    required this.onChanged,
  });

  final List<RemoteContentAsset> slides;
  final PageController controller;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: PageView.builder(
              controller: controller,
              itemCount: slides.length,
              onPageChanged: onChanged,
              itemBuilder: (context, slideIndex) {
                final slide = slides[slideIndex];
                return Image.network(
                  slide.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _ImageFallback(
                    size: double.infinity,
                    height: double.infinity,
                    icon: Icons.collections_outlined,
                  ),
                );
              },
            ),
          ),
        ),
        if (slides.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slides.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: i == index ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == index ? AppTheme.ink : AppTheme.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _VideoMediaBlock extends StatelessWidget {
  const _VideoMediaBlock({
    required this.content,
    required this.asset,
    required this.onOpenUrl,
  });

  final RemoteContent content;
  final RemoteContentAsset? asset;
  final ValueChanged<String> onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final url = asset?.url ?? content.externalUrl;
    final thumbnail = content.coverImageUrl;
    final youtubeVideoId =
        url == null ? null : YoutubePlayerController.convertUrlToId(url);
    final isShorts = url == null ? false : _isYoutubeShortsUrl(url);

    if (youtubeVideoId != null) {
      return _YoutubeVideoPlayer(
        videoId: youtubeVideoId,
        isShorts: isShorts,
      );
    }

    return Material(
      color: AppTheme.softSurface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: url == null ? null : () => onOpenUrl(url),
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: isShorts ? 9 / 16 : 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnail != null)
                  Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  )
                else
                  Container(color: AppTheme.softSurface),
                Container(color: Colors.black.withAlpha(38)),
                Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: AppTheme.ink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _YoutubeVideoPlayer extends StatefulWidget {
  const _YoutubeVideoPlayer({
    required this.videoId,
    required this.isShorts,
  });

  final String videoId;
  final bool isShorts;

  @override
  State<_YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<_YoutubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController(widget.videoId);
  }

  @override
  void didUpdateWidget(covariant _YoutubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId == widget.videoId) return;
    _controller.close();
    _controller = _createController(widget.videoId);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  YoutubePlayerController _createController(String videoId) {
    return YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        enableCaption: true,
        playsInline: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: widget.isShorts ? 9 / 16 : 16 / 9,
        autoFullScreen: true,
      ),
    );
  }
}

class _CoverMedia extends StatelessWidget {
  const _CoverMedia({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        height: 210,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

class _SquareNetworkImage extends StatelessWidget {
  const _SquareNetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const _ImageFallback(
            size: double.infinity,
            height: double.infinity,
            icon: Icons.collections_outlined,
          ),
        ),
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.asset});

  final RemoteContentAsset asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _ImageFallback(size: 52, icon: _assetIcon(asset.assetType)),
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

class _ImageAsset extends StatelessWidget {
  const _ImageAsset({required this.asset});

  final RemoteContentAsset asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            asset.url,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImageFallback(
              size: double.infinity,
              height: 180,
            ),
          ),
          if (asset.caption != null) ...[
            const SizedBox(height: 6),
            Text(
              asset.caption!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mutedInk,
                  ),
            ),
          ],
        ],
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
        borderRadius: BorderRadius.circular(6),
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
  const _ImageFallback({
    this.size = 76,
    this.height,
    this.icon = Icons.auto_stories_outlined,
  });

  final double size;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: height ?? size,
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Icon(icon, color: AppTheme.mutedInk),
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
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

String? _contentSubtitle(RemoteContent content) {
  return content.summary ??
      content.primaryVerseReference ??
      content.author?.displayName;
}

String _contentMeta(RemoteContent content) {
  final parts = [
    _typeLabel(content.contentType),
    if (content.durationSeconds != null)
      _durationLabel(content.durationSeconds!),
    if (content.author != null) content.author!.displayName,
    if (content.primaryVerseReference != null) content.primaryVerseReference!,
  ];
  return parts.join(' · ');
}

String _contentDetailMeta(RemoteContent content) {
  final parts = [
    _typeLabel(content.contentType),
    if (content.durationSeconds != null)
      _durationLabel(content.durationSeconds!),
  ];
  return parts.join(' · ');
}

bool _isImageAsset(RemoteContentAsset asset) {
  return asset.assetType == 'image' ||
      asset.mimeType?.startsWith('image/') == true;
}

bool _isVideoAsset(RemoteContentAsset asset) {
  return asset.assetType == 'video' ||
      asset.mimeType?.startsWith('video/') == true;
}

bool _isYoutubeShortsUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return false;
  final host = uri.host.toLowerCase();
  if (!host.contains('youtube.com') && !host.contains('youtube-nocookie.com')) {
    return false;
  }
  return uri.pathSegments.any((segment) => segment.toLowerCase() == 'shorts');
}

RemoteContentAsset? _firstVideoAsset(List<RemoteContentAsset> assets) {
  for (final asset in assets) {
    if (_isVideoAsset(asset)) return asset;
  }
  return null;
}

IconData _typeIcon(String type) {
  return switch (type) {
    'video' => Icons.play_arrow_rounded,
    'essay' => Icons.article_outlined,
    'cartoon' => Icons.collections_outlined,
    'message' => Icons.chat_bubble_outline,
    _ => Icons.auto_stories_outlined,
  };
}

IconData _assetIcon(String type) {
  return switch (type) {
    'video' => Icons.play_arrow_rounded,
    'audio' => Icons.graphic_eq,
    'link' => Icons.link,
    _ => Icons.insert_drive_file_outlined,
  };
}

int _typeSortOrder(String type) {
  return switch (type) {
    'message' => 0,
    'video' => 1,
    'essay' => 2,
    'cartoon' => 3,
    _ => 99,
  };
}

String _typeLabel(String type) {
  return switch (type) {
    'message' => 'Message',
    'video' => 'Video',
    'essay' => 'Essay',
    'cartoon' => 'Cartoon',
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

Future<void> showContentDetailSheet(
  BuildContext context, {
  required RemoteContent content,
  required ReadRepository readRepository,
  VoidCallback? onPlanStarted,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _ContentDetailSheet(
      content: content,
      readRepository: readRepository,
      onPlanStarted: onPlanStarted,
    ),
  );
}
