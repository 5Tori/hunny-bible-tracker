import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/api/hunny_api_client.dart';
import '../../core/theme/app_theme.dart';
import 'data/today_message_api_client.dart';
import '../read/data/read_repository.dart';
import '../read/domain/read_models.dart';
import '../read/widgets/current_plan_progress_panel.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    required this.readRepository,
    required this.onReadTap,
    TodayMessageApiClient? todayMessageApiClient,
  }) : todayMessageApiClient = todayMessageApiClient ?? TodayMessageApiClient();

  final ReadRepository readRepository;
  final VoidCallback onReadTap;
  final TodayMessageApiClient todayMessageApiClient;

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
      _todayMessageHearted = todayMessageHearted;
      _todayMessageSaved = todayMessageSaved;
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
      _todayMessageHearted = todayMessageHearted;
      _todayMessageSaved = todayMessageSaved;
      _todayMessageLoading = false;
    });
  }

  Future<TodayMessage?> _fetchTodayMessage({
    required String date,
    required String language,
  }) async {
    try {
      return await widget.todayMessageApiClient.fetchTodayMessage(
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

    try {
      final engagement =
          await widget.todayMessageApiClient.heartTodayMessage(message.id);
      await widget.readRepository.setAppSetting(
        _heartedSettingKey(message.id),
        '1',
      );
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
      setState(() {
        _todayMessageHearted = false;
        _todayMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save this heart.')),
      );
    } finally {
      if (mounted) setState(() => _todayMessageActionPending = false);
    }
  }

  Future<void> _toggleSaveTodayMessage() async {
    final message = _todayMessage;
    if (message == null) return;

    final nextValue = !_todayMessageSaved;
    setState(() => _todayMessageSaved = nextValue);
    await widget.readRepository.setAppSetting(
      _savedSettingKey(message.id),
      nextValue ? '1' : '0',
    );
  }

  Future<void> _shareTodayMessage() async {
    final message = _todayMessage;
    if (message == null || _todayMessageActionPending) return;

    setState(() => _todayMessageActionPending = true);
    try {
      final sharedImage = await _createTodayMessageShareImage(message);
      final files = sharedImage == null ? null : [sharedImage.file];
      final result = await SharePlus.instance.share(
        ShareParams(
          title: message.shareTitle,
          subject: message.shareTitle,
          text: message.shareText,
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
          await widget.todayMessageApiClient.shareTodayMessage(message.id);
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
      message:
          'You are offline. Your reading progress is still available, and Hunny will refresh today\'s message when you are back online.',
      imageUrl: 'asset://assets/image/honeycomb.jpg',
      shareImageUrl: null,
      shareImagePublicId: null,
      shareUrl: null,
      hintTitle: 'Offline reading is ready',
      hintSummary:
          'Keep reading where you left off. Today\'s message will refresh when the connection returns.',
      articleTitle: 'Offline reading is ready',
      articleBody:
          'Your reading plan and progress are stored on this device. You can continue reading and marking chapters offline.',
      relatedPlanTemplateKey: null,
      primaryRelatedPlanTemplateId: null,
      relatedPlanTitle: null,
      relatedPlanChapters: null,
      relatedPlanMinutes: null,
      heartCount: 0,
      shareCount: 0,
    );
  }

  Future<void> _openTodayMessageArticle() async {
    final message = _todayMessage;
    if (message == null) return;
    final relatedPlan = message.planTemplateIdentifier == null
        ? null
        : await widget.readRepository.getPlanTemplateByIdentifier(
            message.planTemplateIdentifier!,
          );
    if (!mounted) return;

    final started = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _TodayMessageArticleSheet(
          message: message,
          relatedPlan: relatedPlan,
          onStartPlan: widget.readRepository.addPlanFromTemplate,
        );
      },
    );

    if (!mounted || started != true) return;
    await _load();
    widget.onReadTap();
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
              onHeart: _heartTodayMessage,
              onSave: _toggleSaveTodayMessage,
              onShare: _shareTodayMessage,
              onReadMore: _openTodayMessageArticle,
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
                  onTap: onSave,
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
                  child: const Text('Read more'),
                ),
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

class _TodayMessageArticleSheet extends StatefulWidget {
  const _TodayMessageArticleSheet({
    required this.message,
    required this.relatedPlan,
    required this.onStartPlan,
  });

  final TodayMessage message;
  final ReadingPlanTemplateView? relatedPlan;
  final Future<String> Function(String templateKey) onStartPlan;

  @override
  State<_TodayMessageArticleSheet> createState() =>
      _TodayMessageArticleSheetState();
}

class _TodayMessageArticleSheetState extends State<_TodayMessageArticleSheet> {
  var _startingPlan = false;

  Future<void> _startPlan() async {
    final identifier = widget.message.planTemplateIdentifier ??
        widget.relatedPlan?.templateKey;
    if (identifier == null || _startingPlan) return;
    setState(() => _startingPlan = true);
    try {
      await widget.onStartPlan(identifier);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _startingPlan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start this plan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final relatedPlan = widget.relatedPlan;
    final showRelatedPlan = message.hasRelatedPlan || relatedPlan != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.45,
      maxChildSize: 0.94,
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
                      message.articleHeading,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.ink,
                                fontSize: 29,
                                fontWeight: FontWeight.w900,
                                height: 1.16,
                              ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      message.articleText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.ink,
                            fontSize: 20,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (showRelatedPlan) ...[
                      const SizedBox(height: 28),
                      _RelatedPlanCard(
                        title: relatedPlan?.title ?? message.planTitle,
                        chapters:
                            relatedPlan?.totalChapters ?? message.planChapters,
                        minutes: relatedPlan?.estimatedMinutes ??
                            message.planMinutes,
                        starting: _startingPlan,
                        onStartPlan: _startPlan,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: _startingPlan
                      ? null
                      : () => Navigator.of(context).pop(false),
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

class _RelatedPlanCard extends StatelessWidget {
  const _RelatedPlanCard({
    required this.title,
    required this.chapters,
    required this.minutes,
    required this.starting,
    required this.onStartPlan,
  });

  final String title;
  final int chapters;
  final int minutes;
  final bool starting;
  final VoidCallback onStartPlan;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (chapters > 0) '$chapters chapters',
      if (minutes > 0) '~$minutes min',
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'READ IN CONTEXT',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedInk,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (details.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        details,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mutedInk,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: starting ? null : onStartPlan,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.mutedInk,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                child: Text(starting ? 'Starting...' : 'Start plan'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
