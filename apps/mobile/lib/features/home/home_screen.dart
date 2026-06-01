import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/hunny_api_client.dart';
import '../../core/api/hunny_api_config.dart';
import '../../core/theme/app_theme.dart';
import '../content/data/content_api_client.dart';
import '../content/data/content_read_client.dart';
import '../find/discover_screen.dart';
import 'data/today_message_api_client.dart';
import 'data/today_message_read_client.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';
import '../read/widgets/current_plan_progress_panel.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    required this.readRepository,
    required this.onReadTap,
    TodayMessageReadClient? todayMessageReadClient,
    ContentReadClient? contentReadClient,
  })  : todayMessageReadClient =
            todayMessageReadClient ?? TodayMessageReadClient(),
        contentReadClient = contentReadClient ?? ContentReadClient();

  final ReadRepository readRepository;
  final VoidCallback onReadTap;
  final TodayMessageReadClient todayMessageReadClient;
  final ContentReadClient contentReadClient;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  ReadingOverview? _readingOverview;
  ReadingPlanView? _plan;
  TodayMessage? _todayMessage;
  var _todayMessageLoading = false;
  var _todayMessageHearted = false;
  var _todayMessageSaved = false;
  var _todayMessageActionPending = false;
  var _todayMessageSavePending = false;
  var _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    if (mounted) setState(() => _todayMessageLoading = true);
    const language = 'en';
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cachedTodayMessage =
        await _getCachedTodayMessage(date: today, language: language) ??
            await _getLastCachedTodayMessage(language: language);
    final displayMessage =
        cachedTodayMessage ?? _offlineFallbackTodayMessage(today, language);

    final plan = await widget.readRepository.getCurrentPlan();
    final overview = plan == null
        ? null
        : await widget.readRepository.getReadingOverview(plan.id);
    final todayMessageHearted = await _isTodayMessageHearted(displayMessage.id);
    final todayMessageSaved = await _isTodayMessageSaved(displayMessage.id);
    if (!mounted || generation != _loadGeneration) return;
    setState(() {
      _plan = plan;
      _readingOverview = overview;
      _todayMessage = displayMessage;
      if (!_todayMessageSavePending) {
        _todayMessageSaved = todayMessageSaved;
      }
      _todayMessageHearted = todayMessageHearted;
      _todayMessageLoading = false;
    });

    unawaited(_refreshTodayMessage(
      date: today,
      language: language,
      generation: generation,
    ));
  }

  Future<void> _refreshTodayMessage({
    required String date,
    required String language,
    required int generation,
  }) async {
    final todayMessage = await _fetchTodayMessage(
      date: date,
      language: language,
    );
    if (todayMessage == null) return;
    await _cacheTodayMessage(
      todayMessage,
      cacheDate: date,
      language: language,
    );
    final todayMessageHearted = await _isTodayMessageHearted(todayMessage.id);
    final todayMessageSaved = await _isTodayMessageSaved(todayMessage.id);
    if (!mounted || generation != _loadGeneration) return;
    setState(() {
      _todayMessage = todayMessage;
      if (!_todayMessageSavePending) {
        _todayMessageSaved = todayMessageSaved;
      }
      _todayMessageHearted = todayMessageHearted;
      _todayMessageLoading = false;
    });
  }

  Future<TodayMessage?> _fetchTodayMessage({
    required String date,
    required String language,
  }) async {
    try {
      return await widget.todayMessageReadClient.fetchTodayMessage(
        date: date,
        language: language,
      );
    } catch (_) {
      return null;
    }
  }

  Future<TodayMessage?> _getCachedTodayMessage({
    required String date,
    required String language,
  }) async {
    final value = await widget.readRepository.getAppSetting(
      _cachedTodayMessageKey(date: date, language: language),
    );
    if (value == null) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) return null;
      return TodayMessage.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<TodayMessage?> _getLastCachedTodayMessage({
    required String language,
  }) async {
    final value = await widget.readRepository.getAppSetting(
      _lastCachedTodayMessageKey(language: language),
    );
    if (value == null) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, dynamic>) return null;
      return TodayMessage.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheTodayMessage(
    TodayMessage message, {
    String? cacheDate,
    String? language,
  }) async {
    final encoded = jsonEncode(message.toJson());
    final cacheLanguage = language ?? message.language;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cacheDates = {
      message.publishDate,
      today,
      if (cacheDate != null) cacheDate,
    };
    for (final date in cacheDates) {
      await widget.readRepository.setAppSetting(
        _cachedTodayMessageKey(date: date, language: cacheLanguage),
        encoded,
      );
    }
    await widget.readRepository.setAppSetting(
      _lastCachedTodayMessageKey(language: cacheLanguage),
      encoded,
    );
  }

  Future<bool> _isTodayMessageHearted(String id) async {
    final value =
        await widget.readRepository.getAppSetting(_heartedSettingKey(id));
    return value == '1';
  }

  Future<bool> _isTodayMessageSaved(String id) async {
    final value =
        await widget.readRepository.getAppSetting(_savedSettingKey(id));
    return value == '1';
  }

  Future<void> _heartTodayMessage() async {
    final message = _todayMessage;
    if (message == null || _todayMessageHearted || _todayMessageActionPending) {
      return;
    }

    setState(() {
      _todayMessageHearted = true;
      _todayMessageActionPending = true;
      _todayMessage = message.copyWith(heartCount: message.heartCount + 1);
    });
    await widget.readRepository.setAppSetting(
      _heartedSettingKey(message.id),
      '1',
    );

    try {
      final engagement =
          await widget.todayMessageReadClient.heartTodayMessage(message.id);
      if (!mounted || !_todayMessageHearted) return;
      final updatedMessage = _todayMessage?.copyWith(
        heartCount: engagement.heartCount,
        shareCount: engagement.shareCount,
      );
      if (updatedMessage != null) {
        await _cacheTodayMessage(updatedMessage);
      }
      if (!mounted) return;
      setState(() {
        _todayMessage = updatedMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _todayMessageHearted = false;
        _todayMessage = message;
      });
      await widget.readRepository.setAppSetting(
        _heartedSettingKey(message.id),
        '0',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this heart.')),
      );
    } finally {
      if (mounted) setState(() => _todayMessageActionPending = false);
    }
  }

  Future<void> _toggleSaveTodayMessage() async {
    final message = _todayMessage;
    if (message == null || _todayMessageSavePending) return;

    final messageId = message.id;
    final previousSaved = _todayMessageSaved;
    final nextSaved = !previousSaved;

    setState(() {
      _todayMessageSaved = nextSaved;
      _todayMessageSavePending = true;
    });

    try {
      await widget.readRepository.setAppSetting(
        _savedSettingKey(messageId),
        nextSaved ? '1' : '0',
      );
    } catch (_) {
      if (!mounted || _todayMessage?.id != messageId) return;
      setState(() => _todayMessageSaved = previousSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update save.')),
      );
    } finally {
      if (mounted && _todayMessage?.id == messageId) {
        setState(() => _todayMessageSavePending = false);
      }
    }
  }

  Future<void> _shareTodayMessage() async {
    final message = _todayMessage;
    if (message == null || _todayMessageActionPending) return;

    setState(() => _todayMessageActionPending = true);
    try {
      final sharedImage = await _createTodayMessageShareImage(message);
      final files = sharedImage == null ? null : [sharedImage.file];
      // iOS treats image + text as two separate share items ("Plain Text and 1
      // Document"). Share the image only; verse copy is baked into the PNG and
      // title drives the sheet preview. Android keeps image + caption + link.
      final shareTextOnPlatform = _shouldShareTodayMessageTextWithImage(files)
          ? message.shareText
          : null;
      final result = await SharePlus.instance.share(
        ShareParams(
          title: message.sharePreviewTitle,
          subject: message.shareTitle,
          text: shareTextOnPlatform,
          files: files,
          fileNameOverrides:
              sharedImage == null ? null : [sharedImage.fileName],
        ),
      );
      if (result.status == ShareResultStatus.dismissed) return;

      final optimisticallySharedMessage =
          message.copyWith(shareCount: message.shareCount + 1);
      await _cacheTodayMessage(optimisticallySharedMessage);
      if (!mounted) return;
      setState(() => _todayMessage = optimisticallySharedMessage);
      final engagement =
          await widget.todayMessageReadClient.shareTodayMessage(message.id);
      if (!mounted) return;
      final updatedMessage = _todayMessage?.copyWith(
        heartCount: engagement.heartCount,
        shareCount: engagement.shareCount,
      );
      if (updatedMessage != null) {
        await _cacheTodayMessage(updatedMessage);
      }
      if (!mounted) return;
      setState(() {
        _todayMessage = updatedMessage;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share this message.')),
      );
    } finally {
      if (mounted) setState(() => _todayMessageActionPending = false);
    }
  }

  bool _shouldShareTodayMessageTextWithImage(List<XFile>? files) {
    if (files == null || files.isEmpty) return true;
    if (kIsWeb) return true;
    return defaultTargetPlatform != TargetPlatform.iOS;
  }

  Future<_SharedTodayMessageImage?> _createTodayMessageShareImage(
    TodayMessage message,
  ) async {
    try {
      final sharedImageFromServer =
          await _downloadServerTodayMessageShareImage(message);
      if (sharedImageFromServer != null) return sharedImageFromServer;

      final bytes = await _drawTodayMessageShareImage(message);
      final fileName = 'today-message-${_safeFileNamePart(message.id)}.png';
      return _SharedTodayMessageImage(
        file: XFile.fromData(
          bytes,
          mimeType: 'image/png',
          name: fileName,
        ),
        fileName: fileName,
      );
    } catch (_) {
      return null;
    }
  }

  Future<_SharedTodayMessageImage?> _downloadServerTodayMessageShareImage(
    TodayMessage message,
  ) async {
    final shareImageUrl = message.shareImageUrl;
    if (shareImageUrl == null) return null;

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: HunnyApiClient.requestConnectTimeout,
          receiveTimeout: HunnyApiClient.requestReceiveTimeout,
        ),
      );
      final response = await dio.get<List<int>>(
        shareImageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      final fileName = 'today-message-${_safeFileNamePart(message.id)}.png';
      return _SharedTodayMessageImage(
        file: XFile.fromData(
          Uint8List.fromList(data),
          mimeType: 'image/png',
          name: fileName,
        ),
        fileName: fileName,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _drawTodayMessageShareImage(TodayMessage message) async {
    const width = 1080.0;
    const height = 1350.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(width, height);

    final background = await _loadShareBackgroundImage(message.imageUrl);
    if (background == null) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = AppTheme.ink,
      );
    } else {
      _drawCoverImage(canvas, background, size);
    }

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x22000000),
            Color(0x33000000),
            Color(0xDD000000),
          ],
          stops: [0, 0.45, 1],
        ).createShader(Offset.zero & size),
    );

    const horizontalPadding = 84.0;
    final textWidth = width - horizontalPadding * 2;
    final referenceLabel = message.bibleVersion == null
        ? message.verseReference
        : '${message.verseReference} · ${message.bibleVersion}';

    final versePainter = TextPainter(
      text: TextSpan(
        text: '"${message.primaryText}"',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 66,
          fontWeight: FontWeight.w800,
          height: 1.18,
        ),
      ),
      maxLines: 8,
      ellipsis: '…',
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: textWidth);

    final referencePainter = TextPainter(
      text: TextSpan(
        text: referenceLabel.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.78),
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: 3.2,
          height: 1.3,
        ),
      ),
      maxLines: 2,
      ellipsis: '…',
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: textWidth);

    const bottomPadding = 112.0;
    final referenceTop = height - bottomPadding - referencePainter.height;
    final verseTop = referenceTop - 38 - versePainter.height;
    versePainter.paint(canvas, Offset(horizontalPadding, verseTop));
    referencePainter.paint(canvas, Offset(horizontalPadding, referenceTop));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    picture.dispose();
    image.dispose();
    background?.dispose();
    if (byteData == null) {
      throw StateError('Could not encode today message share image.');
    }
    return byteData.buffer.asUint8List();
  }

  Future<ui.Image?> _loadShareBackgroundImage(String? imageUrl) async {
    if (imageUrl == null) return null;
    try {
      if (_isAssetImageUrl(imageUrl)) {
        final data = await rootBundle.load(_assetPathFromImageUrl(imageUrl));
        final bytes = data.buffer.asUint8List();
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        return frame.image;
      }

      final dio = Dio(
        BaseOptions(
          connectTimeout: HunnyApiClient.requestConnectTimeout,
          receiveTimeout: HunnyApiClient.requestReceiveTimeout,
        ),
      );
      final response = await dio.get<List<int>>(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      final bytes = Uint8List.fromList(data);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void _drawCoverImage(Canvas canvas, ui.Image image, Size outputSize) {
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final scale = math.max(
      outputSize.width / imageSize.width,
      outputSize.height / imageSize.height,
    );
    final sourceSize = Size(
      outputSize.width / scale,
      outputSize.height / scale,
    );
    final sourceRect = Rect.fromCenter(
      center: Offset(imageSize.width / 2, imageSize.height / 2),
      width: sourceSize.width,
      height: sourceSize.height,
    );
    canvas.drawImageRect(
      image,
      sourceRect,
      Offset.zero & outputSize,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  String _safeFileNamePart(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '-');
  }

  String _heartedSettingKey(String id) => 'today_message_hearted_$id';
  String _savedSettingKey(String id) => 'today_message_saved_$id';
  String _cachedTodayMessageKey({
    required String date,
    required String language,
  }) =>
      'today_message_cache_${language}_$date';

  String _lastCachedTodayMessageKey({required String language}) =>
      'today_message_cache_${language}_last';

  TodayMessage _offlineFallbackTodayMessage(String date, String language) {
    return TodayMessage(
      id: 'offline-fallback-$language-$date',
      contentId: null,
      publishDate: date,
      language: language,
      verseReference: 'Proverbs 16:24',
      bibleVersion: null,
      verseText:
          'Gracious words are a honeycomb, sweet to the soul and healing to the bones.',
      imageUrl: 'asset://assets/image/honeycomb.jpg',
      shareImageUrl: null,
      shareImagePublicId: null,
      shareUrl: null,
      hintTitle: 'Offline reading is ready',
      hintSummary:
          'Keep reading where you left off. Today\'s message will refresh when the connection returns.',
      context: null,
      linkedContent: null,
      heartCount: 0,
      shareCount: 0,
    );
  }

  Future<void> _openMessageCardLink(
    TodayMessageLinkedContentSummary linked,
  ) async {
    final raw = linked.messagesUrl?.trim();
    if (raw == null || raw.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message card link is unavailable right now.'),
        ),
      );
      return;
    }

    final uri = raw.startsWith('http')
        ? Uri.parse(raw)
        : Uri.parse('${HunnyApiConfig.fromEnvironment().baseUrl}$raw');
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the message card.')),
      );
    }
  }

  Future<void> _openTodayMessageMore() async {
    final message = _todayMessage;
    if (message == null || !message.hasMoreDetails) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _TodayMessageMoreSheet(
          message: message,
          contentReadClient: widget.contentReadClient,
          onOpenLinkedContent: (linked) async {
            Navigator.of(sheetContext).pop();
            if (!mounted) return;

            if (linked.isMessageCard) {
              await _openMessageCardLink(linked);
              return;
            }

            RemoteContent? content;
            try {
              content = await widget.contentReadClient.fetchContentByIdentifier(
                linked.slug,
                language: message.language,
              );
            } catch (_) {
              content = null;
            }

            if (!mounted) return;
            if (content == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not load this story. Try again online.'),
                ),
              );
              return;
            }

            await showContentDetailSheet(
              context,
              content: content,
              readRepository: widget.readRepository,
              onOpenPlan: (_) => widget.onReadTap(),
            );
            if (!mounted) return;
            await _load();
          },
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final overview = _readingOverview;
    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE · MMM d').format(now).toUpperCase();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              letterSpacing: 0.5,
                              color: AppTheme.mutedInk,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _greeting(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.ink,
                  child: Text(
                    'B',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            _SectionLabel(title: "TODAY'S MESSAGE"),
            const SizedBox(height: 12),
            TodayMessageCard(
              message: _todayMessage,
              loading: _todayMessageLoading,
              hearted: _todayMessageHearted,
              saved: _todayMessageSaved,
              actionPending: _todayMessageActionPending,
              savePending: _todayMessageSavePending,
              onHeart: _heartTodayMessage,
              onSave: _toggleSaveTodayMessage,
              onShare: _shareTodayMessage,
              onReadMore: _openTodayMessageMore,
            ),
            const SizedBox(height: 32),

            // Progress
            Row(
              children: [
                _SectionLabel(title: 'PROGRESS'),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onReadTap,
                  child: Text(
                    'Read ›',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ink,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CurrentPlanProgressPanel(
              overview: overview,
              planTitle: _plan?.title ?? 'No current plan',
              showContinueReading: true,
              onContinueReading: widget.onReadTap,
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

class _SharedTodayMessageImage {
  const _SharedTodayMessageImage({
    required this.file,
    required this.fileName,
  });

  final XFile file;
  final String fileName;
}

ImageProvider<Object>? _imageProviderForTodayMessage(String? imageUrl) {
  if (imageUrl == null) return null;
  if (_isAssetImageUrl(imageUrl)) {
    return AssetImage(_assetPathFromImageUrl(imageUrl));
  }
  return NetworkImage(imageUrl);
}

bool _isAssetImageUrl(String imageUrl) => imageUrl.startsWith('asset://');

String _assetPathFromImageUrl(String imageUrl) =>
    imageUrl.replaceFirst('asset://', '');

class TodayMessageCard extends StatelessWidget {
  const TodayMessageCard({
    super.key,
    required this.message,
    required this.loading,
    required this.hearted,
    required this.saved,
    required this.actionPending,
    required this.savePending,
    required this.onHeart,
    required this.onSave,
    required this.onShare,
    required this.onReadMore,
  });

  final TodayMessage? message;
  final bool loading;
  final bool hearted;
  final bool saved;
  final bool actionPending;
  final bool savePending;
  final VoidCallback onHeart;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onReadMore;

  @override
  Widget build(BuildContext context) {
    final current = message;
    if (loading && current == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (current == null) {
      return Container(
        height: 140,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.softSurface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.border),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          'No message published yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedInk,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    final imageUrl = current.imageUrl;
    final imageProvider = _imageProviderForTodayMessage(imageUrl);
    final hasImage = imageProvider != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.86,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.ink,
                image: hasImage
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: hasImage
                        ? [
                            Colors.black.withValues(alpha: 0.02),
                            Colors.black.withValues(alpha: 0.82),
                          ]
                        : const [
                            AppTheme.ink,
                            Color(0xFF30302A),
                          ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${current.primaryText}"',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      current.referenceLabel.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Row(
              children: [
                _MessageActionButton(
                  icon: hearted ? Icons.favorite : Icons.favorite_border,
                  label: _compactCount(current.heartCount),
                  selected: hearted,
                  onTap: actionPending || hearted ? null : onHeart,
                ),
                const SizedBox(width: 18),
                _MessageActionButton(
                  icon: saved ? Icons.bookmark : Icons.bookmark_border,
                  label: 'Save',
                  selected: saved,
                  onTap: savePending ? null : onSave,
                ),
                const Spacer(),
                _MessageActionButton(
                  icon: Icons.ios_share,
                  label: current.shareCount > 0
                      ? _compactCount(current.shareCount)
                      : '',
                  selected: false,
                  onTap: actionPending ? null : onShare,
                  compact: true,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.reflectionTitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedInk,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 7),
                Text(
                  current.reflectionSummary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.ink,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (current.hasMoreDetails) ...[
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: onReadMore,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.ink,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    child: const Text('More'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _compactCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _MessageActionButton extends StatelessWidget {
  const _MessageActionButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 4 : 2,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppTheme.ink : AppTheme.mutedInk,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 5),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mutedInk,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayMessageMoreSheet extends StatelessWidget {
  const _TodayMessageMoreSheet({
    required this.message,
    required this.contentReadClient,
    required this.onOpenLinkedContent,
  });

  final TodayMessage message;
  final ContentReadClient contentReadClient;
  final Future<void> Function(TodayMessageLinkedContentSummary linked)
      onOpenLinkedContent;

  @override
  Widget build(BuildContext context) {
    final linkedContent = message.linkedContent;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.82,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 44, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.softSurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(
                      message.referenceLabel.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.mutedInk,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.4,
                          ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      message.reflectionTitle,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.ink,
                                fontSize: 29,
                                fontWeight: FontWeight.w900,
                                height: 1.16,
                              ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      message.reflectionSummary,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.ink,
                            fontSize: 18,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (linkedContent != null) ...[
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.softSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              linkedContent.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (linkedContent.linkedPreviewText != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                linkedContent.linkedPreviewText!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.mutedInk,
                                      height: 1.45,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: linkedContent.isMessageCard
                                    ? (linkedContent.messagesUrl != null
                                        ? () =>
                                            onOpenLinkedContent(linkedContent)
                                        : null)
                                    : (contentReadClient.isConfigured
                                        ? () =>
                                            onOpenLinkedContent(linkedContent)
                                        : null),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.ink,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  linkedContent.isMessageCard
                                      ? 'Open message card'
                                      : 'Read full story',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppTheme.ink,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
