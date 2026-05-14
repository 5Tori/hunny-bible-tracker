// Discover (ex-Find) domain models. Behavior: docs/PRODUCT_ROADMAP.md
enum DiscoverLength {
  quick,
  medium,
  deep,
}

extension DiscoverLengthX on DiscoverLength {
  String get label => switch (this) {
        DiscoverLength.quick => 'Quick',
        DiscoverLength.medium => 'Medium',
        DiscoverLength.deep => 'Deep dive',
      };

  String get subtitle => switch (this) {
        DiscoverLength.quick => 'Under 5 min',
        DiscoverLength.medium => '5–15 min',
        DiscoverLength.deep => '15+ min',
      };
}

/// One browsable content card (verse snippet, devotional, etc.).
class DiscoverContentItem {
  const DiscoverContentItem({
    required this.id,
    required this.title,
    required this.reference,
    required this.durationMinutes,
    required this.keywordTags,
    required this.topicTags,
    required this.length,
    required this.highlightTag,
  });

  final String id;
  final String title;
  final String reference;
  final int durationMinutes;
  final Set<String> keywordTags;
  final Set<String> topicTags;
  final DiscoverLength length;

  /// Tag shown with accent fill in "All content" list (design mock).
  final String highlightTag;

  Set<String> get allTags => {...keywordTags, ...topicTags};

  String get durationLabel {
    if (durationMinutes < 60) return '${durationMinutes}m';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}
