-- Pilot Message Card Library seed (~10 cards).
-- Requires: message_taxonomy_seed.sql, content_test_seed author, plan catalog migrations.

insert into contents (
  slug,
  content_type,
  language,
  title,
  subtitle,
  summary,
  body,
  author_id,
  primary_verse_reference,
  bible_version,
  verse_text,
  duration_seconds,
  external_url,
  is_published,
  is_archived,
  published_at,
  featured_rank,
  browse_visible,
  metadata,
  created_at,
  updated_at
)
select
  seed.slug,
  'message',
  'en',
  seed.title,
  seed.subtitle,
  seed.summary,
  seed.body,
  author.id,
  seed.primary_verse_reference,
  seed.bible_version,
  seed.verse_text,
  null,
  null,
  true,
  false,
  now(),
  seed.featured_rank,
  true,
  seed.metadata::jsonb,
  now(),
  now()
from (
  values
    (
      'when-tomorrow-feels-heavy',
      'When tomorrow feels heavy',
      'A gentle word for uncertain days',
      'God does not ask you to carry tomorrow before it arrives.',
      'Take the next small step with Him today.',
      'Matthew 6:34',
      'NIV',
      'Therefore do not worry about tomorrow, for tomorrow will worry about itself.',
      10,
      '{"primaryCategory":"anxiety_worry","shortReflection":"God does not ask you to carry tomorrow before it arrives. Take the next small step with Him today.","prayerText":"Lord, help me trust You with what I cannot control today. Give me peace for the next step. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","night_share"],"isTodayEligible":true,"searchAliases":["future","tomorrow","uncertain","worried"],"seed":true}'
    ),
    (
      'when-you-feel-behind',
      'When you feel behind',
      'You are not late to grace',
      'Comparison can make any season feel like failure.',
      'Your worth is not measured by someone else''s timeline.',
      'Psalm 139:14',
      'NIV',
      'I praise you because I am fearfully and wonderfully made.',
      20,
      '{"primaryCategory":"anxiety_worry","shortReflection":"Comparison can make any season feel like failure. Your worth is not measured by someone else''s timeline.","prayerText":"Father, quiet the voice that says I am behind. Help me trust Your pace for my life. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","send_encouragement"],"isTodayEligible":true,"searchAliases":["behind","comparison","late"],"seed":true}'
    ),
    (
      'before-you-fall-asleep',
      'Before you fall asleep',
      'A quiet pause for the end of the day',
      'The day can end without every question answered.',
      'You may rest in the care of God who does not sleep.',
      'Psalm 4:8',
      'NIV',
      'In peace I will lie down and sleep, for you alone, Lord, make me dwell in safety.',
      30,
      '{"primaryCategory":"peace_rest","shortReflection":"The day can end without every question answered. You may rest in the care of God who does not sleep.","prayerText":"Lord, release what I cannot fix tonight. Guard my rest. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","night_share"],"isTodayEligible":true,"searchAliases":["sleep","rest","night","bedtime"],"seed":true}'
    ),
    (
      'when-waiting-feels-long',
      'When waiting feels long',
      'Hope for a slow season',
      'Waiting is not wasted when God is with you in it.',
      'Keep your heart open to small signs of His faithfulness.',
      'Isaiah 40:31',
      'NIV',
      'Those who hope in the Lord will renew their strength.',
      40,
      '{"primaryCategory":"hope_waiting","shortReflection":"Waiting is not wasted when God is with you in it. Keep your heart open to small signs of His faithfulness.","prayerText":"God of patience, strengthen me while I wait. Help me hope again. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","send_encouragement"],"isTodayEligible":true,"searchAliases":["waiting","long","patience"],"seed":true}'
    ),
    (
      'courage-for-the-next-step',
      'Courage for the next step',
      'You do not need all the strength for the whole road',
      'Courage often looks like one honest step, not a fearless leap.',
      'Ask for strength for today, not for every tomorrow.',
      'Joshua 1:9',
      'NIV',
      'Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      50,
      '{"primaryCategory":"strength_courage","shortReflection":"Courage often looks like one honest step, not a fearless leap. Ask for strength for today, not for every tomorrow.","prayerText":"Lord, I am afraid to begin. Walk with me into the next step. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","send_encouragement"],"isTodayEligible":true,"searchAliases":["courage","start","challenge"],"seed":true}'
    ),
    (
      'when-you-need-wisdom',
      'When you need wisdom',
      'Ask before you decide',
      'You do not have to pretend you already know the answer.',
      'God invites you to ask for wisdom with an open heart.',
      'James 1:5',
      'NIV',
      'If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault.',
      60,
      '{"primaryCategory":"wisdom_guidance","shortReflection":"You do not have to pretend you already know the answer. God invites you to ask for wisdom with an open heart.","prayerText":"Lord, I need clarity I do not have. Give me wisdom for this decision. Amen.","cardTemplateKey":"classic","shareIntents":["for_self"],"isTodayEligible":true,"searchAliases":["wisdom","decision","guidance"],"seed":true}'
    ),
    (
      'for-the-moment-you-feel-alone',
      'For the moment you feel alone',
      'You are seen',
      'Loneliness can make you feel invisible, but it does not erase your worth.',
      'God draws near to the quiet and the weary.',
      'Psalm 34:18',
      'NIV',
      'The Lord is close to the brokenhearted and saves those who are crushed in spirit.',
      70,
      '{"primaryCategory":"loneliness_belonging","shortReflection":"Loneliness can make you feel invisible, but it does not erase your worth. God draws near to the quiet and the weary.","prayerText":"Lord, in my loneliness, remind me I am not forgotten. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","send_comfort"],"isTodayEligible":true,"searchAliases":["alone","lonely","comfort"],"seed":true}'
    ),
    (
      'when-you-need-to-start-again',
      'When you need to start again',
      'Mercy makes room for a new beginning',
      'Failure is not the final word on your story.',
      'Grace opens a door you thought was closed.',
      'Lamentations 3:22-23',
      'NIV',
      'Because of the Lord''s great love we are not consumed, for his compassions never fail. They are new every morning.',
      80,
      '{"primaryCategory":"forgiveness_grace","shortReflection":"Failure is not the final word on your story. Grace opens a door you thought was closed.","prayerText":"Lord, I come back to You again. Make me new where I feel broken. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","send_comfort"],"isTodayEligible":true,"searchAliases":["start again","grace","mercy"],"seed":true}'
    ),
    (
      'a-quiet-morning-gratitude',
      'A quiet morning gratitude',
      'Begin with thanks, not pressure',
      'Before the list of tasks begins, pause to notice what is already given.',
      'Gratitude can soften even a heavy morning.',
      'Psalm 118:24',
      'NIV',
      'This is the day the Lord has made; let us rejoice and be glad in it.',
      90,
      '{"primaryCategory":"gratitude_joy","shortReflection":"Before the list of tasks begins, pause to notice what is already given. Gratitude can soften even a heavy morning.","prayerText":"Thank You, Lord, for this day. Teach my heart to notice Your gifts. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","morning_share","thank_you"],"isTodayEligible":true,"searchAliases":["morning","gratitude","thanks"],"seed":true}'
    ),
    (
      'when-your-mind-feels-crowded',
      'When your mind feels crowded',
      'Room to breathe again',
      'A crowded mind does not mean a crowded soul.',
      'Stillness can begin with one slow breath and one honest prayer.',
      'Psalm 46:10',
      'NIV',
      'Be still, and know that I am God.',
      100,
      '{"primaryCategory":"peace_rest","shortReflection":"A crowded mind does not mean a crowded soul. Stillness can begin with one slow breath and one honest prayer.","prayerText":"Lord, quiet the noise inside me. Help me rest in You. Amen.","cardTemplateKey":"classic","shareIntents":["for_self","night_share"],"isTodayEligible":true,"searchAliases":["overwhelmed","busy","stillness"],"seed":true}'
    )
) as seed(
  slug,
  title,
  subtitle,
  summary,
  body,
  primary_verse_reference,
  bible_version,
  verse_text,
  featured_rank,
  metadata
)
join content_authors author on author.slug = 'hunny-team'
on conflict (slug) do update set
  content_type = excluded.content_type,
  title = excluded.title,
  subtitle = excluded.subtitle,
  summary = excluded.summary,
  body = excluded.body,
  author_id = excluded.author_id,
  primary_verse_reference = excluded.primary_verse_reference,
  bible_version = excluded.bible_version,
  verse_text = excluded.verse_text,
  is_published = true,
  is_archived = false,
  published_at = excluded.published_at,
  featured_rank = excluded.featured_rank,
  browse_visible = true,
  metadata = excluded.metadata,
  updated_at = now();

