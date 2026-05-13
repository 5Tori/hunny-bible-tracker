import 'discover_models.dart';

/// Curated keyword pills (BY KEYWORD).
const discoverKeywordOptions = <String>[
  'Faith',
  'Hope',
  'Love',
  'Grace',
  'Peace',
  'Joy',
  'Wisdom',
  'Mercy',
];

/// Situation / topic rows (BY SITUATION / TOPIC) — counts derived from [discoverCatalog].
const discoverTopicOptions = <String>[
  'Anxiety & Fear',
  'Relationships',
  'Purpose & Calling',
  'Grief & Loss',
  'Gratitude',
];

final discoverLengthOptions = DiscoverLength.values;

/// Mock catalog for UI and filter logic until API exists.
final List<DiscoverContentItem> discoverCatalog = [
  DiscoverContentItem(
    id: '1',
    title: 'Be still and know',
    reference: 'Psalm 46:10',
    durationMinutes: 3,
    keywordTags: {'Faith', 'Peace'},
    topicTags: {'Anxiety & Fear'},
    length: DiscoverLength.quick,
    highlightTag: 'Anxiety & Fear',
  ),
  DiscoverContentItem(
    id: '2',
    title: 'Love is patient',
    reference: '1 Corinthians 13:4–7',
    durationMinutes: 8,
    keywordTags: {'Love', 'Faith'},
    topicTags: {'Relationships'},
    length: DiscoverLength.medium,
    highlightTag: 'Relationships',
  ),
  DiscoverContentItem(
    id: '3',
    title: 'Cast all your anxiety on him',
    reference: '1 Peter 5:7',
    durationMinutes: 12,
    keywordTags: {'Faith', 'Peace'},
    topicTags: {'Anxiety & Fear'},
    length: DiscoverLength.medium,
    highlightTag: 'Peace',
  ),
  DiscoverContentItem(
    id: '4',
    title: 'Plans to give you hope',
    reference: 'Jeremiah 29:11',
    durationMinutes: 6,
    keywordTags: {'Hope', 'Grace'},
    topicTags: {'Purpose & Calling'},
    length: DiscoverLength.medium,
    highlightTag: 'Purpose & Calling',
  ),
  DiscoverContentItem(
    id: '5',
    title: 'The Lord is my shepherd',
    reference: 'Psalm 23',
    durationMinutes: 10,
    keywordTags: {'Peace', 'Faith'},
    topicTags: {'Grief & Loss'},
    length: DiscoverLength.medium,
    highlightTag: 'Grief & Loss',
  ),
  DiscoverContentItem(
    id: '6',
    title: 'Enter his gates with thanksgiving',
    reference: 'Psalm 100:4',
    durationMinutes: 2,
    keywordTags: {'Joy', 'Mercy'},
    topicTags: {'Gratitude'},
    length: DiscoverLength.quick,
    highlightTag: 'Gratitude',
  ),
  DiscoverContentItem(
    id: '7',
    title: 'Nothing can separate us',
    reference: 'Romans 8:38–39',
    durationMinutes: 18,
    keywordTags: {'Faith', 'Love', 'Wisdom'},
    topicTags: {'Purpose & Calling'},
    length: DiscoverLength.deep,
    highlightTag: 'Faith',
  ),
  DiscoverContentItem(
    id: '8',
    title: 'Fear not, for I am with you',
    reference: 'Isaiah 41:10',
    durationMinutes: 4,
    keywordTags: {'Hope', 'Peace'},
    topicTags: {'Anxiety & Fear'},
    length: DiscoverLength.quick,
    highlightTag: 'Anxiety & Fear',
  ),
];

/// Count items whose [DiscoverContentItem.topicTags] contains [topic].
int discoverTopicCount(String topic) {
  return discoverCatalog.where((e) => e.topicTags.contains(topic)).length;
}

int discoverLengthCount(DiscoverLength len) {
  return discoverCatalog.where((e) => e.length == len).length;
}
