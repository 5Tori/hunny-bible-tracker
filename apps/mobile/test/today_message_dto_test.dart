import 'package:flutter_test/flutter_test.dart';
import 'package:hunny_bible_tracker/features/home/data/today_message_api_client.dart';

void main() {
  group('TodayMessage DTO', () {
    test('parses top-level context and linked_content messages_url', () {
      final message = TodayMessage.fromJson({
        'id': 'tm-1',
        'content_id': 'card-1',
        'publish_date': '2026-06-01',
        'language': 'en',
        'verse_reference': 'Matthew 6:34',
        'bible_version': 'NIV',
        'verse_text': 'Therefore do not worry about tomorrow.',
        'image_url': null,
        'share_image_url': null,
        'share_image_public_id': null,
        'share_url': null,
        'hint_title': null,
        'hint_summary': 'Legacy hint',
        'context': 'Take the next small step with Him today.',
        'heart_count': 0,
        'share_count': 0,
        'linked_content': {
          'id': 'card-1',
          'slug': 'when-your-mind-feels-crowded',
          'content_type': 'message',
          'title': 'When your mind feels crowded',
          'summary': null,
          'context': 'God does not ask you to carry tomorrow before it arrives.',
          'cover_image_url': null,
          'messages_url': '/messages/when-your-mind-feels-crowded',
          'related_plans': [],
        },
      });

      expect(message.context, 'Take the next small step with Him today.');
      expect(
        message.reflectionSummary,
        'Take the next small step with Him today.',
      );
      expect(message.hasMoreDetails, isTrue);
      expect(message.linkedContent?.isMessageCard, isTrue);
      expect(
        message.linkedContent?.messagesUrl,
        '/messages/when-your-mind-feels-crowded',
      );
      expect(
        message.linkedContent?.linkedPreviewText,
        'God does not ask you to carry tomorrow before it arrives.',
      );
    });
  });
}