delete from content_tag_links
where content_id in (
  select id from contents where slug in (
    'when-tomorrow-feels-heavy',
    'when-you-feel-behind',
    'before-you-fall-asleep',
    'when-waiting-feels-long',
    'courage-for-the-next-step',
    'when-you-need-wisdom',
    'for-the-moment-you-feel-alone',
    'when-you-need-to-start-again',
    'a-quiet-morning-gratitude',
    'when-your-mind-feels-crowded'
  )
);

insert into content_tag_links (content_id, tag_id, created_at)
select c.id, t.id, now()
from contents c
join (
  values
    ('when-tomorrow-feels-heavy', 'category', 'anxiety_worry'),
    ('when-tomorrow-feels-heavy', 'situation', 'future_uncertainty'),
    ('when-tomorrow-feels-heavy', 'theme', 'trust'),
    ('when-tomorrow-feels-heavy', 'theme', 'peace'),
    ('when-tomorrow-feels-heavy', 'theme', 'prayer'),
    ('when-tomorrow-feels-heavy', 'tone', 'comfort'),
    ('when-tomorrow-feels-heavy', 'bible_context', 'jesus_words'),
    ('when-you-feel-behind', 'category', 'anxiety_worry'),
    ('when-you-feel-behind', 'situation', 'feeling_behind'),
    ('when-you-feel-behind', 'theme', 'identity'),
    ('when-you-feel-behind', 'theme', 'trust'),
    ('when-you-feel-behind', 'theme', 'hope'),
    ('when-you-feel-behind', 'tone', 'assurance'),
    ('before-you-fall-asleep', 'category', 'peace_rest'),
    ('before-you-fall-asleep', 'situation', 'before_sleep'),
    ('before-you-fall-asleep', 'theme', 'peace'),
    ('before-you-fall-asleep', 'theme', 'rest'),
    ('before-you-fall-asleep', 'theme', 'prayer'),
    ('before-you-fall-asleep', 'tone', 'prayerful'),
    ('before-you-fall-asleep', 'bible_context', 'psalms'),
    ('when-waiting-feels-long', 'category', 'hope_waiting'),
    ('when-waiting-feels-long', 'situation', 'waiting_season'),
    ('when-waiting-feels-long', 'theme', 'waiting'),
    ('when-waiting-feels-long', 'theme', 'hope'),
    ('when-waiting-feels-long', 'theme', 'faith'),
    ('when-waiting-feels-long', 'tone', 'encouragement'),
    ('when-waiting-feels-long', 'bible_context', 'prophets'),
    ('courage-for-the-next-step', 'category', 'strength_courage'),
    ('courage-for-the-next-step', 'situation', 'facing_challenge'),
    ('courage-for-the-next-step', 'theme', 'courage'),
    ('courage-for-the-next-step', 'theme', 'strength'),
    ('courage-for-the-next-step', 'theme', 'guidance'),
    ('courage-for-the-next-step', 'tone', 'encouragement'),
    ('when-you-need-wisdom', 'category', 'wisdom_guidance'),
    ('when-you-need-wisdom', 'situation', 'big_decision'),
    ('when-you-need-wisdom', 'theme', 'wisdom'),
    ('when-you-need-wisdom', 'theme', 'guidance'),
    ('when-you-need-wisdom', 'theme', 'prayer'),
    ('when-you-need-wisdom', 'tone', 'reflection'),
    ('for-the-moment-you-feel-alone', 'category', 'loneliness_belonging'),
    ('for-the-moment-you-feel-alone', 'situation', 'feeling_alone'),
    ('for-the-moment-you-feel-alone', 'theme', 'comfort'),
    ('for-the-moment-you-feel-alone', 'theme', 'faith'),
    ('for-the-moment-you-feel-alone', 'tone', 'comfort'),
    ('for-the-moment-you-feel-alone', 'bible_context', 'psalms'),
    ('when-you-need-to-start-again', 'category', 'forgiveness_grace'),
    ('when-you-need-to-start-again', 'situation', 'starting_over'),
    ('when-you-need-to-start-again', 'theme', 'grace'),
    ('when-you-need-to-start-again', 'theme', 'forgiveness'),
    ('when-you-need-to-start-again', 'tone', 'assurance'),
    ('a-quiet-morning-gratitude', 'category', 'gratitude_joy'),
    ('a-quiet-morning-gratitude', 'situation', 'morning_gratitude'),
    ('a-quiet-morning-gratitude', 'theme', 'gratitude'),
    ('a-quiet-morning-gratitude', 'theme', 'joy'),
    ('a-quiet-morning-gratitude', 'theme', 'praise'),
    ('a-quiet-morning-gratitude', 'tone', 'gratitude'),
    ('a-quiet-morning-gratitude', 'share_intent', 'morning_share'),
    ('when-your-mind-feels-crowded', 'category', 'peace_rest'),
    ('when-your-mind-feels-crowded', 'situation', 'overwhelmed'),
    ('when-your-mind-feels-crowded', 'theme', 'peace'),
    ('when-your-mind-feels-crowded', 'theme', 'rest'),
    ('when-your-mind-feels-crowded', 'theme', 'prayer'),
    ('when-your-mind-feels-crowded', 'tone', 'reflection'),
    ('when-your-mind-feels-crowded', 'bible_context', 'psalms')
) as map(content_slug, tag_type, tag_key) on map.content_slug = c.slug
join content_tags t on t.type = map.tag_type and t.key = map.tag_key
on conflict (content_id, tag_id) do nothing;

insert into content_plan_links (
  content_id,
  plan_template_id,
  relationship_type,
  display_order,
  cta_label,
  created_at
)
select c.id, p.id, 'related', map.display_order, 'Start plan', now()
from contents c
join (
  values
    ('when-tomorrow-feels-heavy', 'gospel_of_mark', 0),
    ('when-you-feel-behind', 'psalms_for_anxiety', 0),
    ('before-you-fall-asleep', 'psalms_for_anxiety', 0),
    ('when-waiting-feels-long', 'the_story_of_joseph', 0),
    ('courage-for-the-next-step', 'gospel_of_mark', 0),
    ('when-you-need-wisdom', 'life_of_david', 0),
    ('for-the-moment-you-feel-alone', 'psalms_for_anxiety', 0),
    ('when-you-need-to-start-again', 'jonah', 0),
    ('a-quiet-morning-gratitude', 'bible_in_a_year', 0),
    ('when-your-mind-feels-crowded', 'psalms_for_anxiety', 0)
) as map(content_slug, template_key, display_order) on map.content_slug = c.slug
join plan_templates p on p.template_key = map.template_key
on conflict (content_id, plan_template_id, relationship_type) do update set
  display_order = excluded.display_order,
  cta_label = excluded.cta_label;
