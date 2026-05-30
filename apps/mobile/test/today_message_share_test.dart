import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/features/home/data/today_message_api_client.dart';

TodayMessage _message({
  String? verseText,
  String verseReference = 'Psalm 46:10',
  String? shareUrl = 'https://example.com/today-message/2026-05-30',
}) {
  return TodayMessage(
    id: 'tm-1',
    contentId: null,
    publishDate: '2026-05-30',
    language: 'en',
    verseReference: verseReference,
    bibleVersion: 'KJV',
    verseText: verseText,
    imageUrl: null,
    shareImageUrl: null,
    shareImagePublicId: null,
    shareUrl: shareUrl,
    hintTitle: null,
    hintSummary: null,
    linkedContent: null,
    heartCount: 0,
    shareCount: 0,
  );
}

void main() {
  group('TodayMessage share payloads', () {
    test('shareText includes quote, reference, and url without duplication', () {
      final message = _message(
        verseText: 'Be still, and know that I am God.',
      );

      expect(
        message.shareText,
        'Be still, and know that I am God.\n\n'
        'Psalm 46:10\n\n'
        'https://example.com/today-message/2026-05-30',
      );
    });

    test('shareText omits duplicate reference when verse text is missing', () {
      final message = _message(verseText: null);

      expect(
        message.shareText,
        'Psalm 46:10\n\nhttps://example.com/today-message/2026-05-30',
      );
    });

    test('sharePreviewTitle uses quote and reference for iOS preview', () {
      final message = _message(
        verseText: 'Be still, and know that I am God.',
      );

      expect(
        message.sharePreviewTitle,
        'Be still, and know that I am God. — Psalm 46:10',
      );
    });
  });
}
