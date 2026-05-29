// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BibleBooksTable extends BibleBooks
    with TableInfo<$BibleBooksTable, BibleBook> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleBooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _bookKeyMeta =
      const VerificationMeta('bookKey');
  @override
  late final GeneratedColumn<String> bookKey = GeneratedColumn<String>(
      'book_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _testamentMeta =
      const VerificationMeta('testament');
  @override
  late final GeneratedColumn<String> testament = GeneratedColumn<String>(
      'testament', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookOrderMeta =
      const VerificationMeta('bookOrder');
  @override
  late final GeneratedColumn<int> bookOrder = GeneratedColumn<int>(
      'book_order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameEnMeta =
      const VerificationMeta('displayNameEn');
  @override
  late final GeneratedColumn<String> displayNameEn = GeneratedColumn<String>(
      'display_name_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameKoMeta =
      const VerificationMeta('displayNameKo');
  @override
  late final GeneratedColumn<String> displayNameKo = GeneratedColumn<String>(
      'display_name_ko', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterCountMeta =
      const VerificationMeta('chapterCount');
  @override
  late final GeneratedColumn<int> chapterCount = GeneratedColumn<int>(
      'chapter_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookKey,
        testament,
        bookOrder,
        shortName,
        displayNameEn,
        displayNameKo,
        chapterCount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_books';
  @override
  VerificationContext validateIntegrity(Insertable<BibleBook> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_key')) {
      context.handle(_bookKeyMeta,
          bookKey.isAcceptableOrUnknown(data['book_key']!, _bookKeyMeta));
    } else if (isInserting) {
      context.missing(_bookKeyMeta);
    }
    if (data.containsKey('testament')) {
      context.handle(_testamentMeta,
          testament.isAcceptableOrUnknown(data['testament']!, _testamentMeta));
    } else if (isInserting) {
      context.missing(_testamentMeta);
    }
    if (data.containsKey('book_order')) {
      context.handle(_bookOrderMeta,
          bookOrder.isAcceptableOrUnknown(data['book_order']!, _bookOrderMeta));
    } else if (isInserting) {
      context.missing(_bookOrderMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    if (data.containsKey('display_name_en')) {
      context.handle(
          _displayNameEnMeta,
          displayNameEn.isAcceptableOrUnknown(
              data['display_name_en']!, _displayNameEnMeta));
    } else if (isInserting) {
      context.missing(_displayNameEnMeta);
    }
    if (data.containsKey('display_name_ko')) {
      context.handle(
          _displayNameKoMeta,
          displayNameKo.isAcceptableOrUnknown(
              data['display_name_ko']!, _displayNameKoMeta));
    }
    if (data.containsKey('chapter_count')) {
      context.handle(
          _chapterCountMeta,
          chapterCount.isAcceptableOrUnknown(
              data['chapter_count']!, _chapterCountMeta));
    } else if (isInserting) {
      context.missing(_chapterCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BibleBook map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleBook(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bookKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_key'])!,
      testament: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}testament'])!,
      bookOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}book_order'])!,
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name'])!,
      displayNameEn: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}display_name_en'])!,
      displayNameKo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name_ko']),
      chapterCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_count'])!,
    );
  }

  @override
  $BibleBooksTable createAlias(String alias) {
    return $BibleBooksTable(attachedDatabase, alias);
  }
}

class BibleBook extends DataClass implements Insertable<BibleBook> {
  final int id;
  final String bookKey;
  final String testament;
  final int bookOrder;
  final String shortName;
  final String displayNameEn;
  final String? displayNameKo;
  final int chapterCount;
  const BibleBook(
      {required this.id,
      required this.bookKey,
      required this.testament,
      required this.bookOrder,
      required this.shortName,
      required this.displayNameEn,
      this.displayNameKo,
      required this.chapterCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_key'] = Variable<String>(bookKey);
    map['testament'] = Variable<String>(testament);
    map['book_order'] = Variable<int>(bookOrder);
    map['short_name'] = Variable<String>(shortName);
    map['display_name_en'] = Variable<String>(displayNameEn);
    if (!nullToAbsent || displayNameKo != null) {
      map['display_name_ko'] = Variable<String>(displayNameKo);
    }
    map['chapter_count'] = Variable<int>(chapterCount);
    return map;
  }

  BibleBooksCompanion toCompanion(bool nullToAbsent) {
    return BibleBooksCompanion(
      id: Value(id),
      bookKey: Value(bookKey),
      testament: Value(testament),
      bookOrder: Value(bookOrder),
      shortName: Value(shortName),
      displayNameEn: Value(displayNameEn),
      displayNameKo: displayNameKo == null && nullToAbsent
          ? const Value.absent()
          : Value(displayNameKo),
      chapterCount: Value(chapterCount),
    );
  }

  factory BibleBook.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleBook(
      id: serializer.fromJson<int>(json['id']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      testament: serializer.fromJson<String>(json['testament']),
      bookOrder: serializer.fromJson<int>(json['bookOrder']),
      shortName: serializer.fromJson<String>(json['shortName']),
      displayNameEn: serializer.fromJson<String>(json['displayNameEn']),
      displayNameKo: serializer.fromJson<String?>(json['displayNameKo']),
      chapterCount: serializer.fromJson<int>(json['chapterCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookKey': serializer.toJson<String>(bookKey),
      'testament': serializer.toJson<String>(testament),
      'bookOrder': serializer.toJson<int>(bookOrder),
      'shortName': serializer.toJson<String>(shortName),
      'displayNameEn': serializer.toJson<String>(displayNameEn),
      'displayNameKo': serializer.toJson<String?>(displayNameKo),
      'chapterCount': serializer.toJson<int>(chapterCount),
    };
  }

  BibleBook copyWith(
          {int? id,
          String? bookKey,
          String? testament,
          int? bookOrder,
          String? shortName,
          String? displayNameEn,
          Value<String?> displayNameKo = const Value.absent(),
          int? chapterCount}) =>
      BibleBook(
        id: id ?? this.id,
        bookKey: bookKey ?? this.bookKey,
        testament: testament ?? this.testament,
        bookOrder: bookOrder ?? this.bookOrder,
        shortName: shortName ?? this.shortName,
        displayNameEn: displayNameEn ?? this.displayNameEn,
        displayNameKo:
            displayNameKo.present ? displayNameKo.value : this.displayNameKo,
        chapterCount: chapterCount ?? this.chapterCount,
      );
  BibleBook copyWithCompanion(BibleBooksCompanion data) {
    return BibleBook(
      id: data.id.present ? data.id.value : this.id,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      testament: data.testament.present ? data.testament.value : this.testament,
      bookOrder: data.bookOrder.present ? data.bookOrder.value : this.bookOrder,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      displayNameEn: data.displayNameEn.present
          ? data.displayNameEn.value
          : this.displayNameEn,
      displayNameKo: data.displayNameKo.present
          ? data.displayNameKo.value
          : this.displayNameKo,
      chapterCount: data.chapterCount.present
          ? data.chapterCount.value
          : this.chapterCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BibleBook(')
          ..write('id: $id, ')
          ..write('bookKey: $bookKey, ')
          ..write('testament: $testament, ')
          ..write('bookOrder: $bookOrder, ')
          ..write('shortName: $shortName, ')
          ..write('displayNameEn: $displayNameEn, ')
          ..write('displayNameKo: $displayNameKo, ')
          ..write('chapterCount: $chapterCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookKey, testament, bookOrder, shortName,
      displayNameEn, displayNameKo, chapterCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleBook &&
          other.id == this.id &&
          other.bookKey == this.bookKey &&
          other.testament == this.testament &&
          other.bookOrder == this.bookOrder &&
          other.shortName == this.shortName &&
          other.displayNameEn == this.displayNameEn &&
          other.displayNameKo == this.displayNameKo &&
          other.chapterCount == this.chapterCount);
}

class BibleBooksCompanion extends UpdateCompanion<BibleBook> {
  final Value<int> id;
  final Value<String> bookKey;
  final Value<String> testament;
  final Value<int> bookOrder;
  final Value<String> shortName;
  final Value<String> displayNameEn;
  final Value<String?> displayNameKo;
  final Value<int> chapterCount;
  const BibleBooksCompanion({
    this.id = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.testament = const Value.absent(),
    this.bookOrder = const Value.absent(),
    this.shortName = const Value.absent(),
    this.displayNameEn = const Value.absent(),
    this.displayNameKo = const Value.absent(),
    this.chapterCount = const Value.absent(),
  });
  BibleBooksCompanion.insert({
    this.id = const Value.absent(),
    required String bookKey,
    required String testament,
    required int bookOrder,
    required String shortName,
    required String displayNameEn,
    this.displayNameKo = const Value.absent(),
    required int chapterCount,
  })  : bookKey = Value(bookKey),
        testament = Value(testament),
        bookOrder = Value(bookOrder),
        shortName = Value(shortName),
        displayNameEn = Value(displayNameEn),
        chapterCount = Value(chapterCount);
  static Insertable<BibleBook> custom({
    Expression<int>? id,
    Expression<String>? bookKey,
    Expression<String>? testament,
    Expression<int>? bookOrder,
    Expression<String>? shortName,
    Expression<String>? displayNameEn,
    Expression<String>? displayNameKo,
    Expression<int>? chapterCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookKey != null) 'book_key': bookKey,
      if (testament != null) 'testament': testament,
      if (bookOrder != null) 'book_order': bookOrder,
      if (shortName != null) 'short_name': shortName,
      if (displayNameEn != null) 'display_name_en': displayNameEn,
      if (displayNameKo != null) 'display_name_ko': displayNameKo,
      if (chapterCount != null) 'chapter_count': chapterCount,
    });
  }

  BibleBooksCompanion copyWith(
      {Value<int>? id,
      Value<String>? bookKey,
      Value<String>? testament,
      Value<int>? bookOrder,
      Value<String>? shortName,
      Value<String>? displayNameEn,
      Value<String?>? displayNameKo,
      Value<int>? chapterCount}) {
    return BibleBooksCompanion(
      id: id ?? this.id,
      bookKey: bookKey ?? this.bookKey,
      testament: testament ?? this.testament,
      bookOrder: bookOrder ?? this.bookOrder,
      shortName: shortName ?? this.shortName,
      displayNameEn: displayNameEn ?? this.displayNameEn,
      displayNameKo: displayNameKo ?? this.displayNameKo,
      chapterCount: chapterCount ?? this.chapterCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookKey.present) {
      map['book_key'] = Variable<String>(bookKey.value);
    }
    if (testament.present) {
      map['testament'] = Variable<String>(testament.value);
    }
    if (bookOrder.present) {
      map['book_order'] = Variable<int>(bookOrder.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (displayNameEn.present) {
      map['display_name_en'] = Variable<String>(displayNameEn.value);
    }
    if (displayNameKo.present) {
      map['display_name_ko'] = Variable<String>(displayNameKo.value);
    }
    if (chapterCount.present) {
      map['chapter_count'] = Variable<int>(chapterCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleBooksCompanion(')
          ..write('id: $id, ')
          ..write('bookKey: $bookKey, ')
          ..write('testament: $testament, ')
          ..write('bookOrder: $bookOrder, ')
          ..write('shortName: $shortName, ')
          ..write('displayNameEn: $displayNameEn, ')
          ..write('displayNameKo: $displayNameKo, ')
          ..write('chapterCount: $chapterCount')
          ..write(')'))
        .toString();
  }
}

class $BibleChaptersTable extends BibleChapters
    with TableInfo<$BibleChaptersTable, BibleChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookKeyMeta =
      const VerificationMeta('bookKey');
  @override
  late final GeneratedColumn<String> bookKey = GeneratedColumn<String>(
      'book_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _verseCountMeta =
      const VerificationMeta('verseCount');
  @override
  late final GeneratedColumn<int> verseCount = GeneratedColumn<int>(
      'verse_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _estimatedReadingSecondsMeta =
      const VerificationMeta('estimatedReadingSeconds');
  @override
  late final GeneratedColumn<int> estimatedReadingSeconds =
      GeneratedColumn<int>('estimated_reading_seconds', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _estimatedReadingMinutesMeta =
      const VerificationMeta('estimatedReadingMinutes');
  @override
  late final GeneratedColumn<int> estimatedReadingMinutes =
      GeneratedColumn<int>('estimated_reading_minutes', aliasedName, false,
          type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        bookKey,
        chapterNumber,
        verseCount,
        estimatedReadingSeconds,
        estimatedReadingMinutes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_chapters';
  @override
  VerificationContext validateIntegrity(Insertable<BibleChapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_key')) {
      context.handle(_bookKeyMeta,
          bookKey.isAcceptableOrUnknown(data['book_key']!, _bookKeyMeta));
    } else if (isInserting) {
      context.missing(_bookKeyMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('verse_count')) {
      context.handle(
          _verseCountMeta,
          verseCount.isAcceptableOrUnknown(
              data['verse_count']!, _verseCountMeta));
    } else if (isInserting) {
      context.missing(_verseCountMeta);
    }
    if (data.containsKey('estimated_reading_seconds')) {
      context.handle(
          _estimatedReadingSecondsMeta,
          estimatedReadingSeconds.isAcceptableOrUnknown(
              data['estimated_reading_seconds']!,
              _estimatedReadingSecondsMeta));
    } else if (isInserting) {
      context.missing(_estimatedReadingSecondsMeta);
    }
    if (data.containsKey('estimated_reading_minutes')) {
      context.handle(
          _estimatedReadingMinutesMeta,
          estimatedReadingMinutes.isAcceptableOrUnknown(
              data['estimated_reading_minutes']!,
              _estimatedReadingMinutesMeta));
    } else if (isInserting) {
      context.missing(_estimatedReadingMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookKey, chapterNumber};
  @override
  BibleChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleChapter(
      bookKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_key'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number'])!,
      verseCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}verse_count'])!,
      estimatedReadingSeconds: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}estimated_reading_seconds'])!,
      estimatedReadingMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}estimated_reading_minutes'])!,
    );
  }

  @override
  $BibleChaptersTable createAlias(String alias) {
    return $BibleChaptersTable(attachedDatabase, alias);
  }
}

class BibleChapter extends DataClass implements Insertable<BibleChapter> {
  final String bookKey;
  final int chapterNumber;
  final int verseCount;
  final int estimatedReadingSeconds;
  final int estimatedReadingMinutes;
  const BibleChapter(
      {required this.bookKey,
      required this.chapterNumber,
      required this.verseCount,
      required this.estimatedReadingSeconds,
      required this.estimatedReadingMinutes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_key'] = Variable<String>(bookKey);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['verse_count'] = Variable<int>(verseCount);
    map['estimated_reading_seconds'] = Variable<int>(estimatedReadingSeconds);
    map['estimated_reading_minutes'] = Variable<int>(estimatedReadingMinutes);
    return map;
  }

  BibleChaptersCompanion toCompanion(bool nullToAbsent) {
    return BibleChaptersCompanion(
      bookKey: Value(bookKey),
      chapterNumber: Value(chapterNumber),
      verseCount: Value(verseCount),
      estimatedReadingSeconds: Value(estimatedReadingSeconds),
      estimatedReadingMinutes: Value(estimatedReadingMinutes),
    );
  }

  factory BibleChapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleChapter(
      bookKey: serializer.fromJson<String>(json['bookKey']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      verseCount: serializer.fromJson<int>(json['verseCount']),
      estimatedReadingSeconds:
          serializer.fromJson<int>(json['estimatedReadingSeconds']),
      estimatedReadingMinutes:
          serializer.fromJson<int>(json['estimatedReadingMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookKey': serializer.toJson<String>(bookKey),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'verseCount': serializer.toJson<int>(verseCount),
      'estimatedReadingSeconds':
          serializer.toJson<int>(estimatedReadingSeconds),
      'estimatedReadingMinutes':
          serializer.toJson<int>(estimatedReadingMinutes),
    };
  }

  BibleChapter copyWith(
          {String? bookKey,
          int? chapterNumber,
          int? verseCount,
          int? estimatedReadingSeconds,
          int? estimatedReadingMinutes}) =>
      BibleChapter(
        bookKey: bookKey ?? this.bookKey,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        verseCount: verseCount ?? this.verseCount,
        estimatedReadingSeconds:
            estimatedReadingSeconds ?? this.estimatedReadingSeconds,
        estimatedReadingMinutes:
            estimatedReadingMinutes ?? this.estimatedReadingMinutes,
      );
  BibleChapter copyWithCompanion(BibleChaptersCompanion data) {
    return BibleChapter(
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      verseCount:
          data.verseCount.present ? data.verseCount.value : this.verseCount,
      estimatedReadingSeconds: data.estimatedReadingSeconds.present
          ? data.estimatedReadingSeconds.value
          : this.estimatedReadingSeconds,
      estimatedReadingMinutes: data.estimatedReadingMinutes.present
          ? data.estimatedReadingMinutes.value
          : this.estimatedReadingMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BibleChapter(')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('verseCount: $verseCount, ')
          ..write('estimatedReadingSeconds: $estimatedReadingSeconds, ')
          ..write('estimatedReadingMinutes: $estimatedReadingMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookKey, chapterNumber, verseCount,
      estimatedReadingSeconds, estimatedReadingMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleChapter &&
          other.bookKey == this.bookKey &&
          other.chapterNumber == this.chapterNumber &&
          other.verseCount == this.verseCount &&
          other.estimatedReadingSeconds == this.estimatedReadingSeconds &&
          other.estimatedReadingMinutes == this.estimatedReadingMinutes);
}

class BibleChaptersCompanion extends UpdateCompanion<BibleChapter> {
  final Value<String> bookKey;
  final Value<int> chapterNumber;
  final Value<int> verseCount;
  final Value<int> estimatedReadingSeconds;
  final Value<int> estimatedReadingMinutes;
  final Value<int> rowid;
  const BibleChaptersCompanion({
    this.bookKey = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.verseCount = const Value.absent(),
    this.estimatedReadingSeconds = const Value.absent(),
    this.estimatedReadingMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BibleChaptersCompanion.insert({
    required String bookKey,
    required int chapterNumber,
    required int verseCount,
    required int estimatedReadingSeconds,
    required int estimatedReadingMinutes,
    this.rowid = const Value.absent(),
  })  : bookKey = Value(bookKey),
        chapterNumber = Value(chapterNumber),
        verseCount = Value(verseCount),
        estimatedReadingSeconds = Value(estimatedReadingSeconds),
        estimatedReadingMinutes = Value(estimatedReadingMinutes);
  static Insertable<BibleChapter> custom({
    Expression<String>? bookKey,
    Expression<int>? chapterNumber,
    Expression<int>? verseCount,
    Expression<int>? estimatedReadingSeconds,
    Expression<int>? estimatedReadingMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookKey != null) 'book_key': bookKey,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (verseCount != null) 'verse_count': verseCount,
      if (estimatedReadingSeconds != null)
        'estimated_reading_seconds': estimatedReadingSeconds,
      if (estimatedReadingMinutes != null)
        'estimated_reading_minutes': estimatedReadingMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BibleChaptersCompanion copyWith(
      {Value<String>? bookKey,
      Value<int>? chapterNumber,
      Value<int>? verseCount,
      Value<int>? estimatedReadingSeconds,
      Value<int>? estimatedReadingMinutes,
      Value<int>? rowid}) {
    return BibleChaptersCompanion(
      bookKey: bookKey ?? this.bookKey,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      verseCount: verseCount ?? this.verseCount,
      estimatedReadingSeconds:
          estimatedReadingSeconds ?? this.estimatedReadingSeconds,
      estimatedReadingMinutes:
          estimatedReadingMinutes ?? this.estimatedReadingMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookKey.present) {
      map['book_key'] = Variable<String>(bookKey.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (verseCount.present) {
      map['verse_count'] = Variable<int>(verseCount.value);
    }
    if (estimatedReadingSeconds.present) {
      map['estimated_reading_seconds'] =
          Variable<int>(estimatedReadingSeconds.value);
    }
    if (estimatedReadingMinutes.present) {
      map['estimated_reading_minutes'] =
          Variable<int>(estimatedReadingMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleChaptersCompanion(')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('verseCount: $verseCount, ')
          ..write('estimatedReadingSeconds: $estimatedReadingSeconds, ')
          ..write('estimatedReadingMinutes: $estimatedReadingMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('guest'));
  static const VerificationMeta _authUserIdMeta =
      const VerificationMeta('authUserId');
  @override
  late final GeneratedColumn<String> authUserId = GeneratedColumn<String>(
      'auth_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _clientRevisionMeta =
      const VerificationMeta('clientRevision');
  @override
  late final GeneratedColumn<int> clientRevision = GeneratedColumn<int>(
      'client_revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        authUserId,
        syncStatus,
        serverId,
        lastSyncedAt,
        clientRevision,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(Insertable<LocalUser> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('auth_user_id')) {
      context.handle(
          _authUserIdMeta,
          authUserId.isAcceptableOrUnknown(
              data['auth_user_id']!, _authUserIdMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('client_revision')) {
      context.handle(
          _clientRevisionMeta,
          clientRevision.isAcceptableOrUnknown(
              data['client_revision']!, _clientRevisionMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      authUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}auth_user_id']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      clientRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_revision'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String id;
  final String type;
  final String? authUserId;
  final String syncStatus;

  /// Server-side profile / identity row id after sync (`docs/SYNC_STRATEGY.md`).
  final String? serverId;
  final DateTime? lastSyncedAt;
  final int clientRevision;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocalUser(
      {required this.id,
      required this.type,
      this.authUserId,
      required this.syncStatus,
      this.serverId,
      this.lastSyncedAt,
      required this.clientRevision,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || authUserId != null) {
      map['auth_user_id'] = Variable<String>(authUserId);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['client_revision'] = Variable<int>(clientRevision);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      type: Value(type),
      authUserId: authUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(authUserId),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      clientRevision: Value(clientRevision),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalUser.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      authUserId: serializer.fromJson<String?>(json['authUserId']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      clientRevision: serializer.fromJson<int>(json['clientRevision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'authUserId': serializer.toJson<String?>(authUserId),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'clientRevision': serializer.toJson<int>(clientRevision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalUser copyWith(
          {String? id,
          String? type,
          Value<String?> authUserId = const Value.absent(),
          String? syncStatus,
          Value<String?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          int? clientRevision,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      LocalUser(
        id: id ?? this.id,
        type: type ?? this.type,
        authUserId: authUserId.present ? authUserId.value : this.authUserId,
        syncStatus: syncStatus ?? this.syncStatus,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        clientRevision: clientRevision ?? this.clientRevision,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      authUserId:
          data.authUserId.present ? data.authUserId.value : this.authUserId,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      clientRevision: data.clientRevision.present
          ? data.clientRevision.value
          : this.clientRevision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('authUserId: $authUserId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, authUserId, syncStatus, serverId,
      lastSyncedAt, clientRevision, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.type == this.type &&
          other.authUserId == this.authUserId &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.clientRevision == this.clientRevision &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> authUserId;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> clientRevision;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.authUserId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String id,
    this.type = const Value.absent(),
    this.authUserId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? authUserId,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? clientRevision,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (authUserId != null) 'auth_user_id': authUserId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (clientRevision != null) 'client_revision': clientRevision,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String?>? authUserId,
      Value<String>? syncStatus,
      Value<String?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? clientRevision,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      authUserId: authUserId ?? this.authUserId,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      clientRevision: clientRevision ?? this.clientRevision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (authUserId.present) {
      map['auth_user_id'] = Variable<String>(authUserId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (clientRevision.present) {
      map['client_revision'] = Variable<int>(clientRevision.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('authUserId: $authUserId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanTemplatesTable extends PlanTemplates
    with TableInfo<$PlanTemplatesTable, PlanTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateKeyMeta =
      const VerificationMeta('templateKey');
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
      'template_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subtitleMeta =
      const VerificationMeta('subtitle');
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
      'subtitle', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _shortDescriptionMeta =
      const VerificationMeta('shortDescription');
  @override
  late final GeneratedColumn<String> shortDescription = GeneratedColumn<String>(
      'short_description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _coverImageUrlMeta =
      const VerificationMeta('coverImageUrl');
  @override
  late final GeneratedColumn<String> coverImageUrl = GeneratedColumn<String>(
      'cover_image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _planTypeMeta =
      const VerificationMeta('planType');
  @override
  late final GeneratedColumn<String> planType = GeneratedColumn<String>(
      'plan_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('canonical'));
  static const VerificationMeta _testamentScopeMeta =
      const VerificationMeta('testamentScope');
  @override
  late final GeneratedColumn<String> testamentScope = GeneratedColumn<String>(
      'testament_scope', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('whole_bible'));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _estimatedMinutesMeta =
      const VerificationMeta('estimatedMinutes');
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
      'estimated_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _estimatedDaysMeta =
      const VerificationMeta('estimatedDays');
  @override
  late final GeneratedColumn<int> estimatedDays = GeneratedColumn<int>(
      'estimated_days', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _totalChaptersMeta =
      const VerificationMeta('totalChapters');
  @override
  late final GeneratedColumn<int> totalChapters = GeneratedColumn<int>(
      'total_chapters', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _primaryBookKeyMeta =
      const VerificationMeta('primaryBookKey');
  @override
  late final GeneratedColumn<String> primaryBookKey = GeneratedColumn<String>(
      'primary_book_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _primaryCharacterMeta =
      const VerificationMeta('primaryCharacter');
  @override
  late final GeneratedColumn<String> primaryCharacter = GeneratedColumn<String>(
      'primary_character', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isBuiltinMeta =
      const VerificationMeta('isBuiltin');
  @override
  late final GeneratedColumn<bool> isBuiltin = GeneratedColumn<bool>(
      'is_builtin', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_builtin" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isPublishedMeta =
      const VerificationMeta('isPublished');
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
      'is_published', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_published" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _featuredRankMeta =
      const VerificationMeta('featuredRank');
  @override
  late final GeneratedColumn<int> featuredRank = GeneratedColumn<int>(
      'featured_rank', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _browseVisibleMeta =
      const VerificationMeta('browseVisible');
  @override
  late final GeneratedColumn<bool> browseVisible = GeneratedColumn<bool>(
      'browse_visible', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("browse_visible" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        templateKey,
        title,
        subtitle,
        description,
        shortDescription,
        coverImageUrl,
        planType,
        testamentScope,
        difficulty,
        estimatedMinutes,
        estimatedDays,
        totalChapters,
        primaryBookKey,
        primaryCharacter,
        isBuiltin,
        isPublished,
        featuredRank,
        browseVisible,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_templates';
  @override
  VerificationContext validateIntegrity(Insertable<PlanTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_key')) {
      context.handle(
          _templateKeyMeta,
          templateKey.isAcceptableOrUnknown(
              data['template_key']!, _templateKeyMeta));
    } else if (isInserting) {
      context.missing(_templateKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(_subtitleMeta,
          subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('short_description')) {
      context.handle(
          _shortDescriptionMeta,
          shortDescription.isAcceptableOrUnknown(
              data['short_description']!, _shortDescriptionMeta));
    }
    if (data.containsKey('cover_image_url')) {
      context.handle(
          _coverImageUrlMeta,
          coverImageUrl.isAcceptableOrUnknown(
              data['cover_image_url']!, _coverImageUrlMeta));
    }
    if (data.containsKey('plan_type')) {
      context.handle(_planTypeMeta,
          planType.isAcceptableOrUnknown(data['plan_type']!, _planTypeMeta));
    }
    if (data.containsKey('testament_scope')) {
      context.handle(
          _testamentScopeMeta,
          testamentScope.isAcceptableOrUnknown(
              data['testament_scope']!, _testamentScopeMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
          _estimatedMinutesMeta,
          estimatedMinutes.isAcceptableOrUnknown(
              data['estimated_minutes']!, _estimatedMinutesMeta));
    }
    if (data.containsKey('estimated_days')) {
      context.handle(
          _estimatedDaysMeta,
          estimatedDays.isAcceptableOrUnknown(
              data['estimated_days']!, _estimatedDaysMeta));
    }
    if (data.containsKey('total_chapters')) {
      context.handle(
          _totalChaptersMeta,
          totalChapters.isAcceptableOrUnknown(
              data['total_chapters']!, _totalChaptersMeta));
    }
    if (data.containsKey('primary_book_key')) {
      context.handle(
          _primaryBookKeyMeta,
          primaryBookKey.isAcceptableOrUnknown(
              data['primary_book_key']!, _primaryBookKeyMeta));
    }
    if (data.containsKey('primary_character')) {
      context.handle(
          _primaryCharacterMeta,
          primaryCharacter.isAcceptableOrUnknown(
              data['primary_character']!, _primaryCharacterMeta));
    }
    if (data.containsKey('is_builtin')) {
      context.handle(_isBuiltinMeta,
          isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta));
    }
    if (data.containsKey('is_published')) {
      context.handle(
          _isPublishedMeta,
          isPublished.isAcceptableOrUnknown(
              data['is_published']!, _isPublishedMeta));
    }
    if (data.containsKey('featured_rank')) {
      context.handle(
          _featuredRankMeta,
          featuredRank.isAcceptableOrUnknown(
              data['featured_rank']!, _featuredRankMeta));
    }
    if (data.containsKey('browse_visible')) {
      context.handle(
          _browseVisibleMeta,
          browseVisible.isAcceptableOrUnknown(
              data['browse_visible']!, _browseVisibleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_key'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      subtitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subtitle'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      shortDescription: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}short_description'])!,
      coverImageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_image_url']),
      planType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_type'])!,
      testamentScope: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}testament_scope'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty']),
      estimatedMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_minutes']),
      estimatedDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_days']),
      totalChapters: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_chapters'])!,
      primaryBookKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}primary_book_key']),
      primaryCharacter: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}primary_character']),
      isBuiltin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_builtin'])!,
      isPublished: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_published'])!,
      featuredRank: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}featured_rank']),
      browseVisible: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}browse_visible'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlanTemplatesTable createAlias(String alias) {
    return $PlanTemplatesTable(attachedDatabase, alias);
  }
}

class PlanTemplate extends DataClass implements Insertable<PlanTemplate> {
  final String id;
  final String templateKey;
  final String title;
  final String subtitle;
  final String description;
  final String shortDescription;
  final String? coverImageUrl;
  final String planType;
  final String testamentScope;
  final String? difficulty;
  final int? estimatedMinutes;
  final int? estimatedDays;
  final int totalChapters;
  final String? primaryBookKey;
  final String? primaryCharacter;
  final bool isBuiltin;
  final bool isPublished;
  final int? featuredRank;
  final bool browseVisible;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlanTemplate(
      {required this.id,
      required this.templateKey,
      required this.title,
      required this.subtitle,
      required this.description,
      required this.shortDescription,
      this.coverImageUrl,
      required this.planType,
      required this.testamentScope,
      this.difficulty,
      this.estimatedMinutes,
      this.estimatedDays,
      required this.totalChapters,
      this.primaryBookKey,
      this.primaryCharacter,
      required this.isBuiltin,
      required this.isPublished,
      this.featuredRank,
      required this.browseVisible,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_key'] = Variable<String>(templateKey);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['description'] = Variable<String>(description);
    map['short_description'] = Variable<String>(shortDescription);
    if (!nullToAbsent || coverImageUrl != null) {
      map['cover_image_url'] = Variable<String>(coverImageUrl);
    }
    map['plan_type'] = Variable<String>(planType);
    map['testament_scope'] = Variable<String>(testamentScope);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    if (!nullToAbsent || estimatedDays != null) {
      map['estimated_days'] = Variable<int>(estimatedDays);
    }
    map['total_chapters'] = Variable<int>(totalChapters);
    if (!nullToAbsent || primaryBookKey != null) {
      map['primary_book_key'] = Variable<String>(primaryBookKey);
    }
    if (!nullToAbsent || primaryCharacter != null) {
      map['primary_character'] = Variable<String>(primaryCharacter);
    }
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['is_published'] = Variable<bool>(isPublished);
    if (!nullToAbsent || featuredRank != null) {
      map['featured_rank'] = Variable<int>(featuredRank);
    }
    map['browse_visible'] = Variable<bool>(browseVisible);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlanTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PlanTemplatesCompanion(
      id: Value(id),
      templateKey: Value(templateKey),
      title: Value(title),
      subtitle: Value(subtitle),
      description: Value(description),
      shortDescription: Value(shortDescription),
      coverImageUrl: coverImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageUrl),
      planType: Value(planType),
      testamentScope: Value(testamentScope),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      estimatedDays: estimatedDays == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedDays),
      totalChapters: Value(totalChapters),
      primaryBookKey: primaryBookKey == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryBookKey),
      primaryCharacter: primaryCharacter == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryCharacter),
      isBuiltin: Value(isBuiltin),
      isPublished: Value(isPublished),
      featuredRank: featuredRank == null && nullToAbsent
          ? const Value.absent()
          : Value(featuredRank),
      browseVisible: Value(browseVisible),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTemplate(
      id: serializer.fromJson<String>(json['id']),
      templateKey: serializer.fromJson<String>(json['templateKey']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      description: serializer.fromJson<String>(json['description']),
      shortDescription: serializer.fromJson<String>(json['shortDescription']),
      coverImageUrl: serializer.fromJson<String?>(json['coverImageUrl']),
      planType: serializer.fromJson<String>(json['planType']),
      testamentScope: serializer.fromJson<String>(json['testamentScope']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      estimatedDays: serializer.fromJson<int?>(json['estimatedDays']),
      totalChapters: serializer.fromJson<int>(json['totalChapters']),
      primaryBookKey: serializer.fromJson<String?>(json['primaryBookKey']),
      primaryCharacter: serializer.fromJson<String?>(json['primaryCharacter']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      featuredRank: serializer.fromJson<int?>(json['featuredRank']),
      browseVisible: serializer.fromJson<bool>(json['browseVisible']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateKey': serializer.toJson<String>(templateKey),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'description': serializer.toJson<String>(description),
      'shortDescription': serializer.toJson<String>(shortDescription),
      'coverImageUrl': serializer.toJson<String?>(coverImageUrl),
      'planType': serializer.toJson<String>(planType),
      'testamentScope': serializer.toJson<String>(testamentScope),
      'difficulty': serializer.toJson<String?>(difficulty),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'estimatedDays': serializer.toJson<int?>(estimatedDays),
      'totalChapters': serializer.toJson<int>(totalChapters),
      'primaryBookKey': serializer.toJson<String?>(primaryBookKey),
      'primaryCharacter': serializer.toJson<String?>(primaryCharacter),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'isPublished': serializer.toJson<bool>(isPublished),
      'featuredRank': serializer.toJson<int?>(featuredRank),
      'browseVisible': serializer.toJson<bool>(browseVisible),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlanTemplate copyWith(
          {String? id,
          String? templateKey,
          String? title,
          String? subtitle,
          String? description,
          String? shortDescription,
          Value<String?> coverImageUrl = const Value.absent(),
          String? planType,
          String? testamentScope,
          Value<String?> difficulty = const Value.absent(),
          Value<int?> estimatedMinutes = const Value.absent(),
          Value<int?> estimatedDays = const Value.absent(),
          int? totalChapters,
          Value<String?> primaryBookKey = const Value.absent(),
          Value<String?> primaryCharacter = const Value.absent(),
          bool? isBuiltin,
          bool? isPublished,
          Value<int?> featuredRank = const Value.absent(),
          bool? browseVisible,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PlanTemplate(
        id: id ?? this.id,
        templateKey: templateKey ?? this.templateKey,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        description: description ?? this.description,
        shortDescription: shortDescription ?? this.shortDescription,
        coverImageUrl:
            coverImageUrl.present ? coverImageUrl.value : this.coverImageUrl,
        planType: planType ?? this.planType,
        testamentScope: testamentScope ?? this.testamentScope,
        difficulty: difficulty.present ? difficulty.value : this.difficulty,
        estimatedMinutes: estimatedMinutes.present
            ? estimatedMinutes.value
            : this.estimatedMinutes,
        estimatedDays:
            estimatedDays.present ? estimatedDays.value : this.estimatedDays,
        totalChapters: totalChapters ?? this.totalChapters,
        primaryBookKey:
            primaryBookKey.present ? primaryBookKey.value : this.primaryBookKey,
        primaryCharacter: primaryCharacter.present
            ? primaryCharacter.value
            : this.primaryCharacter,
        isBuiltin: isBuiltin ?? this.isBuiltin,
        isPublished: isPublished ?? this.isPublished,
        featuredRank:
            featuredRank.present ? featuredRank.value : this.featuredRank,
        browseVisible: browseVisible ?? this.browseVisible,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PlanTemplate copyWithCompanion(PlanTemplatesCompanion data) {
    return PlanTemplate(
      id: data.id.present ? data.id.value : this.id,
      templateKey:
          data.templateKey.present ? data.templateKey.value : this.templateKey,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      description:
          data.description.present ? data.description.value : this.description,
      shortDescription: data.shortDescription.present
          ? data.shortDescription.value
          : this.shortDescription,
      coverImageUrl: data.coverImageUrl.present
          ? data.coverImageUrl.value
          : this.coverImageUrl,
      planType: data.planType.present ? data.planType.value : this.planType,
      testamentScope: data.testamentScope.present
          ? data.testamentScope.value
          : this.testamentScope,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      estimatedDays: data.estimatedDays.present
          ? data.estimatedDays.value
          : this.estimatedDays,
      totalChapters: data.totalChapters.present
          ? data.totalChapters.value
          : this.totalChapters,
      primaryBookKey: data.primaryBookKey.present
          ? data.primaryBookKey.value
          : this.primaryBookKey,
      primaryCharacter: data.primaryCharacter.present
          ? data.primaryCharacter.value
          : this.primaryCharacter,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      isPublished:
          data.isPublished.present ? data.isPublished.value : this.isPublished,
      featuredRank: data.featuredRank.present
          ? data.featuredRank.value
          : this.featuredRank,
      browseVisible: data.browseVisible.present
          ? data.browseVisible.value
          : this.browseVisible,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplate(')
          ..write('id: $id, ')
          ..write('templateKey: $templateKey, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('description: $description, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('planType: $planType, ')
          ..write('testamentScope: $testamentScope, ')
          ..write('difficulty: $difficulty, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('estimatedDays: $estimatedDays, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('primaryBookKey: $primaryBookKey, ')
          ..write('primaryCharacter: $primaryCharacter, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('isPublished: $isPublished, ')
          ..write('featuredRank: $featuredRank, ')
          ..write('browseVisible: $browseVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        templateKey,
        title,
        subtitle,
        description,
        shortDescription,
        coverImageUrl,
        planType,
        testamentScope,
        difficulty,
        estimatedMinutes,
        estimatedDays,
        totalChapters,
        primaryBookKey,
        primaryCharacter,
        isBuiltin,
        isPublished,
        featuredRank,
        browseVisible,
        createdAt,
        updatedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTemplate &&
          other.id == this.id &&
          other.templateKey == this.templateKey &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.description == this.description &&
          other.shortDescription == this.shortDescription &&
          other.coverImageUrl == this.coverImageUrl &&
          other.planType == this.planType &&
          other.testamentScope == this.testamentScope &&
          other.difficulty == this.difficulty &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.estimatedDays == this.estimatedDays &&
          other.totalChapters == this.totalChapters &&
          other.primaryBookKey == this.primaryBookKey &&
          other.primaryCharacter == this.primaryCharacter &&
          other.isBuiltin == this.isBuiltin &&
          other.isPublished == this.isPublished &&
          other.featuredRank == this.featuredRank &&
          other.browseVisible == this.browseVisible &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlanTemplatesCompanion extends UpdateCompanion<PlanTemplate> {
  final Value<String> id;
  final Value<String> templateKey;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> description;
  final Value<String> shortDescription;
  final Value<String?> coverImageUrl;
  final Value<String> planType;
  final Value<String> testamentScope;
  final Value<String?> difficulty;
  final Value<int?> estimatedMinutes;
  final Value<int?> estimatedDays;
  final Value<int> totalChapters;
  final Value<String?> primaryBookKey;
  final Value<String?> primaryCharacter;
  final Value<bool> isBuiltin;
  final Value<bool> isPublished;
  final Value<int?> featuredRank;
  final Value<bool> browseVisible;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlanTemplatesCompanion({
    this.id = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.description = const Value.absent(),
    this.shortDescription = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.planType = const Value.absent(),
    this.testamentScope = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.estimatedDays = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.primaryBookKey = const Value.absent(),
    this.primaryCharacter = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.featuredRank = const Value.absent(),
    this.browseVisible = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanTemplatesCompanion.insert({
    required String id,
    required String templateKey,
    required String title,
    this.subtitle = const Value.absent(),
    this.description = const Value.absent(),
    this.shortDescription = const Value.absent(),
    this.coverImageUrl = const Value.absent(),
    this.planType = const Value.absent(),
    this.testamentScope = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.estimatedDays = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.primaryBookKey = const Value.absent(),
    this.primaryCharacter = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.featuredRank = const Value.absent(),
    this.browseVisible = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateKey = Value(templateKey),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PlanTemplate> custom({
    Expression<String>? id,
    Expression<String>? templateKey,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? description,
    Expression<String>? shortDescription,
    Expression<String>? coverImageUrl,
    Expression<String>? planType,
    Expression<String>? testamentScope,
    Expression<String>? difficulty,
    Expression<int>? estimatedMinutes,
    Expression<int>? estimatedDays,
    Expression<int>? totalChapters,
    Expression<String>? primaryBookKey,
    Expression<String>? primaryCharacter,
    Expression<bool>? isBuiltin,
    Expression<bool>? isPublished,
    Expression<int>? featuredRank,
    Expression<bool>? browseVisible,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateKey != null) 'template_key': templateKey,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (description != null) 'description': description,
      if (shortDescription != null) 'short_description': shortDescription,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      if (planType != null) 'plan_type': planType,
      if (testamentScope != null) 'testament_scope': testamentScope,
      if (difficulty != null) 'difficulty': difficulty,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (estimatedDays != null) 'estimated_days': estimatedDays,
      if (totalChapters != null) 'total_chapters': totalChapters,
      if (primaryBookKey != null) 'primary_book_key': primaryBookKey,
      if (primaryCharacter != null) 'primary_character': primaryCharacter,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (isPublished != null) 'is_published': isPublished,
      if (featuredRank != null) 'featured_rank': featuredRank,
      if (browseVisible != null) 'browse_visible': browseVisible,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateKey,
      Value<String>? title,
      Value<String>? subtitle,
      Value<String>? description,
      Value<String>? shortDescription,
      Value<String?>? coverImageUrl,
      Value<String>? planType,
      Value<String>? testamentScope,
      Value<String?>? difficulty,
      Value<int?>? estimatedMinutes,
      Value<int?>? estimatedDays,
      Value<int>? totalChapters,
      Value<String?>? primaryBookKey,
      Value<String?>? primaryCharacter,
      Value<bool>? isBuiltin,
      Value<bool>? isPublished,
      Value<int?>? featuredRank,
      Value<bool>? browseVisible,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PlanTemplatesCompanion(
      id: id ?? this.id,
      templateKey: templateKey ?? this.templateKey,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      planType: planType ?? this.planType,
      testamentScope: testamentScope ?? this.testamentScope,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      totalChapters: totalChapters ?? this.totalChapters,
      primaryBookKey: primaryBookKey ?? this.primaryBookKey,
      primaryCharacter: primaryCharacter ?? this.primaryCharacter,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      isPublished: isPublished ?? this.isPublished,
      featuredRank: featuredRank ?? this.featuredRank,
      browseVisible: browseVisible ?? this.browseVisible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateKey.present) {
      map['template_key'] = Variable<String>(templateKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (shortDescription.present) {
      map['short_description'] = Variable<String>(shortDescription.value);
    }
    if (coverImageUrl.present) {
      map['cover_image_url'] = Variable<String>(coverImageUrl.value);
    }
    if (planType.present) {
      map['plan_type'] = Variable<String>(planType.value);
    }
    if (testamentScope.present) {
      map['testament_scope'] = Variable<String>(testamentScope.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (estimatedDays.present) {
      map['estimated_days'] = Variable<int>(estimatedDays.value);
    }
    if (totalChapters.present) {
      map['total_chapters'] = Variable<int>(totalChapters.value);
    }
    if (primaryBookKey.present) {
      map['primary_book_key'] = Variable<String>(primaryBookKey.value);
    }
    if (primaryCharacter.present) {
      map['primary_character'] = Variable<String>(primaryCharacter.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (featuredRank.present) {
      map['featured_rank'] = Variable<int>(featuredRank.value);
    }
    if (browseVisible.present) {
      map['browse_visible'] = Variable<bool>(browseVisible.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('templateKey: $templateKey, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('description: $description, ')
          ..write('shortDescription: $shortDescription, ')
          ..write('coverImageUrl: $coverImageUrl, ')
          ..write('planType: $planType, ')
          ..write('testamentScope: $testamentScope, ')
          ..write('difficulty: $difficulty, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('estimatedDays: $estimatedDays, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('primaryBookKey: $primaryBookKey, ')
          ..write('primaryCharacter: $primaryCharacter, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('isPublished: $isPublished, ')
          ..write('featuredRank: $featuredRank, ')
          ..write('browseVisible: $browseVisible, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanTemplateSectionsTable extends PlanTemplateSections
    with TableInfo<$PlanTemplateSectionsTable, PlanTemplateSection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTemplateSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _planTemplateIdMeta =
      const VerificationMeta('planTemplateId');
  @override
  late final GeneratedColumn<String> planTemplateId = GeneratedColumn<String>(
      'plan_template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sectionKeyMeta =
      const VerificationMeta('sectionKey');
  @override
  late final GeneratedColumn<String> sectionKey = GeneratedColumn<String>(
      'section_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _estimatedMinutesMeta =
      const VerificationMeta('estimatedMinutes');
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
      'estimated_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        planTemplateId,
        sectionKey,
        title,
        description,
        orderIndex,
        estimatedMinutes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_template_sections';
  @override
  VerificationContext validateIntegrity(
      Insertable<PlanTemplateSection> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_template_id')) {
      context.handle(
          _planTemplateIdMeta,
          planTemplateId.isAcceptableOrUnknown(
              data['plan_template_id']!, _planTemplateIdMeta));
    } else if (isInserting) {
      context.missing(_planTemplateIdMeta);
    }
    if (data.containsKey('section_key')) {
      context.handle(
          _sectionKeyMeta,
          sectionKey.isAcceptableOrUnknown(
              data['section_key']!, _sectionKeyMeta));
    } else if (isInserting) {
      context.missing(_sectionKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
          _estimatedMinutesMeta,
          estimatedMinutes.isAcceptableOrUnknown(
              data['estimated_minutes']!, _estimatedMinutesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {planTemplateId, sectionKey},
      ];
  @override
  PlanTemplateSection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTemplateSection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}plan_template_id'])!,
      sectionKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_key'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      estimatedMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}estimated_minutes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlanTemplateSectionsTable createAlias(String alias) {
    return $PlanTemplateSectionsTable(attachedDatabase, alias);
  }
}

class PlanTemplateSection extends DataClass
    implements Insertable<PlanTemplateSection> {
  final String id;
  final String planTemplateId;
  final String sectionKey;
  final String title;
  final String description;
  final int orderIndex;
  final int? estimatedMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlanTemplateSection(
      {required this.id,
      required this.planTemplateId,
      required this.sectionKey,
      required this.title,
      required this.description,
      required this.orderIndex,
      this.estimatedMinutes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_template_id'] = Variable<String>(planTemplateId);
    map['section_key'] = Variable<String>(sectionKey);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlanTemplateSectionsCompanion toCompanion(bool nullToAbsent) {
    return PlanTemplateSectionsCompanion(
      id: Value(id),
      planTemplateId: Value(planTemplateId),
      sectionKey: Value(sectionKey),
      title: Value(title),
      description: Value(description),
      orderIndex: Value(orderIndex),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanTemplateSection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTemplateSection(
      id: serializer.fromJson<String>(json['id']),
      planTemplateId: serializer.fromJson<String>(json['planTemplateId']),
      sectionKey: serializer.fromJson<String>(json['sectionKey']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planTemplateId': serializer.toJson<String>(planTemplateId),
      'sectionKey': serializer.toJson<String>(sectionKey),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlanTemplateSection copyWith(
          {String? id,
          String? planTemplateId,
          String? sectionKey,
          String? title,
          String? description,
          int? orderIndex,
          Value<int?> estimatedMinutes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PlanTemplateSection(
        id: id ?? this.id,
        planTemplateId: planTemplateId ?? this.planTemplateId,
        sectionKey: sectionKey ?? this.sectionKey,
        title: title ?? this.title,
        description: description ?? this.description,
        orderIndex: orderIndex ?? this.orderIndex,
        estimatedMinutes: estimatedMinutes.present
            ? estimatedMinutes.value
            : this.estimatedMinutes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PlanTemplateSection copyWithCompanion(PlanTemplateSectionsCompanion data) {
    return PlanTemplateSection(
      id: data.id.present ? data.id.value : this.id,
      planTemplateId: data.planTemplateId.present
          ? data.planTemplateId.value
          : this.planTemplateId,
      sectionKey:
          data.sectionKey.present ? data.sectionKey.value : this.sectionKey,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplateSection(')
          ..write('id: $id, ')
          ..write('planTemplateId: $planTemplateId, ')
          ..write('sectionKey: $sectionKey, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planTemplateId, sectionKey, title,
      description, orderIndex, estimatedMinutes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTemplateSection &&
          other.id == this.id &&
          other.planTemplateId == this.planTemplateId &&
          other.sectionKey == this.sectionKey &&
          other.title == this.title &&
          other.description == this.description &&
          other.orderIndex == this.orderIndex &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlanTemplateSectionsCompanion
    extends UpdateCompanion<PlanTemplateSection> {
  final Value<String> id;
  final Value<String> planTemplateId;
  final Value<String> sectionKey;
  final Value<String> title;
  final Value<String> description;
  final Value<int> orderIndex;
  final Value<int?> estimatedMinutes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlanTemplateSectionsCompanion({
    this.id = const Value.absent(),
    this.planTemplateId = const Value.absent(),
    this.sectionKey = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanTemplateSectionsCompanion.insert({
    required String id,
    required String planTemplateId,
    required String sectionKey,
    required String title,
    this.description = const Value.absent(),
    required int orderIndex,
    this.estimatedMinutes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planTemplateId = Value(planTemplateId),
        sectionKey = Value(sectionKey),
        title = Value(title),
        orderIndex = Value(orderIndex),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PlanTemplateSection> custom({
    Expression<String>? id,
    Expression<String>? planTemplateId,
    Expression<String>? sectionKey,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? orderIndex,
    Expression<int>? estimatedMinutes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planTemplateId != null) 'plan_template_id': planTemplateId,
      if (sectionKey != null) 'section_key': sectionKey,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (orderIndex != null) 'order_index': orderIndex,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanTemplateSectionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? planTemplateId,
      Value<String>? sectionKey,
      Value<String>? title,
      Value<String>? description,
      Value<int>? orderIndex,
      Value<int?>? estimatedMinutes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PlanTemplateSectionsCompanion(
      id: id ?? this.id,
      planTemplateId: planTemplateId ?? this.planTemplateId,
      sectionKey: sectionKey ?? this.sectionKey,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planTemplateId.present) {
      map['plan_template_id'] = Variable<String>(planTemplateId.value);
    }
    if (sectionKey.present) {
      map['section_key'] = Variable<String>(sectionKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplateSectionsCompanion(')
          ..write('id: $id, ')
          ..write('planTemplateId: $planTemplateId, ')
          ..write('sectionKey: $sectionKey, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanTemplateItemsTable extends PlanTemplateItems
    with TableInfo<$PlanTemplateItemsTable, PlanTemplateItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTemplateItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sectionIdMeta =
      const VerificationMeta('sectionId');
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
      'section_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bookKeyMeta =
      const VerificationMeta('bookKey');
  @override
  late final GeneratedColumn<String> bookKey = GeneratedColumn<String>(
      'book_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startChapterMeta =
      const VerificationMeta('startChapter');
  @override
  late final GeneratedColumn<int> startChapter = GeneratedColumn<int>(
      'start_chapter', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endChapterMeta =
      const VerificationMeta('endChapter');
  @override
  late final GeneratedColumn<int> endChapter = GeneratedColumn<int>(
      'end_chapter', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sectionId, orderIndex, bookKey, startChapter, endChapter];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_template_items';
  @override
  VerificationContext validateIntegrity(Insertable<PlanTemplateItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(_sectionIdMeta,
          sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta));
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('book_key')) {
      context.handle(_bookKeyMeta,
          bookKey.isAcceptableOrUnknown(data['book_key']!, _bookKeyMeta));
    } else if (isInserting) {
      context.missing(_bookKeyMeta);
    }
    if (data.containsKey('start_chapter')) {
      context.handle(
          _startChapterMeta,
          startChapter.isAcceptableOrUnknown(
              data['start_chapter']!, _startChapterMeta));
    } else if (isInserting) {
      context.missing(_startChapterMeta);
    }
    if (data.containsKey('end_chapter')) {
      context.handle(
          _endChapterMeta,
          endChapter.isAcceptableOrUnknown(
              data['end_chapter']!, _endChapterMeta));
    } else if (isInserting) {
      context.missing(_endChapterMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanTemplateItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTemplateItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      bookKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_key'])!,
      startChapter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_chapter'])!,
      endChapter: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_chapter'])!,
    );
  }

  @override
  $PlanTemplateItemsTable createAlias(String alias) {
    return $PlanTemplateItemsTable(attachedDatabase, alias);
  }
}

class PlanTemplateItem extends DataClass
    implements Insertable<PlanTemplateItem> {
  final String id;
  final String sectionId;
  final int orderIndex;
  final String bookKey;
  final int startChapter;
  final int endChapter;
  const PlanTemplateItem(
      {required this.id,
      required this.sectionId,
      required this.orderIndex,
      required this.bookKey,
      required this.startChapter,
      required this.endChapter});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['section_id'] = Variable<String>(sectionId);
    map['order_index'] = Variable<int>(orderIndex);
    map['book_key'] = Variable<String>(bookKey);
    map['start_chapter'] = Variable<int>(startChapter);
    map['end_chapter'] = Variable<int>(endChapter);
    return map;
  }

  PlanTemplateItemsCompanion toCompanion(bool nullToAbsent) {
    return PlanTemplateItemsCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      orderIndex: Value(orderIndex),
      bookKey: Value(bookKey),
      startChapter: Value(startChapter),
      endChapter: Value(endChapter),
    );
  }

  factory PlanTemplateItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTemplateItem(
      id: serializer.fromJson<String>(json['id']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      startChapter: serializer.fromJson<int>(json['startChapter']),
      endChapter: serializer.fromJson<int>(json['endChapter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sectionId': serializer.toJson<String>(sectionId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'bookKey': serializer.toJson<String>(bookKey),
      'startChapter': serializer.toJson<int>(startChapter),
      'endChapter': serializer.toJson<int>(endChapter),
    };
  }

  PlanTemplateItem copyWith(
          {String? id,
          String? sectionId,
          int? orderIndex,
          String? bookKey,
          int? startChapter,
          int? endChapter}) =>
      PlanTemplateItem(
        id: id ?? this.id,
        sectionId: sectionId ?? this.sectionId,
        orderIndex: orderIndex ?? this.orderIndex,
        bookKey: bookKey ?? this.bookKey,
        startChapter: startChapter ?? this.startChapter,
        endChapter: endChapter ?? this.endChapter,
      );
  PlanTemplateItem copyWithCompanion(PlanTemplateItemsCompanion data) {
    return PlanTemplateItem(
      id: data.id.present ? data.id.value : this.id,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      startChapter: data.startChapter.present
          ? data.startChapter.value
          : this.startChapter,
      endChapter:
          data.endChapter.present ? data.endChapter.value : this.endChapter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplateItem(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('bookKey: $bookKey, ')
          ..write('startChapter: $startChapter, ')
          ..write('endChapter: $endChapter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sectionId, orderIndex, bookKey, startChapter, endChapter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTemplateItem &&
          other.id == this.id &&
          other.sectionId == this.sectionId &&
          other.orderIndex == this.orderIndex &&
          other.bookKey == this.bookKey &&
          other.startChapter == this.startChapter &&
          other.endChapter == this.endChapter);
}

class PlanTemplateItemsCompanion extends UpdateCompanion<PlanTemplateItem> {
  final Value<String> id;
  final Value<String> sectionId;
  final Value<int> orderIndex;
  final Value<String> bookKey;
  final Value<int> startChapter;
  final Value<int> endChapter;
  final Value<int> rowid;
  const PlanTemplateItemsCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.startChapter = const Value.absent(),
    this.endChapter = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanTemplateItemsCompanion.insert({
    required String id,
    required String sectionId,
    required int orderIndex,
    required String bookKey,
    required int startChapter,
    required int endChapter,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sectionId = Value(sectionId),
        orderIndex = Value(orderIndex),
        bookKey = Value(bookKey),
        startChapter = Value(startChapter),
        endChapter = Value(endChapter);
  static Insertable<PlanTemplateItem> custom({
    Expression<String>? id,
    Expression<String>? sectionId,
    Expression<int>? orderIndex,
    Expression<String>? bookKey,
    Expression<int>? startChapter,
    Expression<int>? endChapter,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (bookKey != null) 'book_key': bookKey,
      if (startChapter != null) 'start_chapter': startChapter,
      if (endChapter != null) 'end_chapter': endChapter,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanTemplateItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? sectionId,
      Value<int>? orderIndex,
      Value<String>? bookKey,
      Value<int>? startChapter,
      Value<int>? endChapter,
      Value<int>? rowid}) {
    return PlanTemplateItemsCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      orderIndex: orderIndex ?? this.orderIndex,
      bookKey: bookKey ?? this.bookKey,
      startChapter: startChapter ?? this.startChapter,
      endChapter: endChapter ?? this.endChapter,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (bookKey.present) {
      map['book_key'] = Variable<String>(bookKey.value);
    }
    if (startChapter.present) {
      map['start_chapter'] = Variable<int>(startChapter.value);
    }
    if (endChapter.present) {
      map['end_chapter'] = Variable<int>(endChapter.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplateItemsCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('bookKey: $bookKey, ')
          ..write('startChapter: $startChapter, ')
          ..write('endChapter: $endChapter, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanTagsTable extends PlanTags with TableInfo<$PlanTagsTable, PlanTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, key, name, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_tags';
  @override
  VerificationContext validateIntegrity(Insertable<PlanTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $PlanTagsTable createAlias(String alias) {
    return $PlanTagsTable(attachedDatabase, alias);
  }
}

class PlanTag extends DataClass implements Insertable<PlanTag> {
  final String id;
  final String key;
  final String name;
  final String type;
  const PlanTag(
      {required this.id,
      required this.key,
      required this.name,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['key'] = Variable<String>(key);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    return map;
  }

  PlanTagsCompanion toCompanion(bool nullToAbsent) {
    return PlanTagsCompanion(
      id: Value(id),
      key: Value(key),
      name: Value(name),
      type: Value(type),
    );
  }

  factory PlanTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTag(
      id: serializer.fromJson<String>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'key': serializer.toJson<String>(key),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
    };
  }

  PlanTag copyWith({String? id, String? key, String? name, String? type}) =>
      PlanTag(
        id: id ?? this.id,
        key: key ?? this.key,
        name: name ?? this.name,
        type: type ?? this.type,
      );
  PlanTag copyWithCompanion(PlanTagsCompanion data) {
    return PlanTag(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTag(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, name, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTag &&
          other.id == this.id &&
          other.key == this.key &&
          other.name == this.name &&
          other.type == this.type);
}

class PlanTagsCompanion extends UpdateCompanion<PlanTag> {
  final Value<String> id;
  final Value<String> key;
  final Value<String> name;
  final Value<String> type;
  final Value<int> rowid;
  const PlanTagsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanTagsCompanion.insert({
    required String id,
    required String key,
    required String name,
    required String type,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        key = Value(key),
        name = Value(name),
        type = Value(type);
  static Insertable<PlanTag> custom({
    Expression<String>? id,
    Expression<String>? key,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanTagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? key,
      Value<String>? name,
      Value<String>? type,
      Value<int>? rowid}) {
    return PlanTagsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTagsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanTemplateTagsTable extends PlanTemplateTags
    with TableInfo<$PlanTemplateTagsTable, PlanTemplateTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTemplateTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _planTemplateIdMeta =
      const VerificationMeta('planTemplateId');
  @override
  late final GeneratedColumn<String> planTemplateId = GeneratedColumn<String>(
      'plan_template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [planTemplateId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_template_tags';
  @override
  VerificationContext validateIntegrity(Insertable<PlanTemplateTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plan_template_id')) {
      context.handle(
          _planTemplateIdMeta,
          planTemplateId.isAcceptableOrUnknown(
              data['plan_template_id']!, _planTemplateIdMeta));
    } else if (isInserting) {
      context.missing(_planTemplateIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {planTemplateId, tagId};
  @override
  PlanTemplateTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTemplateTag(
      planTemplateId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}plan_template_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $PlanTemplateTagsTable createAlias(String alias) {
    return $PlanTemplateTagsTable(attachedDatabase, alias);
  }
}

class PlanTemplateTag extends DataClass implements Insertable<PlanTemplateTag> {
  final String planTemplateId;
  final String tagId;
  const PlanTemplateTag({required this.planTemplateId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plan_template_id'] = Variable<String>(planTemplateId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  PlanTemplateTagsCompanion toCompanion(bool nullToAbsent) {
    return PlanTemplateTagsCompanion(
      planTemplateId: Value(planTemplateId),
      tagId: Value(tagId),
    );
  }

  factory PlanTemplateTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTemplateTag(
      planTemplateId: serializer.fromJson<String>(json['planTemplateId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'planTemplateId': serializer.toJson<String>(planTemplateId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  PlanTemplateTag copyWith({String? planTemplateId, String? tagId}) =>
      PlanTemplateTag(
        planTemplateId: planTemplateId ?? this.planTemplateId,
        tagId: tagId ?? this.tagId,
      );
  PlanTemplateTag copyWithCompanion(PlanTemplateTagsCompanion data) {
    return PlanTemplateTag(
      planTemplateId: data.planTemplateId.present
          ? data.planTemplateId.value
          : this.planTemplateId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplateTag(')
          ..write('planTemplateId: $planTemplateId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(planTemplateId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTemplateTag &&
          other.planTemplateId == this.planTemplateId &&
          other.tagId == this.tagId);
}

class PlanTemplateTagsCompanion extends UpdateCompanion<PlanTemplateTag> {
  final Value<String> planTemplateId;
  final Value<String> tagId;
  final Value<int> rowid;
  const PlanTemplateTagsCompanion({
    this.planTemplateId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanTemplateTagsCompanion.insert({
    required String planTemplateId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : planTemplateId = Value(planTemplateId),
        tagId = Value(tagId);
  static Insertable<PlanTemplateTag> custom({
    Expression<String>? planTemplateId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (planTemplateId != null) 'plan_template_id': planTemplateId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanTemplateTagsCompanion copyWith(
      {Value<String>? planTemplateId,
      Value<String>? tagId,
      Value<int>? rowid}) {
    return PlanTemplateTagsCompanion(
      planTemplateId: planTemplateId ?? this.planTemplateId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (planTemplateId.present) {
      map['plan_template_id'] = Variable<String>(planTemplateId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTemplateTagsCompanion(')
          ..write('planTemplateId: $planTemplateId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserReadingPlansTable extends UserReadingPlans
    with TableInfo<$UserReadingPlansTable, UserReadingPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserReadingPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localUserIdMeta =
      const VerificationMeta('localUserId');
  @override
  late final GeneratedColumn<String> localUserId = GeneratedColumn<String>(
      'local_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _subscribedAtMeta =
      const VerificationMeta('subscribedAt');
  @override
  late final GeneratedColumn<DateTime> subscribedAt = GeneratedColumn<DateTime>(
      'subscribed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _archivedAtMeta =
      const VerificationMeta('archivedAt');
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
      'archived_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastOpenedSectionIdMeta =
      const VerificationMeta('lastOpenedSectionId');
  @override
  late final GeneratedColumn<String> lastOpenedSectionId =
      GeneratedColumn<String>('last_opened_section_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastOpenedBookKeyMeta =
      const VerificationMeta('lastOpenedBookKey');
  @override
  late final GeneratedColumn<String> lastOpenedBookKey =
      GeneratedColumn<String>('last_opened_book_key', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _clientRevisionMeta =
      const VerificationMeta('clientRevision');
  @override
  late final GeneratedColumn<int> clientRevision = GeneratedColumn<int>(
      'client_revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        localUserId,
        templateId,
        title,
        status,
        subscribedAt,
        startedAt,
        completedAt,
        archivedAt,
        isActive,
        lastOpenedSectionId,
        lastOpenedBookKey,
        createdAt,
        updatedAt,
        syncStatus,
        serverId,
        lastSyncedAt,
        clientRevision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_reading_plans';
  @override
  VerificationContext validateIntegrity(Insertable<UserReadingPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_user_id')) {
      context.handle(
          _localUserIdMeta,
          localUserId.isAcceptableOrUnknown(
              data['local_user_id']!, _localUserIdMeta));
    } else if (isInserting) {
      context.missing(_localUserIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
          _subscribedAtMeta,
          subscribedAt.isAcceptableOrUnknown(
              data['subscribed_at']!, _subscribedAtMeta));
    } else if (isInserting) {
      context.missing(_subscribedAtMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('archived_at')) {
      context.handle(
          _archivedAtMeta,
          archivedAt.isAcceptableOrUnknown(
              data['archived_at']!, _archivedAtMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('last_opened_section_id')) {
      context.handle(
          _lastOpenedSectionIdMeta,
          lastOpenedSectionId.isAcceptableOrUnknown(
              data['last_opened_section_id']!, _lastOpenedSectionIdMeta));
    }
    if (data.containsKey('last_opened_book_key')) {
      context.handle(
          _lastOpenedBookKeyMeta,
          lastOpenedBookKey.isAcceptableOrUnknown(
              data['last_opened_book_key']!, _lastOpenedBookKeyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('client_revision')) {
      context.handle(
          _clientRevisionMeta,
          clientRevision.isAcceptableOrUnknown(
              data['client_revision']!, _clientRevisionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserReadingPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserReadingPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      localUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_user_id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      subscribedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}subscribed_at'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      archivedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}archived_at']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastOpenedSectionId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_opened_section_id']),
      lastOpenedBookKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_opened_book_key']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      clientRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_revision'])!,
    );
  }

  @override
  $UserReadingPlansTable createAlias(String alias) {
    return $UserReadingPlansTable(attachedDatabase, alias);
  }
}

class UserReadingPlan extends DataClass implements Insertable<UserReadingPlan> {
  final String id;
  final String localUserId;
  final String templateId;
  final String title;
  final String status;
  final DateTime subscribedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? archivedAt;
  final bool isActive;
  final String? lastOpenedSectionId;
  final String? lastOpenedBookKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final String? serverId;
  final DateTime? lastSyncedAt;
  final int clientRevision;
  const UserReadingPlan(
      {required this.id,
      required this.localUserId,
      required this.templateId,
      required this.title,
      required this.status,
      required this.subscribedAt,
      this.startedAt,
      this.completedAt,
      this.archivedAt,
      required this.isActive,
      this.lastOpenedSectionId,
      this.lastOpenedBookKey,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus,
      this.serverId,
      this.lastSyncedAt,
      required this.clientRevision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_user_id'] = Variable<String>(localUserId);
    map['template_id'] = Variable<String>(templateId);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    map['subscribed_at'] = Variable<DateTime>(subscribedAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastOpenedSectionId != null) {
      map['last_opened_section_id'] = Variable<String>(lastOpenedSectionId);
    }
    if (!nullToAbsent || lastOpenedBookKey != null) {
      map['last_opened_book_key'] = Variable<String>(lastOpenedBookKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['client_revision'] = Variable<int>(clientRevision);
    return map;
  }

  UserReadingPlansCompanion toCompanion(bool nullToAbsent) {
    return UserReadingPlansCompanion(
      id: Value(id),
      localUserId: Value(localUserId),
      templateId: Value(templateId),
      title: Value(title),
      status: Value(status),
      subscribedAt: Value(subscribedAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      isActive: Value(isActive),
      lastOpenedSectionId: lastOpenedSectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedSectionId),
      lastOpenedBookKey: lastOpenedBookKey == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedBookKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      clientRevision: Value(clientRevision),
    );
  }

  factory UserReadingPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserReadingPlan(
      id: serializer.fromJson<String>(json['id']),
      localUserId: serializer.fromJson<String>(json['localUserId']),
      templateId: serializer.fromJson<String>(json['templateId']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      subscribedAt: serializer.fromJson<DateTime>(json['subscribedAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastOpenedSectionId:
          serializer.fromJson<String?>(json['lastOpenedSectionId']),
      lastOpenedBookKey:
          serializer.fromJson<String?>(json['lastOpenedBookKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      clientRevision: serializer.fromJson<int>(json['clientRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localUserId': serializer.toJson<String>(localUserId),
      'templateId': serializer.toJson<String>(templateId),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'lastOpenedSectionId': serializer.toJson<String?>(lastOpenedSectionId),
      'lastOpenedBookKey': serializer.toJson<String?>(lastOpenedBookKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'clientRevision': serializer.toJson<int>(clientRevision),
    };
  }

  UserReadingPlan copyWith(
          {String? id,
          String? localUserId,
          String? templateId,
          String? title,
          String? status,
          DateTime? subscribedAt,
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> completedAt = const Value.absent(),
          Value<DateTime?> archivedAt = const Value.absent(),
          bool? isActive,
          Value<String?> lastOpenedSectionId = const Value.absent(),
          Value<String?> lastOpenedBookKey = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus,
          Value<String?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          int? clientRevision}) =>
      UserReadingPlan(
        id: id ?? this.id,
        localUserId: localUserId ?? this.localUserId,
        templateId: templateId ?? this.templateId,
        title: title ?? this.title,
        status: status ?? this.status,
        subscribedAt: subscribedAt ?? this.subscribedAt,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
        isActive: isActive ?? this.isActive,
        lastOpenedSectionId: lastOpenedSectionId.present
            ? lastOpenedSectionId.value
            : this.lastOpenedSectionId,
        lastOpenedBookKey: lastOpenedBookKey.present
            ? lastOpenedBookKey.value
            : this.lastOpenedBookKey,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        clientRevision: clientRevision ?? this.clientRevision,
      );
  UserReadingPlan copyWithCompanion(UserReadingPlansCompanion data) {
    return UserReadingPlan(
      id: data.id.present ? data.id.value : this.id,
      localUserId:
          data.localUserId.present ? data.localUserId.value : this.localUserId,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      archivedAt:
          data.archivedAt.present ? data.archivedAt.value : this.archivedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastOpenedSectionId: data.lastOpenedSectionId.present
          ? data.lastOpenedSectionId.value
          : this.lastOpenedSectionId,
      lastOpenedBookKey: data.lastOpenedBookKey.present
          ? data.lastOpenedBookKey.value
          : this.lastOpenedBookKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      clientRevision: data.clientRevision.present
          ? data.clientRevision.value
          : this.clientRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserReadingPlan(')
          ..write('id: $id, ')
          ..write('localUserId: $localUserId, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('isActive: $isActive, ')
          ..write('lastOpenedSectionId: $lastOpenedSectionId, ')
          ..write('lastOpenedBookKey: $lastOpenedBookKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      localUserId,
      templateId,
      title,
      status,
      subscribedAt,
      startedAt,
      completedAt,
      archivedAt,
      isActive,
      lastOpenedSectionId,
      lastOpenedBookKey,
      createdAt,
      updatedAt,
      syncStatus,
      serverId,
      lastSyncedAt,
      clientRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserReadingPlan &&
          other.id == this.id &&
          other.localUserId == this.localUserId &&
          other.templateId == this.templateId &&
          other.title == this.title &&
          other.status == this.status &&
          other.subscribedAt == this.subscribedAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.archivedAt == this.archivedAt &&
          other.isActive == this.isActive &&
          other.lastOpenedSectionId == this.lastOpenedSectionId &&
          other.lastOpenedBookKey == this.lastOpenedBookKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.clientRevision == this.clientRevision);
}

class UserReadingPlansCompanion extends UpdateCompanion<UserReadingPlan> {
  final Value<String> id;
  final Value<String> localUserId;
  final Value<String> templateId;
  final Value<String> title;
  final Value<String> status;
  final Value<DateTime> subscribedAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> archivedAt;
  final Value<bool> isActive;
  final Value<String?> lastOpenedSectionId;
  final Value<String?> lastOpenedBookKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> clientRevision;
  final Value<int> rowid;
  const UserReadingPlansCompanion({
    this.id = const Value.absent(),
    this.localUserId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastOpenedSectionId = const Value.absent(),
    this.lastOpenedBookKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserReadingPlansCompanion.insert({
    required String id,
    required String localUserId,
    required String templateId,
    required String title,
    this.status = const Value.absent(),
    required DateTime subscribedAt,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastOpenedSectionId = const Value.absent(),
    this.lastOpenedBookKey = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUserId = Value(localUserId),
        templateId = Value(templateId),
        title = Value(title),
        subscribedAt = Value(subscribedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserReadingPlan> custom({
    Expression<String>? id,
    Expression<String>? localUserId,
    Expression<String>? templateId,
    Expression<String>? title,
    Expression<String>? status,
    Expression<DateTime>? subscribedAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? archivedAt,
    Expression<bool>? isActive,
    Expression<String>? lastOpenedSectionId,
    Expression<String>? lastOpenedBookKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? clientRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localUserId != null) 'local_user_id': localUserId,
      if (templateId != null) 'template_id': templateId,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (isActive != null) 'is_active': isActive,
      if (lastOpenedSectionId != null)
        'last_opened_section_id': lastOpenedSectionId,
      if (lastOpenedBookKey != null) 'last_opened_book_key': lastOpenedBookKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (clientRevision != null) 'client_revision': clientRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserReadingPlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? localUserId,
      Value<String>? templateId,
      Value<String>? title,
      Value<String>? status,
      Value<DateTime>? subscribedAt,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? completedAt,
      Value<DateTime?>? archivedAt,
      Value<bool>? isActive,
      Value<String?>? lastOpenedSectionId,
      Value<String?>? lastOpenedBookKey,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<String?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? clientRevision,
      Value<int>? rowid}) {
    return UserReadingPlansCompanion(
      id: id ?? this.id,
      localUserId: localUserId ?? this.localUserId,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      status: status ?? this.status,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isActive: isActive ?? this.isActive,
      lastOpenedSectionId: lastOpenedSectionId ?? this.lastOpenedSectionId,
      lastOpenedBookKey: lastOpenedBookKey ?? this.lastOpenedBookKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      clientRevision: clientRevision ?? this.clientRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localUserId.present) {
      map['local_user_id'] = Variable<String>(localUserId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<DateTime>(subscribedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastOpenedSectionId.present) {
      map['last_opened_section_id'] =
          Variable<String>(lastOpenedSectionId.value);
    }
    if (lastOpenedBookKey.present) {
      map['last_opened_book_key'] = Variable<String>(lastOpenedBookKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (clientRevision.present) {
      map['client_revision'] = Variable<int>(clientRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserReadingPlansCompanion(')
          ..write('id: $id, ')
          ..write('localUserId: $localUserId, ')
          ..write('templateId: $templateId, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('isActive: $isActive, ')
          ..write('lastOpenedSectionId: $lastOpenedSectionId, ')
          ..write('lastOpenedBookKey: $lastOpenedBookKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPlanChaptersTable extends UserPlanChapters
    with TableInfo<$UserPlanChaptersTable, UserPlanChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPlanChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userPlanIdMeta =
      const VerificationMeta('userPlanId');
  @override
  late final GeneratedColumn<String> userPlanId = GeneratedColumn<String>(
      'user_plan_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sectionIdMeta =
      const VerificationMeta('sectionId');
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
      'section_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookKeyMeta =
      const VerificationMeta('bookKey');
  @override
  late final GeneratedColumn<String> bookKey = GeneratedColumn<String>(
      'book_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _clientRevisionMeta =
      const VerificationMeta('clientRevision');
  @override
  late final GeneratedColumn<int> clientRevision = GeneratedColumn<int>(
      'client_revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userPlanId,
        sectionId,
        bookKey,
        chapterNumber,
        orderIndex,
        createdAt,
        syncStatus,
        serverId,
        lastSyncedAt,
        clientRevision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_plan_chapters';
  @override
  VerificationContext validateIntegrity(Insertable<UserPlanChapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_plan_id')) {
      context.handle(
          _userPlanIdMeta,
          userPlanId.isAcceptableOrUnknown(
              data['user_plan_id']!, _userPlanIdMeta));
    } else if (isInserting) {
      context.missing(_userPlanIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(_sectionIdMeta,
          sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta));
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('book_key')) {
      context.handle(_bookKeyMeta,
          bookKey.isAcceptableOrUnknown(data['book_key']!, _bookKeyMeta));
    } else if (isInserting) {
      context.missing(_bookKeyMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('client_revision')) {
      context.handle(
          _clientRevisionMeta,
          clientRevision.isAcceptableOrUnknown(
              data['client_revision']!, _clientRevisionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {userPlanId, bookKey, chapterNumber},
      ];
  @override
  UserPlanChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlanChapter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_plan_id'])!,
      sectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_id'])!,
      bookKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_key'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      clientRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_revision'])!,
    );
  }

  @override
  $UserPlanChaptersTable createAlias(String alias) {
    return $UserPlanChaptersTable(attachedDatabase, alias);
  }
}

class UserPlanChapter extends DataClass implements Insertable<UserPlanChapter> {
  final String id;
  final String userPlanId;
  final String sectionId;
  final String bookKey;
  final int chapterNumber;
  final int orderIndex;
  final DateTime createdAt;
  final String syncStatus;
  final String? serverId;
  final DateTime? lastSyncedAt;
  final int clientRevision;
  const UserPlanChapter(
      {required this.id,
      required this.userPlanId,
      required this.sectionId,
      required this.bookKey,
      required this.chapterNumber,
      required this.orderIndex,
      required this.createdAt,
      required this.syncStatus,
      this.serverId,
      this.lastSyncedAt,
      required this.clientRevision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_plan_id'] = Variable<String>(userPlanId);
    map['section_id'] = Variable<String>(sectionId);
    map['book_key'] = Variable<String>(bookKey);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['client_revision'] = Variable<int>(clientRevision);
    return map;
  }

  UserPlanChaptersCompanion toCompanion(bool nullToAbsent) {
    return UserPlanChaptersCompanion(
      id: Value(id),
      userPlanId: Value(userPlanId),
      sectionId: Value(sectionId),
      bookKey: Value(bookKey),
      chapterNumber: Value(chapterNumber),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      clientRevision: Value(clientRevision),
    );
  }

  factory UserPlanChapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlanChapter(
      id: serializer.fromJson<String>(json['id']),
      userPlanId: serializer.fromJson<String>(json['userPlanId']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      clientRevision: serializer.fromJson<int>(json['clientRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userPlanId': serializer.toJson<String>(userPlanId),
      'sectionId': serializer.toJson<String>(sectionId),
      'bookKey': serializer.toJson<String>(bookKey),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'clientRevision': serializer.toJson<int>(clientRevision),
    };
  }

  UserPlanChapter copyWith(
          {String? id,
          String? userPlanId,
          String? sectionId,
          String? bookKey,
          int? chapterNumber,
          int? orderIndex,
          DateTime? createdAt,
          String? syncStatus,
          Value<String?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          int? clientRevision}) =>
      UserPlanChapter(
        id: id ?? this.id,
        userPlanId: userPlanId ?? this.userPlanId,
        sectionId: sectionId ?? this.sectionId,
        bookKey: bookKey ?? this.bookKey,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        orderIndex: orderIndex ?? this.orderIndex,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        clientRevision: clientRevision ?? this.clientRevision,
      );
  UserPlanChapter copyWithCompanion(UserPlanChaptersCompanion data) {
    return UserPlanChapter(
      id: data.id.present ? data.id.value : this.id,
      userPlanId:
          data.userPlanId.present ? data.userPlanId.value : this.userPlanId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      clientRevision: data.clientRevision.present
          ? data.clientRevision.value
          : this.clientRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPlanChapter(')
          ..write('id: $id, ')
          ..write('userPlanId: $userPlanId, ')
          ..write('sectionId: $sectionId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userPlanId,
      sectionId,
      bookKey,
      chapterNumber,
      orderIndex,
      createdAt,
      syncStatus,
      serverId,
      lastSyncedAt,
      clientRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlanChapter &&
          other.id == this.id &&
          other.userPlanId == this.userPlanId &&
          other.sectionId == this.sectionId &&
          other.bookKey == this.bookKey &&
          other.chapterNumber == this.chapterNumber &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.clientRevision == this.clientRevision);
}

class UserPlanChaptersCompanion extends UpdateCompanion<UserPlanChapter> {
  final Value<String> id;
  final Value<String> userPlanId;
  final Value<String> sectionId;
  final Value<String> bookKey;
  final Value<int> chapterNumber;
  final Value<int> orderIndex;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> clientRevision;
  final Value<int> rowid;
  const UserPlanChaptersCompanion({
    this.id = const Value.absent(),
    this.userPlanId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPlanChaptersCompanion.insert({
    required String id,
    required String userPlanId,
    required String sectionId,
    required String bookKey,
    required int chapterNumber,
    required int orderIndex,
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userPlanId = Value(userPlanId),
        sectionId = Value(sectionId),
        bookKey = Value(bookKey),
        chapterNumber = Value(chapterNumber),
        orderIndex = Value(orderIndex),
        createdAt = Value(createdAt);
  static Insertable<UserPlanChapter> custom({
    Expression<String>? id,
    Expression<String>? userPlanId,
    Expression<String>? sectionId,
    Expression<String>? bookKey,
    Expression<int>? chapterNumber,
    Expression<int>? orderIndex,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? clientRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userPlanId != null) 'user_plan_id': userPlanId,
      if (sectionId != null) 'section_id': sectionId,
      if (bookKey != null) 'book_key': bookKey,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (clientRevision != null) 'client_revision': clientRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPlanChaptersCompanion copyWith(
      {Value<String>? id,
      Value<String>? userPlanId,
      Value<String>? sectionId,
      Value<String>? bookKey,
      Value<int>? chapterNumber,
      Value<int>? orderIndex,
      Value<DateTime>? createdAt,
      Value<String>? syncStatus,
      Value<String?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? clientRevision,
      Value<int>? rowid}) {
    return UserPlanChaptersCompanion(
      id: id ?? this.id,
      userPlanId: userPlanId ?? this.userPlanId,
      sectionId: sectionId ?? this.sectionId,
      bookKey: bookKey ?? this.bookKey,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      clientRevision: clientRevision ?? this.clientRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userPlanId.present) {
      map['user_plan_id'] = Variable<String>(userPlanId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (bookKey.present) {
      map['book_key'] = Variable<String>(bookKey.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (clientRevision.present) {
      map['client_revision'] = Variable<int>(clientRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPlanChaptersCompanion(')
          ..write('id: $id, ')
          ..write('userPlanId: $userPlanId, ')
          ..write('sectionId: $sectionId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanCompletionEventsTable extends PlanCompletionEvents
    with TableInfo<$PlanCompletionEventsTable, PlanCompletionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanCompletionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localUserIdMeta =
      const VerificationMeta('localUserId');
  @override
  late final GeneratedColumn<String> localUserId = GeneratedColumn<String>(
      'local_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userPlanIdMeta =
      const VerificationMeta('userPlanId');
  @override
  late final GeneratedColumn<String> userPlanId = GeneratedColumn<String>(
      'user_plan_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _completionNumberMeta =
      const VerificationMeta('completionNumber');
  @override
  late final GeneratedColumn<int> completionNumber = GeneratedColumn<int>(
      'completion_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _clientRevisionMeta =
      const VerificationMeta('clientRevision');
  @override
  late final GeneratedColumn<int> clientRevision = GeneratedColumn<int>(
      'client_revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        localUserId,
        userPlanId,
        templateId,
        completionNumber,
        completedAt,
        createdAt,
        syncStatus,
        serverId,
        lastSyncedAt,
        clientRevision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_completion_events';
  @override
  VerificationContext validateIntegrity(
      Insertable<PlanCompletionEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_user_id')) {
      context.handle(
          _localUserIdMeta,
          localUserId.isAcceptableOrUnknown(
              data['local_user_id']!, _localUserIdMeta));
    } else if (isInserting) {
      context.missing(_localUserIdMeta);
    }
    if (data.containsKey('user_plan_id')) {
      context.handle(
          _userPlanIdMeta,
          userPlanId.isAcceptableOrUnknown(
              data['user_plan_id']!, _userPlanIdMeta));
    } else if (isInserting) {
      context.missing(_userPlanIdMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('completion_number')) {
      context.handle(
          _completionNumberMeta,
          completionNumber.isAcceptableOrUnknown(
              data['completion_number']!, _completionNumberMeta));
    } else if (isInserting) {
      context.missing(_completionNumberMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('client_revision')) {
      context.handle(
          _clientRevisionMeta,
          clientRevision.isAcceptableOrUnknown(
              data['client_revision']!, _clientRevisionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {userPlanId},
      ];
  @override
  PlanCompletionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanCompletionEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      localUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_user_id'])!,
      userPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_plan_id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      completionNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completion_number'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      clientRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_revision'])!,
    );
  }

  @override
  $PlanCompletionEventsTable createAlias(String alias) {
    return $PlanCompletionEventsTable(attachedDatabase, alias);
  }
}

class PlanCompletionEvent extends DataClass
    implements Insertable<PlanCompletionEvent> {
  final String id;
  final String localUserId;
  final String userPlanId;
  final String templateId;
  final int completionNumber;
  final DateTime completedAt;
  final DateTime createdAt;
  final String syncStatus;
  final String? serverId;
  final DateTime? lastSyncedAt;
  final int clientRevision;
  const PlanCompletionEvent(
      {required this.id,
      required this.localUserId,
      required this.userPlanId,
      required this.templateId,
      required this.completionNumber,
      required this.completedAt,
      required this.createdAt,
      required this.syncStatus,
      this.serverId,
      this.lastSyncedAt,
      required this.clientRevision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_user_id'] = Variable<String>(localUserId);
    map['user_plan_id'] = Variable<String>(userPlanId);
    map['template_id'] = Variable<String>(templateId);
    map['completion_number'] = Variable<int>(completionNumber);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['client_revision'] = Variable<int>(clientRevision);
    return map;
  }

  PlanCompletionEventsCompanion toCompanion(bool nullToAbsent) {
    return PlanCompletionEventsCompanion(
      id: Value(id),
      localUserId: Value(localUserId),
      userPlanId: Value(userPlanId),
      templateId: Value(templateId),
      completionNumber: Value(completionNumber),
      completedAt: Value(completedAt),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      clientRevision: Value(clientRevision),
    );
  }

  factory PlanCompletionEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanCompletionEvent(
      id: serializer.fromJson<String>(json['id']),
      localUserId: serializer.fromJson<String>(json['localUserId']),
      userPlanId: serializer.fromJson<String>(json['userPlanId']),
      templateId: serializer.fromJson<String>(json['templateId']),
      completionNumber: serializer.fromJson<int>(json['completionNumber']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      clientRevision: serializer.fromJson<int>(json['clientRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localUserId': serializer.toJson<String>(localUserId),
      'userPlanId': serializer.toJson<String>(userPlanId),
      'templateId': serializer.toJson<String>(templateId),
      'completionNumber': serializer.toJson<int>(completionNumber),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'clientRevision': serializer.toJson<int>(clientRevision),
    };
  }

  PlanCompletionEvent copyWith(
          {String? id,
          String? localUserId,
          String? userPlanId,
          String? templateId,
          int? completionNumber,
          DateTime? completedAt,
          DateTime? createdAt,
          String? syncStatus,
          Value<String?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          int? clientRevision}) =>
      PlanCompletionEvent(
        id: id ?? this.id,
        localUserId: localUserId ?? this.localUserId,
        userPlanId: userPlanId ?? this.userPlanId,
        templateId: templateId ?? this.templateId,
        completionNumber: completionNumber ?? this.completionNumber,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        clientRevision: clientRevision ?? this.clientRevision,
      );
  PlanCompletionEvent copyWithCompanion(PlanCompletionEventsCompanion data) {
    return PlanCompletionEvent(
      id: data.id.present ? data.id.value : this.id,
      localUserId:
          data.localUserId.present ? data.localUserId.value : this.localUserId,
      userPlanId:
          data.userPlanId.present ? data.userPlanId.value : this.userPlanId,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      completionNumber: data.completionNumber.present
          ? data.completionNumber.value
          : this.completionNumber,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      clientRevision: data.clientRevision.present
          ? data.clientRevision.value
          : this.clientRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanCompletionEvent(')
          ..write('id: $id, ')
          ..write('localUserId: $localUserId, ')
          ..write('userPlanId: $userPlanId, ')
          ..write('templateId: $templateId, ')
          ..write('completionNumber: $completionNumber, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      localUserId,
      userPlanId,
      templateId,
      completionNumber,
      completedAt,
      createdAt,
      syncStatus,
      serverId,
      lastSyncedAt,
      clientRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanCompletionEvent &&
          other.id == this.id &&
          other.localUserId == this.localUserId &&
          other.userPlanId == this.userPlanId &&
          other.templateId == this.templateId &&
          other.completionNumber == this.completionNumber &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.clientRevision == this.clientRevision);
}

class PlanCompletionEventsCompanion
    extends UpdateCompanion<PlanCompletionEvent> {
  final Value<String> id;
  final Value<String> localUserId;
  final Value<String> userPlanId;
  final Value<String> templateId;
  final Value<int> completionNumber;
  final Value<DateTime> completedAt;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> clientRevision;
  final Value<int> rowid;
  const PlanCompletionEventsCompanion({
    this.id = const Value.absent(),
    this.localUserId = const Value.absent(),
    this.userPlanId = const Value.absent(),
    this.templateId = const Value.absent(),
    this.completionNumber = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanCompletionEventsCompanion.insert({
    required String id,
    required String localUserId,
    required String userPlanId,
    required String templateId,
    required int completionNumber,
    required DateTime completedAt,
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUserId = Value(localUserId),
        userPlanId = Value(userPlanId),
        templateId = Value(templateId),
        completionNumber = Value(completionNumber),
        completedAt = Value(completedAt),
        createdAt = Value(createdAt);
  static Insertable<PlanCompletionEvent> custom({
    Expression<String>? id,
    Expression<String>? localUserId,
    Expression<String>? userPlanId,
    Expression<String>? templateId,
    Expression<int>? completionNumber,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? clientRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localUserId != null) 'local_user_id': localUserId,
      if (userPlanId != null) 'user_plan_id': userPlanId,
      if (templateId != null) 'template_id': templateId,
      if (completionNumber != null) 'completion_number': completionNumber,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (clientRevision != null) 'client_revision': clientRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanCompletionEventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? localUserId,
      Value<String>? userPlanId,
      Value<String>? templateId,
      Value<int>? completionNumber,
      Value<DateTime>? completedAt,
      Value<DateTime>? createdAt,
      Value<String>? syncStatus,
      Value<String?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? clientRevision,
      Value<int>? rowid}) {
    return PlanCompletionEventsCompanion(
      id: id ?? this.id,
      localUserId: localUserId ?? this.localUserId,
      userPlanId: userPlanId ?? this.userPlanId,
      templateId: templateId ?? this.templateId,
      completionNumber: completionNumber ?? this.completionNumber,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      clientRevision: clientRevision ?? this.clientRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localUserId.present) {
      map['local_user_id'] = Variable<String>(localUserId.value);
    }
    if (userPlanId.present) {
      map['user_plan_id'] = Variable<String>(userPlanId.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (completionNumber.present) {
      map['completion_number'] = Variable<int>(completionNumber.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (clientRevision.present) {
      map['client_revision'] = Variable<int>(clientRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanCompletionEventsCompanion(')
          ..write('id: $id, ')
          ..write('localUserId: $localUserId, ')
          ..write('userPlanId: $userPlanId, ')
          ..write('templateId: $templateId, ')
          ..write('completionNumber: $completionNumber, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChapterProgressEntriesTable extends ChapterProgressEntries
    with TableInfo<$ChapterProgressEntriesTable, ChapterProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChapterProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localUserIdMeta =
      const VerificationMeta('localUserId');
  @override
  late final GeneratedColumn<String> localUserId = GeneratedColumn<String>(
      'local_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userPlanIdMeta =
      const VerificationMeta('userPlanId');
  @override
  late final GeneratedColumn<String> userPlanId = GeneratedColumn<String>(
      'user_plan_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookKeyMeta =
      const VerificationMeta('bookKey');
  @override
  late final GeneratedColumn<String> bookKey = GeneratedColumn<String>(
      'book_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _clientRevisionMeta =
      const VerificationMeta('clientRevision');
  @override
  late final GeneratedColumn<int> clientRevision = GeneratedColumn<int>(
      'client_revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        localUserId,
        userPlanId,
        bookKey,
        chapterNumber,
        isCompleted,
        completedAt,
        updatedAt,
        syncStatus,
        serverId,
        lastSyncedAt,
        clientRevision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapter_progress_entries';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChapterProgressEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_user_id')) {
      context.handle(
          _localUserIdMeta,
          localUserId.isAcceptableOrUnknown(
              data['local_user_id']!, _localUserIdMeta));
    } else if (isInserting) {
      context.missing(_localUserIdMeta);
    }
    if (data.containsKey('user_plan_id')) {
      context.handle(
          _userPlanIdMeta,
          userPlanId.isAcceptableOrUnknown(
              data['user_plan_id']!, _userPlanIdMeta));
    } else if (isInserting) {
      context.missing(_userPlanIdMeta);
    }
    if (data.containsKey('book_key')) {
      context.handle(_bookKeyMeta,
          bookKey.isAcceptableOrUnknown(data['book_key']!, _bookKeyMeta));
    } else if (isInserting) {
      context.missing(_bookKeyMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('client_revision')) {
      context.handle(
          _clientRevisionMeta,
          clientRevision.isAcceptableOrUnknown(
              data['client_revision']!, _clientRevisionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {localUserId, userPlanId, bookKey, chapterNumber},
      ];
  @override
  ChapterProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterProgressEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      localUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_user_id'])!,
      userPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_plan_id'])!,
      bookKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_key'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number'])!,
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      clientRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_revision'])!,
    );
  }

  @override
  $ChapterProgressEntriesTable createAlias(String alias) {
    return $ChapterProgressEntriesTable(attachedDatabase, alias);
  }
}

class ChapterProgressEntry extends DataClass
    implements Insertable<ChapterProgressEntry> {
  final String id;
  final String localUserId;
  final String userPlanId;
  final String bookKey;
  final int chapterNumber;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final String syncStatus;
  final String? serverId;
  final DateTime? lastSyncedAt;
  final int clientRevision;
  const ChapterProgressEntry(
      {required this.id,
      required this.localUserId,
      required this.userPlanId,
      required this.bookKey,
      required this.chapterNumber,
      required this.isCompleted,
      this.completedAt,
      required this.updatedAt,
      required this.syncStatus,
      this.serverId,
      this.lastSyncedAt,
      required this.clientRevision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_user_id'] = Variable<String>(localUserId);
    map['user_plan_id'] = Variable<String>(userPlanId);
    map['book_key'] = Variable<String>(bookKey);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['client_revision'] = Variable<int>(clientRevision);
    return map;
  }

  ChapterProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChapterProgressEntriesCompanion(
      id: Value(id),
      localUserId: Value(localUserId),
      userPlanId: Value(userPlanId),
      bookKey: Value(bookKey),
      chapterNumber: Value(chapterNumber),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      clientRevision: Value(clientRevision),
    );
  }

  factory ChapterProgressEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterProgressEntry(
      id: serializer.fromJson<String>(json['id']),
      localUserId: serializer.fromJson<String>(json['localUserId']),
      userPlanId: serializer.fromJson<String>(json['userPlanId']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      clientRevision: serializer.fromJson<int>(json['clientRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localUserId': serializer.toJson<String>(localUserId),
      'userPlanId': serializer.toJson<String>(userPlanId),
      'bookKey': serializer.toJson<String>(bookKey),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'clientRevision': serializer.toJson<int>(clientRevision),
    };
  }

  ChapterProgressEntry copyWith(
          {String? id,
          String? localUserId,
          String? userPlanId,
          String? bookKey,
          int? chapterNumber,
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? updatedAt,
          String? syncStatus,
          Value<String?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          int? clientRevision}) =>
      ChapterProgressEntry(
        id: id ?? this.id,
        localUserId: localUserId ?? this.localUserId,
        userPlanId: userPlanId ?? this.userPlanId,
        bookKey: bookKey ?? this.bookKey,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        clientRevision: clientRevision ?? this.clientRevision,
      );
  ChapterProgressEntry copyWithCompanion(ChapterProgressEntriesCompanion data) {
    return ChapterProgressEntry(
      id: data.id.present ? data.id.value : this.id,
      localUserId:
          data.localUserId.present ? data.localUserId.value : this.localUserId,
      userPlanId:
          data.userPlanId.present ? data.userPlanId.value : this.userPlanId,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      clientRevision: data.clientRevision.present
          ? data.clientRevision.value
          : this.clientRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressEntry(')
          ..write('id: $id, ')
          ..write('localUserId: $localUserId, ')
          ..write('userPlanId: $userPlanId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      localUserId,
      userPlanId,
      bookKey,
      chapterNumber,
      isCompleted,
      completedAt,
      updatedAt,
      syncStatus,
      serverId,
      lastSyncedAt,
      clientRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterProgressEntry &&
          other.id == this.id &&
          other.localUserId == this.localUserId &&
          other.userPlanId == this.userPlanId &&
          other.bookKey == this.bookKey &&
          other.chapterNumber == this.chapterNumber &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.clientRevision == this.clientRevision);
}

class ChapterProgressEntriesCompanion
    extends UpdateCompanion<ChapterProgressEntry> {
  final Value<String> id;
  final Value<String> localUserId;
  final Value<String> userPlanId;
  final Value<String> bookKey;
  final Value<int> chapterNumber;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> clientRevision;
  final Value<int> rowid;
  const ChapterProgressEntriesCompanion({
    this.id = const Value.absent(),
    this.localUserId = const Value.absent(),
    this.userPlanId = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterProgressEntriesCompanion.insert({
    required String id,
    required String localUserId,
    required String userPlanId,
    required String bookKey,
    required int chapterNumber,
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUserId = Value(localUserId),
        userPlanId = Value(userPlanId),
        bookKey = Value(bookKey),
        chapterNumber = Value(chapterNumber),
        updatedAt = Value(updatedAt);
  static Insertable<ChapterProgressEntry> custom({
    Expression<String>? id,
    Expression<String>? localUserId,
    Expression<String>? userPlanId,
    Expression<String>? bookKey,
    Expression<int>? chapterNumber,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? clientRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localUserId != null) 'local_user_id': localUserId,
      if (userPlanId != null) 'user_plan_id': userPlanId,
      if (bookKey != null) 'book_key': bookKey,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (clientRevision != null) 'client_revision': clientRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterProgressEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? localUserId,
      Value<String>? userPlanId,
      Value<String>? bookKey,
      Value<int>? chapterNumber,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<String?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? clientRevision,
      Value<int>? rowid}) {
    return ChapterProgressEntriesCompanion(
      id: id ?? this.id,
      localUserId: localUserId ?? this.localUserId,
      userPlanId: userPlanId ?? this.userPlanId,
      bookKey: bookKey ?? this.bookKey,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      clientRevision: clientRevision ?? this.clientRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localUserId.present) {
      map['local_user_id'] = Variable<String>(localUserId.value);
    }
    if (userPlanId.present) {
      map['user_plan_id'] = Variable<String>(userPlanId.value);
    }
    if (bookKey.present) {
      map['book_key'] = Variable<String>(bookKey.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (clientRevision.present) {
      map['client_revision'] = Variable<int>(clientRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressEntriesCompanion(')
          ..write('id: $id, ')
          ..write('localUserId: $localUserId, ')
          ..write('userPlanId: $userPlanId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingActivitiesTable extends ReadingActivities
    with TableInfo<$ReadingActivitiesTable, ReadingActivity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localUserIdMeta =
      const VerificationMeta('localUserId');
  @override
  late final GeneratedColumn<String> localUserId = GeneratedColumn<String>(
      'local_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userPlanIdMeta =
      const VerificationMeta('userPlanId');
  @override
  late final GeneratedColumn<String> userPlanId = GeneratedColumn<String>(
      'user_plan_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookKeyMeta =
      const VerificationMeta('bookKey');
  @override
  late final GeneratedColumn<String> bookKey = GeneratedColumn<String>(
      'book_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterNumberMeta =
      const VerificationMeta('chapterNumber');
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
      'chapter_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activityDateMeta =
      const VerificationMeta('activityDate');
  @override
  late final GeneratedColumn<String> activityDate = GeneratedColumn<String>(
      'activity_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timezoneMeta =
      const VerificationMeta('timezone');
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
      'timezone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _happenedAtMeta =
      const VerificationMeta('happenedAt');
  @override
  late final GeneratedColumn<DateTime> happenedAt = GeneratedColumn<DateTime>(
      'happened_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
      'server_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _clientRevisionMeta =
      const VerificationMeta('clientRevision');
  @override
  late final GeneratedColumn<int> clientRevision = GeneratedColumn<int>(
      'client_revision', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        localUserId,
        userPlanId,
        bookKey,
        chapterNumber,
        action,
        activityDate,
        timezone,
        happenedAt,
        createdAt,
        syncStatus,
        serverId,
        lastSyncedAt,
        clientRevision
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_activities';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingActivity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_user_id')) {
      context.handle(
          _localUserIdMeta,
          localUserId.isAcceptableOrUnknown(
              data['local_user_id']!, _localUserIdMeta));
    } else if (isInserting) {
      context.missing(_localUserIdMeta);
    }
    if (data.containsKey('user_plan_id')) {
      context.handle(
          _userPlanIdMeta,
          userPlanId.isAcceptableOrUnknown(
              data['user_plan_id']!, _userPlanIdMeta));
    } else if (isInserting) {
      context.missing(_userPlanIdMeta);
    }
    if (data.containsKey('book_key')) {
      context.handle(_bookKeyMeta,
          bookKey.isAcceptableOrUnknown(data['book_key']!, _bookKeyMeta));
    } else if (isInserting) {
      context.missing(_bookKeyMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
          _chapterNumberMeta,
          chapterNumber.isAcceptableOrUnknown(
              data['chapter_number']!, _chapterNumberMeta));
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('activity_date')) {
      context.handle(
          _activityDateMeta,
          activityDate.isAcceptableOrUnknown(
              data['activity_date']!, _activityDateMeta));
    } else if (isInserting) {
      context.missing(_activityDateMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(_timezoneMeta,
          timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta));
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('happened_at')) {
      context.handle(
          _happenedAtMeta,
          happenedAt.isAcceptableOrUnknown(
              data['happened_at']!, _happenedAtMeta));
    } else if (isInserting) {
      context.missing(_happenedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    if (data.containsKey('client_revision')) {
      context.handle(
          _clientRevisionMeta,
          clientRevision.isAcceptableOrUnknown(
              data['client_revision']!, _clientRevisionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {localUserId, userPlanId, bookKey, chapterNumber, activityDate, action},
      ];
  @override
  ReadingActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingActivity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      localUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_user_id'])!,
      userPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_plan_id'])!,
      bookKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_key'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      activityDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}activity_date'])!,
      timezone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timezone'])!,
      happenedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}happened_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}server_id']),
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
      clientRevision: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}client_revision'])!,
    );
  }

  @override
  $ReadingActivitiesTable createAlias(String alias) {
    return $ReadingActivitiesTable(attachedDatabase, alias);
  }
}

class ReadingActivity extends DataClass implements Insertable<ReadingActivity> {
  final String id;
  final String localUserId;
  final String userPlanId;
  final String bookKey;
  final int chapterNumber;
  final String action;
  final String activityDate;
  final String timezone;
  final DateTime happenedAt;
  final DateTime createdAt;
  final String syncStatus;
  final String? serverId;
  final DateTime? lastSyncedAt;
  final int clientRevision;
  const ReadingActivity(
      {required this.id,
      required this.localUserId,
      required this.userPlanId,
      required this.bookKey,
      required this.chapterNumber,
      required this.action,
      required this.activityDate,
      required this.timezone,
      required this.happenedAt,
      required this.createdAt,
      required this.syncStatus,
      this.serverId,
      this.lastSyncedAt,
      required this.clientRevision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_user_id'] = Variable<String>(localUserId);
    map['user_plan_id'] = Variable<String>(userPlanId);
    map['book_key'] = Variable<String>(bookKey);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['action'] = Variable<String>(action);
    map['activity_date'] = Variable<String>(activityDate);
    map['timezone'] = Variable<String>(timezone);
    map['happened_at'] = Variable<DateTime>(happenedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    map['client_revision'] = Variable<int>(clientRevision);
    return map;
  }

  ReadingActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ReadingActivitiesCompanion(
      id: Value(id),
      localUserId: Value(localUserId),
      userPlanId: Value(userPlanId),
      bookKey: Value(bookKey),
      chapterNumber: Value(chapterNumber),
      action: Value(action),
      activityDate: Value(activityDate),
      timezone: Value(timezone),
      happenedAt: Value(happenedAt),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      clientRevision: Value(clientRevision),
    );
  }

  factory ReadingActivity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingActivity(
      id: serializer.fromJson<String>(json['id']),
      localUserId: serializer.fromJson<String>(json['localUserId']),
      userPlanId: serializer.fromJson<String>(json['userPlanId']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      action: serializer.fromJson<String>(json['action']),
      activityDate: serializer.fromJson<String>(json['activityDate']),
      timezone: serializer.fromJson<String>(json['timezone']),
      happenedAt: serializer.fromJson<DateTime>(json['happenedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      clientRevision: serializer.fromJson<int>(json['clientRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'localUserId': serializer.toJson<String>(localUserId),
      'userPlanId': serializer.toJson<String>(userPlanId),
      'bookKey': serializer.toJson<String>(bookKey),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'action': serializer.toJson<String>(action),
      'activityDate': serializer.toJson<String>(activityDate),
      'timezone': serializer.toJson<String>(timezone),
      'happenedAt': serializer.toJson<DateTime>(happenedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'serverId': serializer.toJson<String?>(serverId),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'clientRevision': serializer.toJson<int>(clientRevision),
    };
  }

  ReadingActivity copyWith(
          {String? id,
          String? localUserId,
          String? userPlanId,
          String? bookKey,
          int? chapterNumber,
          String? action,
          String? activityDate,
          String? timezone,
          DateTime? happenedAt,
          DateTime? createdAt,
          String? syncStatus,
          Value<String?> serverId = const Value.absent(),
          Value<DateTime?> lastSyncedAt = const Value.absent(),
          int? clientRevision}) =>
      ReadingActivity(
        id: id ?? this.id,
        localUserId: localUserId ?? this.localUserId,
        userPlanId: userPlanId ?? this.userPlanId,
        bookKey: bookKey ?? this.bookKey,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        action: action ?? this.action,
        activityDate: activityDate ?? this.activityDate,
        timezone: timezone ?? this.timezone,
        happenedAt: happenedAt ?? this.happenedAt,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
        serverId: serverId.present ? serverId.value : this.serverId,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
        clientRevision: clientRevision ?? this.clientRevision,
      );
  ReadingActivity copyWithCompanion(ReadingActivitiesCompanion data) {
    return ReadingActivity(
      id: data.id.present ? data.id.value : this.id,
      localUserId:
          data.localUserId.present ? data.localUserId.value : this.localUserId,
      userPlanId:
          data.userPlanId.present ? data.userPlanId.value : this.userPlanId,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      action: data.action.present ? data.action.value : this.action,
      activityDate: data.activityDate.present
          ? data.activityDate.value
          : this.activityDate,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      happenedAt:
          data.happenedAt.present ? data.happenedAt.value : this.happenedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      clientRevision: data.clientRevision.present
          ? data.clientRevision.value
          : this.clientRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingActivity(')
          ..write('id: $id, ')
          ..write('localUserId: $localUserId, ')
          ..write('userPlanId: $userPlanId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('action: $action, ')
          ..write('activityDate: $activityDate, ')
          ..write('timezone: $timezone, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      localUserId,
      userPlanId,
      bookKey,
      chapterNumber,
      action,
      activityDate,
      timezone,
      happenedAt,
      createdAt,
      syncStatus,
      serverId,
      lastSyncedAt,
      clientRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingActivity &&
          other.id == this.id &&
          other.localUserId == this.localUserId &&
          other.userPlanId == this.userPlanId &&
          other.bookKey == this.bookKey &&
          other.chapterNumber == this.chapterNumber &&
          other.action == this.action &&
          other.activityDate == this.activityDate &&
          other.timezone == this.timezone &&
          other.happenedAt == this.happenedAt &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus &&
          other.serverId == this.serverId &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.clientRevision == this.clientRevision);
}

class ReadingActivitiesCompanion extends UpdateCompanion<ReadingActivity> {
  final Value<String> id;
  final Value<String> localUserId;
  final Value<String> userPlanId;
  final Value<String> bookKey;
  final Value<int> chapterNumber;
  final Value<String> action;
  final Value<String> activityDate;
  final Value<String> timezone;
  final Value<DateTime> happenedAt;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<String?> serverId;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> clientRevision;
  final Value<int> rowid;
  const ReadingActivitiesCompanion({
    this.id = const Value.absent(),
    this.localUserId = const Value.absent(),
    this.userPlanId = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.action = const Value.absent(),
    this.activityDate = const Value.absent(),
    this.timezone = const Value.absent(),
    this.happenedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingActivitiesCompanion.insert({
    required String id,
    required String localUserId,
    required String userPlanId,
    required String bookKey,
    required int chapterNumber,
    required String action,
    required String activityDate,
    required String timezone,
    required DateTime happenedAt,
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.serverId = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.clientRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        localUserId = Value(localUserId),
        userPlanId = Value(userPlanId),
        bookKey = Value(bookKey),
        chapterNumber = Value(chapterNumber),
        action = Value(action),
        activityDate = Value(activityDate),
        timezone = Value(timezone),
        happenedAt = Value(happenedAt),
        createdAt = Value(createdAt);
  static Insertable<ReadingActivity> custom({
    Expression<String>? id,
    Expression<String>? localUserId,
    Expression<String>? userPlanId,
    Expression<String>? bookKey,
    Expression<int>? chapterNumber,
    Expression<String>? action,
    Expression<String>? activityDate,
    Expression<String>? timezone,
    Expression<DateTime>? happenedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<String>? serverId,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? clientRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localUserId != null) 'local_user_id': localUserId,
      if (userPlanId != null) 'user_plan_id': userPlanId,
      if (bookKey != null) 'book_key': bookKey,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (action != null) 'action': action,
      if (activityDate != null) 'activity_date': activityDate,
      if (timezone != null) 'timezone': timezone,
      if (happenedAt != null) 'happened_at': happenedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (serverId != null) 'server_id': serverId,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (clientRevision != null) 'client_revision': clientRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingActivitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? localUserId,
      Value<String>? userPlanId,
      Value<String>? bookKey,
      Value<int>? chapterNumber,
      Value<String>? action,
      Value<String>? activityDate,
      Value<String>? timezone,
      Value<DateTime>? happenedAt,
      Value<DateTime>? createdAt,
      Value<String>? syncStatus,
      Value<String?>? serverId,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? clientRevision,
      Value<int>? rowid}) {
    return ReadingActivitiesCompanion(
      id: id ?? this.id,
      localUserId: localUserId ?? this.localUserId,
      userPlanId: userPlanId ?? this.userPlanId,
      bookKey: bookKey ?? this.bookKey,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      action: action ?? this.action,
      activityDate: activityDate ?? this.activityDate,
      timezone: timezone ?? this.timezone,
      happenedAt: happenedAt ?? this.happenedAt,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      clientRevision: clientRevision ?? this.clientRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (localUserId.present) {
      map['local_user_id'] = Variable<String>(localUserId.value);
    }
    if (userPlanId.present) {
      map['user_plan_id'] = Variable<String>(userPlanId.value);
    }
    if (bookKey.present) {
      map['book_key'] = Variable<String>(bookKey.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (activityDate.present) {
      map['activity_date'] = Variable<String>(activityDate.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (happenedAt.present) {
      map['happened_at'] = Variable<DateTime>(happenedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (clientRevision.present) {
      map['client_revision'] = Variable<int>(clientRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('localUserId: $localUserId, ')
          ..write('userPlanId: $userPlanId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('action: $action, ')
          ..write('activityDate: $activityDate, ')
          ..write('timezone: $timezone, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('serverId: $serverId, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('clientRevision: $clientRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting(
      {required this.key, required this.value, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value),
        updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BibleBooksTable bibleBooks = $BibleBooksTable(this);
  late final $BibleChaptersTable bibleChapters = $BibleChaptersTable(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $PlanTemplatesTable planTemplates = $PlanTemplatesTable(this);
  late final $PlanTemplateSectionsTable planTemplateSections =
      $PlanTemplateSectionsTable(this);
  late final $PlanTemplateItemsTable planTemplateItems =
      $PlanTemplateItemsTable(this);
  late final $PlanTagsTable planTags = $PlanTagsTable(this);
  late final $PlanTemplateTagsTable planTemplateTags =
      $PlanTemplateTagsTable(this);
  late final $UserReadingPlansTable userReadingPlans =
      $UserReadingPlansTable(this);
  late final $UserPlanChaptersTable userPlanChapters =
      $UserPlanChaptersTable(this);
  late final $PlanCompletionEventsTable planCompletionEvents =
      $PlanCompletionEventsTable(this);
  late final $ChapterProgressEntriesTable chapterProgressEntries =
      $ChapterProgressEntriesTable(this);
  late final $ReadingActivitiesTable readingActivities =
      $ReadingActivitiesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        bibleBooks,
        bibleChapters,
        localUsers,
        planTemplates,
        planTemplateSections,
        planTemplateItems,
        planTags,
        planTemplateTags,
        userReadingPlans,
        userPlanChapters,
        planCompletionEvents,
        chapterProgressEntries,
        readingActivities,
        appSettings
      ];
}

typedef $$BibleBooksTableCreateCompanionBuilder = BibleBooksCompanion Function({
  Value<int> id,
  required String bookKey,
  required String testament,
  required int bookOrder,
  required String shortName,
  required String displayNameEn,
  Value<String?> displayNameKo,
  required int chapterCount,
});
typedef $$BibleBooksTableUpdateCompanionBuilder = BibleBooksCompanion Function({
  Value<int> id,
  Value<String> bookKey,
  Value<String> testament,
  Value<int> bookOrder,
  Value<String> shortName,
  Value<String> displayNameEn,
  Value<String?> displayNameKo,
  Value<int> chapterCount,
});

class $$BibleBooksTableFilterComposer
    extends Composer<_$AppDatabase, $BibleBooksTable> {
  $$BibleBooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get testament => $composableBuilder(
      column: $table.testament, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bookOrder => $composableBuilder(
      column: $table.bookOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayNameEn => $composableBuilder(
      column: $table.displayNameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayNameKo => $composableBuilder(
      column: $table.displayNameKo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterCount => $composableBuilder(
      column: $table.chapterCount, builder: (column) => ColumnFilters(column));
}

class $$BibleBooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BibleBooksTable> {
  $$BibleBooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get testament => $composableBuilder(
      column: $table.testament, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bookOrder => $composableBuilder(
      column: $table.bookOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayNameEn => $composableBuilder(
      column: $table.displayNameEn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayNameKo => $composableBuilder(
      column: $table.displayNameKo,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterCount => $composableBuilder(
      column: $table.chapterCount,
      builder: (column) => ColumnOrderings(column));
}

class $$BibleBooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BibleBooksTable> {
  $$BibleBooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<String> get testament =>
      $composableBuilder(column: $table.testament, builder: (column) => column);

  GeneratedColumn<int> get bookOrder =>
      $composableBuilder(column: $table.bookOrder, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<String> get displayNameEn => $composableBuilder(
      column: $table.displayNameEn, builder: (column) => column);

  GeneratedColumn<String> get displayNameKo => $composableBuilder(
      column: $table.displayNameKo, builder: (column) => column);

  GeneratedColumn<int> get chapterCount => $composableBuilder(
      column: $table.chapterCount, builder: (column) => column);
}

class $$BibleBooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BibleBooksTable,
    BibleBook,
    $$BibleBooksTableFilterComposer,
    $$BibleBooksTableOrderingComposer,
    $$BibleBooksTableAnnotationComposer,
    $$BibleBooksTableCreateCompanionBuilder,
    $$BibleBooksTableUpdateCompanionBuilder,
    (BibleBook, BaseReferences<_$AppDatabase, $BibleBooksTable, BibleBook>),
    BibleBook,
    PrefetchHooks Function()> {
  $$BibleBooksTableTableManager(_$AppDatabase db, $BibleBooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BibleBooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BibleBooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BibleBooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<String> testament = const Value.absent(),
            Value<int> bookOrder = const Value.absent(),
            Value<String> shortName = const Value.absent(),
            Value<String> displayNameEn = const Value.absent(),
            Value<String?> displayNameKo = const Value.absent(),
            Value<int> chapterCount = const Value.absent(),
          }) =>
              BibleBooksCompanion(
            id: id,
            bookKey: bookKey,
            testament: testament,
            bookOrder: bookOrder,
            shortName: shortName,
            displayNameEn: displayNameEn,
            displayNameKo: displayNameKo,
            chapterCount: chapterCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String bookKey,
            required String testament,
            required int bookOrder,
            required String shortName,
            required String displayNameEn,
            Value<String?> displayNameKo = const Value.absent(),
            required int chapterCount,
          }) =>
              BibleBooksCompanion.insert(
            id: id,
            bookKey: bookKey,
            testament: testament,
            bookOrder: bookOrder,
            shortName: shortName,
            displayNameEn: displayNameEn,
            displayNameKo: displayNameKo,
            chapterCount: chapterCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BibleBooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BibleBooksTable,
    BibleBook,
    $$BibleBooksTableFilterComposer,
    $$BibleBooksTableOrderingComposer,
    $$BibleBooksTableAnnotationComposer,
    $$BibleBooksTableCreateCompanionBuilder,
    $$BibleBooksTableUpdateCompanionBuilder,
    (BibleBook, BaseReferences<_$AppDatabase, $BibleBooksTable, BibleBook>),
    BibleBook,
    PrefetchHooks Function()>;
typedef $$BibleChaptersTableCreateCompanionBuilder = BibleChaptersCompanion
    Function({
  required String bookKey,
  required int chapterNumber,
  required int verseCount,
  required int estimatedReadingSeconds,
  required int estimatedReadingMinutes,
  Value<int> rowid,
});
typedef $$BibleChaptersTableUpdateCompanionBuilder = BibleChaptersCompanion
    Function({
  Value<String> bookKey,
  Value<int> chapterNumber,
  Value<int> verseCount,
  Value<int> estimatedReadingSeconds,
  Value<int> estimatedReadingMinutes,
  Value<int> rowid,
});

class $$BibleChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $BibleChaptersTable> {
  $$BibleChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get verseCount => $composableBuilder(
      column: $table.verseCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedReadingSeconds => $composableBuilder(
      column: $table.estimatedReadingSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedReadingMinutes => $composableBuilder(
      column: $table.estimatedReadingMinutes,
      builder: (column) => ColumnFilters(column));
}

class $$BibleChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $BibleChaptersTable> {
  $$BibleChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get verseCount => $composableBuilder(
      column: $table.verseCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedReadingSeconds => $composableBuilder(
      column: $table.estimatedReadingSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedReadingMinutes => $composableBuilder(
      column: $table.estimatedReadingMinutes,
      builder: (column) => ColumnOrderings(column));
}

class $$BibleChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $BibleChaptersTable> {
  $$BibleChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<int> get verseCount => $composableBuilder(
      column: $table.verseCount, builder: (column) => column);

  GeneratedColumn<int> get estimatedReadingSeconds => $composableBuilder(
      column: $table.estimatedReadingSeconds, builder: (column) => column);

  GeneratedColumn<int> get estimatedReadingMinutes => $composableBuilder(
      column: $table.estimatedReadingMinutes, builder: (column) => column);
}

class $$BibleChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BibleChaptersTable,
    BibleChapter,
    $$BibleChaptersTableFilterComposer,
    $$BibleChaptersTableOrderingComposer,
    $$BibleChaptersTableAnnotationComposer,
    $$BibleChaptersTableCreateCompanionBuilder,
    $$BibleChaptersTableUpdateCompanionBuilder,
    (
      BibleChapter,
      BaseReferences<_$AppDatabase, $BibleChaptersTable, BibleChapter>
    ),
    BibleChapter,
    PrefetchHooks Function()> {
  $$BibleChaptersTableTableManager(_$AppDatabase db, $BibleChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BibleChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BibleChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BibleChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> bookKey = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<int> verseCount = const Value.absent(),
            Value<int> estimatedReadingSeconds = const Value.absent(),
            Value<int> estimatedReadingMinutes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BibleChaptersCompanion(
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            verseCount: verseCount,
            estimatedReadingSeconds: estimatedReadingSeconds,
            estimatedReadingMinutes: estimatedReadingMinutes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String bookKey,
            required int chapterNumber,
            required int verseCount,
            required int estimatedReadingSeconds,
            required int estimatedReadingMinutes,
            Value<int> rowid = const Value.absent(),
          }) =>
              BibleChaptersCompanion.insert(
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            verseCount: verseCount,
            estimatedReadingSeconds: estimatedReadingSeconds,
            estimatedReadingMinutes: estimatedReadingMinutes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BibleChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BibleChaptersTable,
    BibleChapter,
    $$BibleChaptersTableFilterComposer,
    $$BibleChaptersTableOrderingComposer,
    $$BibleChaptersTableAnnotationComposer,
    $$BibleChaptersTableCreateCompanionBuilder,
    $$BibleChaptersTableUpdateCompanionBuilder,
    (
      BibleChapter,
      BaseReferences<_$AppDatabase, $BibleChaptersTable, BibleChapter>
    ),
    BibleChapter,
    PrefetchHooks Function()>;
typedef $$LocalUsersTableCreateCompanionBuilder = LocalUsersCompanion Function({
  required String id,
  Value<String> type,
  Value<String?> authUserId,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LocalUsersTableUpdateCompanionBuilder = LocalUsersCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String?> authUserId,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authUserId => $composableBuilder(
      column: $table.authUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authUserId => $composableBuilder(
      column: $table.authUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get authUserId => $composableBuilder(
      column: $table.authUserId, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalUsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalUsersTable,
    LocalUser,
    $$LocalUsersTableFilterComposer,
    $$LocalUsersTableOrderingComposer,
    $$LocalUsersTableAnnotationComposer,
    $$LocalUsersTableCreateCompanionBuilder,
    $$LocalUsersTableUpdateCompanionBuilder,
    (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
    LocalUser,
    PrefetchHooks Function()> {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> authUserId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUsersCompanion(
            id: id,
            type: type,
            authUserId: authUserId,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> type = const Value.absent(),
            Value<String?> authUserId = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalUsersCompanion.insert(
            id: id,
            type: type,
            authUserId: authUserId,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalUsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalUsersTable,
    LocalUser,
    $$LocalUsersTableFilterComposer,
    $$LocalUsersTableOrderingComposer,
    $$LocalUsersTableAnnotationComposer,
    $$LocalUsersTableCreateCompanionBuilder,
    $$LocalUsersTableUpdateCompanionBuilder,
    (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
    LocalUser,
    PrefetchHooks Function()>;
typedef $$PlanTemplatesTableCreateCompanionBuilder = PlanTemplatesCompanion
    Function({
  required String id,
  required String templateKey,
  required String title,
  Value<String> subtitle,
  Value<String> description,
  Value<String> shortDescription,
  Value<String?> coverImageUrl,
  Value<String> planType,
  Value<String> testamentScope,
  Value<String?> difficulty,
  Value<int?> estimatedMinutes,
  Value<int?> estimatedDays,
  Value<int> totalChapters,
  Value<String?> primaryBookKey,
  Value<String?> primaryCharacter,
  Value<bool> isBuiltin,
  Value<bool> isPublished,
  Value<int?> featuredRank,
  Value<bool> browseVisible,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PlanTemplatesTableUpdateCompanionBuilder = PlanTemplatesCompanion
    Function({
  Value<String> id,
  Value<String> templateKey,
  Value<String> title,
  Value<String> subtitle,
  Value<String> description,
  Value<String> shortDescription,
  Value<String?> coverImageUrl,
  Value<String> planType,
  Value<String> testamentScope,
  Value<String?> difficulty,
  Value<int?> estimatedMinutes,
  Value<int?> estimatedDays,
  Value<int> totalChapters,
  Value<String?> primaryBookKey,
  Value<String?> primaryCharacter,
  Value<bool> isBuiltin,
  Value<bool> isPublished,
  Value<int?> featuredRank,
  Value<bool> browseVisible,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PlanTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTemplatesTable> {
  $$PlanTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planType => $composableBuilder(
      column: $table.planType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get testamentScope => $composableBuilder(
      column: $table.testamentScope,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedDays => $composableBuilder(
      column: $table.estimatedDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primaryBookKey => $composableBuilder(
      column: $table.primaryBookKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primaryCharacter => $composableBuilder(
      column: $table.primaryCharacter,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
      column: $table.isBuiltin, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get featuredRank => $composableBuilder(
      column: $table.featuredRank, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get browseVisible => $composableBuilder(
      column: $table.browseVisible, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PlanTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTemplatesTable> {
  $$PlanTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subtitle => $composableBuilder(
      column: $table.subtitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planType => $composableBuilder(
      column: $table.planType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get testamentScope => $composableBuilder(
      column: $table.testamentScope,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedDays => $composableBuilder(
      column: $table.estimatedDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryBookKey => $composableBuilder(
      column: $table.primaryBookKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryCharacter => $composableBuilder(
      column: $table.primaryCharacter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
      column: $table.isBuiltin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get featuredRank => $composableBuilder(
      column: $table.featuredRank,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get browseVisible => $composableBuilder(
      column: $table.browseVisible,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlanTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTemplatesTable> {
  $$PlanTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get shortDescription => $composableBuilder(
      column: $table.shortDescription, builder: (column) => column);

  GeneratedColumn<String> get coverImageUrl => $composableBuilder(
      column: $table.coverImageUrl, builder: (column) => column);

  GeneratedColumn<String> get planType =>
      $composableBuilder(column: $table.planType, builder: (column) => column);

  GeneratedColumn<String> get testamentScope => $composableBuilder(
      column: $table.testamentScope, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes, builder: (column) => column);

  GeneratedColumn<int> get estimatedDays => $composableBuilder(
      column: $table.estimatedDays, builder: (column) => column);

  GeneratedColumn<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters, builder: (column) => column);

  GeneratedColumn<String> get primaryBookKey => $composableBuilder(
      column: $table.primaryBookKey, builder: (column) => column);

  GeneratedColumn<String> get primaryCharacter => $composableBuilder(
      column: $table.primaryCharacter, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => column);

  GeneratedColumn<int> get featuredRank => $composableBuilder(
      column: $table.featuredRank, builder: (column) => column);

  GeneratedColumn<bool> get browseVisible => $composableBuilder(
      column: $table.browseVisible, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlanTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanTemplatesTable,
    PlanTemplate,
    $$PlanTemplatesTableFilterComposer,
    $$PlanTemplatesTableOrderingComposer,
    $$PlanTemplatesTableAnnotationComposer,
    $$PlanTemplatesTableCreateCompanionBuilder,
    $$PlanTemplatesTableUpdateCompanionBuilder,
    (
      PlanTemplate,
      BaseReferences<_$AppDatabase, $PlanTemplatesTable, PlanTemplate>
    ),
    PlanTemplate,
    PrefetchHooks Function()> {
  $$PlanTemplatesTableTableManager(_$AppDatabase db, $PlanTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateKey = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> subtitle = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> shortDescription = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String> planType = const Value.absent(),
            Value<String> testamentScope = const Value.absent(),
            Value<String?> difficulty = const Value.absent(),
            Value<int?> estimatedMinutes = const Value.absent(),
            Value<int?> estimatedDays = const Value.absent(),
            Value<int> totalChapters = const Value.absent(),
            Value<String?> primaryBookKey = const Value.absent(),
            Value<String?> primaryCharacter = const Value.absent(),
            Value<bool> isBuiltin = const Value.absent(),
            Value<bool> isPublished = const Value.absent(),
            Value<int?> featuredRank = const Value.absent(),
            Value<bool> browseVisible = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTemplatesCompanion(
            id: id,
            templateKey: templateKey,
            title: title,
            subtitle: subtitle,
            description: description,
            shortDescription: shortDescription,
            coverImageUrl: coverImageUrl,
            planType: planType,
            testamentScope: testamentScope,
            difficulty: difficulty,
            estimatedMinutes: estimatedMinutes,
            estimatedDays: estimatedDays,
            totalChapters: totalChapters,
            primaryBookKey: primaryBookKey,
            primaryCharacter: primaryCharacter,
            isBuiltin: isBuiltin,
            isPublished: isPublished,
            featuredRank: featuredRank,
            browseVisible: browseVisible,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateKey,
            required String title,
            Value<String> subtitle = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> shortDescription = const Value.absent(),
            Value<String?> coverImageUrl = const Value.absent(),
            Value<String> planType = const Value.absent(),
            Value<String> testamentScope = const Value.absent(),
            Value<String?> difficulty = const Value.absent(),
            Value<int?> estimatedMinutes = const Value.absent(),
            Value<int?> estimatedDays = const Value.absent(),
            Value<int> totalChapters = const Value.absent(),
            Value<String?> primaryBookKey = const Value.absent(),
            Value<String?> primaryCharacter = const Value.absent(),
            Value<bool> isBuiltin = const Value.absent(),
            Value<bool> isPublished = const Value.absent(),
            Value<int?> featuredRank = const Value.absent(),
            Value<bool> browseVisible = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTemplatesCompanion.insert(
            id: id,
            templateKey: templateKey,
            title: title,
            subtitle: subtitle,
            description: description,
            shortDescription: shortDescription,
            coverImageUrl: coverImageUrl,
            planType: planType,
            testamentScope: testamentScope,
            difficulty: difficulty,
            estimatedMinutes: estimatedMinutes,
            estimatedDays: estimatedDays,
            totalChapters: totalChapters,
            primaryBookKey: primaryBookKey,
            primaryCharacter: primaryCharacter,
            isBuiltin: isBuiltin,
            isPublished: isPublished,
            featuredRank: featuredRank,
            browseVisible: browseVisible,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanTemplatesTable,
    PlanTemplate,
    $$PlanTemplatesTableFilterComposer,
    $$PlanTemplatesTableOrderingComposer,
    $$PlanTemplatesTableAnnotationComposer,
    $$PlanTemplatesTableCreateCompanionBuilder,
    $$PlanTemplatesTableUpdateCompanionBuilder,
    (
      PlanTemplate,
      BaseReferences<_$AppDatabase, $PlanTemplatesTable, PlanTemplate>
    ),
    PlanTemplate,
    PrefetchHooks Function()>;
typedef $$PlanTemplateSectionsTableCreateCompanionBuilder
    = PlanTemplateSectionsCompanion Function({
  required String id,
  required String planTemplateId,
  required String sectionKey,
  required String title,
  Value<String> description,
  required int orderIndex,
  Value<int?> estimatedMinutes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PlanTemplateSectionsTableUpdateCompanionBuilder
    = PlanTemplateSectionsCompanion Function({
  Value<String> id,
  Value<String> planTemplateId,
  Value<String> sectionKey,
  Value<String> title,
  Value<String> description,
  Value<int> orderIndex,
  Value<int?> estimatedMinutes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PlanTemplateSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTemplateSectionsTable> {
  $$PlanTemplateSectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planTemplateId => $composableBuilder(
      column: $table.planTemplateId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sectionKey => $composableBuilder(
      column: $table.sectionKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PlanTemplateSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTemplateSectionsTable> {
  $$PlanTemplateSectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planTemplateId => $composableBuilder(
      column: $table.planTemplateId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sectionKey => $composableBuilder(
      column: $table.sectionKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlanTemplateSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTemplateSectionsTable> {
  $$PlanTemplateSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planTemplateId => $composableBuilder(
      column: $table.planTemplateId, builder: (column) => column);

  GeneratedColumn<String> get sectionKey => $composableBuilder(
      column: $table.sectionKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
      column: $table.estimatedMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlanTemplateSectionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanTemplateSectionsTable,
    PlanTemplateSection,
    $$PlanTemplateSectionsTableFilterComposer,
    $$PlanTemplateSectionsTableOrderingComposer,
    $$PlanTemplateSectionsTableAnnotationComposer,
    $$PlanTemplateSectionsTableCreateCompanionBuilder,
    $$PlanTemplateSectionsTableUpdateCompanionBuilder,
    (
      PlanTemplateSection,
      BaseReferences<_$AppDatabase, $PlanTemplateSectionsTable,
          PlanTemplateSection>
    ),
    PlanTemplateSection,
    PrefetchHooks Function()> {
  $$PlanTemplateSectionsTableTableManager(
      _$AppDatabase db, $PlanTemplateSectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTemplateSectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTemplateSectionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTemplateSectionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> planTemplateId = const Value.absent(),
            Value<String> sectionKey = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<int?> estimatedMinutes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTemplateSectionsCompanion(
            id: id,
            planTemplateId: planTemplateId,
            sectionKey: sectionKey,
            title: title,
            description: description,
            orderIndex: orderIndex,
            estimatedMinutes: estimatedMinutes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planTemplateId,
            required String sectionKey,
            required String title,
            Value<String> description = const Value.absent(),
            required int orderIndex,
            Value<int?> estimatedMinutes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTemplateSectionsCompanion.insert(
            id: id,
            planTemplateId: planTemplateId,
            sectionKey: sectionKey,
            title: title,
            description: description,
            orderIndex: orderIndex,
            estimatedMinutes: estimatedMinutes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanTemplateSectionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PlanTemplateSectionsTable,
        PlanTemplateSection,
        $$PlanTemplateSectionsTableFilterComposer,
        $$PlanTemplateSectionsTableOrderingComposer,
        $$PlanTemplateSectionsTableAnnotationComposer,
        $$PlanTemplateSectionsTableCreateCompanionBuilder,
        $$PlanTemplateSectionsTableUpdateCompanionBuilder,
        (
          PlanTemplateSection,
          BaseReferences<_$AppDatabase, $PlanTemplateSectionsTable,
              PlanTemplateSection>
        ),
        PlanTemplateSection,
        PrefetchHooks Function()>;
typedef $$PlanTemplateItemsTableCreateCompanionBuilder
    = PlanTemplateItemsCompanion Function({
  required String id,
  required String sectionId,
  required int orderIndex,
  required String bookKey,
  required int startChapter,
  required int endChapter,
  Value<int> rowid,
});
typedef $$PlanTemplateItemsTableUpdateCompanionBuilder
    = PlanTemplateItemsCompanion Function({
  Value<String> id,
  Value<String> sectionId,
  Value<int> orderIndex,
  Value<String> bookKey,
  Value<int> startChapter,
  Value<int> endChapter,
  Value<int> rowid,
});

class $$PlanTemplateItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTemplateItemsTable> {
  $$PlanTemplateItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sectionId => $composableBuilder(
      column: $table.sectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startChapter => $composableBuilder(
      column: $table.startChapter, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endChapter => $composableBuilder(
      column: $table.endChapter, builder: (column) => ColumnFilters(column));
}

class $$PlanTemplateItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTemplateItemsTable> {
  $$PlanTemplateItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sectionId => $composableBuilder(
      column: $table.sectionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startChapter => $composableBuilder(
      column: $table.startChapter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endChapter => $composableBuilder(
      column: $table.endChapter, builder: (column) => ColumnOrderings(column));
}

class $$PlanTemplateItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTemplateItemsTable> {
  $$PlanTemplateItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<int> get startChapter => $composableBuilder(
      column: $table.startChapter, builder: (column) => column);

  GeneratedColumn<int> get endChapter => $composableBuilder(
      column: $table.endChapter, builder: (column) => column);
}

class $$PlanTemplateItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanTemplateItemsTable,
    PlanTemplateItem,
    $$PlanTemplateItemsTableFilterComposer,
    $$PlanTemplateItemsTableOrderingComposer,
    $$PlanTemplateItemsTableAnnotationComposer,
    $$PlanTemplateItemsTableCreateCompanionBuilder,
    $$PlanTemplateItemsTableUpdateCompanionBuilder,
    (
      PlanTemplateItem,
      BaseReferences<_$AppDatabase, $PlanTemplateItemsTable, PlanTemplateItem>
    ),
    PlanTemplateItem,
    PrefetchHooks Function()> {
  $$PlanTemplateItemsTableTableManager(
      _$AppDatabase db, $PlanTemplateItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTemplateItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTemplateItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTemplateItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> sectionId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<int> startChapter = const Value.absent(),
            Value<int> endChapter = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTemplateItemsCompanion(
            id: id,
            sectionId: sectionId,
            orderIndex: orderIndex,
            bookKey: bookKey,
            startChapter: startChapter,
            endChapter: endChapter,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String sectionId,
            required int orderIndex,
            required String bookKey,
            required int startChapter,
            required int endChapter,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTemplateItemsCompanion.insert(
            id: id,
            sectionId: sectionId,
            orderIndex: orderIndex,
            bookKey: bookKey,
            startChapter: startChapter,
            endChapter: endChapter,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanTemplateItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanTemplateItemsTable,
    PlanTemplateItem,
    $$PlanTemplateItemsTableFilterComposer,
    $$PlanTemplateItemsTableOrderingComposer,
    $$PlanTemplateItemsTableAnnotationComposer,
    $$PlanTemplateItemsTableCreateCompanionBuilder,
    $$PlanTemplateItemsTableUpdateCompanionBuilder,
    (
      PlanTemplateItem,
      BaseReferences<_$AppDatabase, $PlanTemplateItemsTable, PlanTemplateItem>
    ),
    PlanTemplateItem,
    PrefetchHooks Function()>;
typedef $$PlanTagsTableCreateCompanionBuilder = PlanTagsCompanion Function({
  required String id,
  required String key,
  required String name,
  required String type,
  Value<int> rowid,
});
typedef $$PlanTagsTableUpdateCompanionBuilder = PlanTagsCompanion Function({
  Value<String> id,
  Value<String> key,
  Value<String> name,
  Value<String> type,
  Value<int> rowid,
});

class $$PlanTagsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTagsTable> {
  $$PlanTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));
}

class $$PlanTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTagsTable> {
  $$PlanTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));
}

class $$PlanTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTagsTable> {
  $$PlanTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$PlanTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanTagsTable,
    PlanTag,
    $$PlanTagsTableFilterComposer,
    $$PlanTagsTableOrderingComposer,
    $$PlanTagsTableAnnotationComposer,
    $$PlanTagsTableCreateCompanionBuilder,
    $$PlanTagsTableUpdateCompanionBuilder,
    (PlanTag, BaseReferences<_$AppDatabase, $PlanTagsTable, PlanTag>),
    PlanTag,
    PrefetchHooks Function()> {
  $$PlanTagsTableTableManager(_$AppDatabase db, $PlanTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTagsCompanion(
            id: id,
            key: key,
            name: name,
            type: type,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String key,
            required String name,
            required String type,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTagsCompanion.insert(
            id: id,
            key: key,
            name: name,
            type: type,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanTagsTable,
    PlanTag,
    $$PlanTagsTableFilterComposer,
    $$PlanTagsTableOrderingComposer,
    $$PlanTagsTableAnnotationComposer,
    $$PlanTagsTableCreateCompanionBuilder,
    $$PlanTagsTableUpdateCompanionBuilder,
    (PlanTag, BaseReferences<_$AppDatabase, $PlanTagsTable, PlanTag>),
    PlanTag,
    PrefetchHooks Function()>;
typedef $$PlanTemplateTagsTableCreateCompanionBuilder
    = PlanTemplateTagsCompanion Function({
  required String planTemplateId,
  required String tagId,
  Value<int> rowid,
});
typedef $$PlanTemplateTagsTableUpdateCompanionBuilder
    = PlanTemplateTagsCompanion Function({
  Value<String> planTemplateId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$PlanTemplateTagsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTemplateTagsTable> {
  $$PlanTemplateTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get planTemplateId => $composableBuilder(
      column: $table.planTemplateId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$PlanTemplateTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTemplateTagsTable> {
  $$PlanTemplateTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get planTemplateId => $composableBuilder(
      column: $table.planTemplateId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$PlanTemplateTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTemplateTagsTable> {
  $$PlanTemplateTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get planTemplateId => $composableBuilder(
      column: $table.planTemplateId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$PlanTemplateTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanTemplateTagsTable,
    PlanTemplateTag,
    $$PlanTemplateTagsTableFilterComposer,
    $$PlanTemplateTagsTableOrderingComposer,
    $$PlanTemplateTagsTableAnnotationComposer,
    $$PlanTemplateTagsTableCreateCompanionBuilder,
    $$PlanTemplateTagsTableUpdateCompanionBuilder,
    (
      PlanTemplateTag,
      BaseReferences<_$AppDatabase, $PlanTemplateTagsTable, PlanTemplateTag>
    ),
    PlanTemplateTag,
    PrefetchHooks Function()> {
  $$PlanTemplateTagsTableTableManager(
      _$AppDatabase db, $PlanTemplateTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTemplateTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTemplateTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTemplateTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> planTemplateId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTemplateTagsCompanion(
            planTemplateId: planTemplateId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String planTemplateId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanTemplateTagsCompanion.insert(
            planTemplateId: planTemplateId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanTemplateTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanTemplateTagsTable,
    PlanTemplateTag,
    $$PlanTemplateTagsTableFilterComposer,
    $$PlanTemplateTagsTableOrderingComposer,
    $$PlanTemplateTagsTableAnnotationComposer,
    $$PlanTemplateTagsTableCreateCompanionBuilder,
    $$PlanTemplateTagsTableUpdateCompanionBuilder,
    (
      PlanTemplateTag,
      BaseReferences<_$AppDatabase, $PlanTemplateTagsTable, PlanTemplateTag>
    ),
    PlanTemplateTag,
    PrefetchHooks Function()>;
typedef $$UserReadingPlansTableCreateCompanionBuilder
    = UserReadingPlansCompanion Function({
  required String id,
  required String localUserId,
  required String templateId,
  required String title,
  Value<String> status,
  required DateTime subscribedAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> archivedAt,
  Value<bool> isActive,
  Value<String?> lastOpenedSectionId,
  Value<String?> lastOpenedBookKey,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});
typedef $$UserReadingPlansTableUpdateCompanionBuilder
    = UserReadingPlansCompanion Function({
  Value<String> id,
  Value<String> localUserId,
  Value<String> templateId,
  Value<String> title,
  Value<String> status,
  Value<DateTime> subscribedAt,
  Value<DateTime?> startedAt,
  Value<DateTime?> completedAt,
  Value<DateTime?> archivedAt,
  Value<bool> isActive,
  Value<String?> lastOpenedSectionId,
  Value<String?> lastOpenedBookKey,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});

class $$UserReadingPlansTableFilterComposer
    extends Composer<_$AppDatabase, $UserReadingPlansTable> {
  $$UserReadingPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastOpenedSectionId => $composableBuilder(
      column: $table.lastOpenedSectionId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastOpenedBookKey => $composableBuilder(
      column: $table.lastOpenedBookKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnFilters(column));
}

class $$UserReadingPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $UserReadingPlansTable> {
  $$UserReadingPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastOpenedSectionId => $composableBuilder(
      column: $table.lastOpenedSectionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastOpenedBookKey => $composableBuilder(
      column: $table.lastOpenedBookKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnOrderings(column));
}

class $$UserReadingPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserReadingPlansTable> {
  $$UserReadingPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
      column: $table.archivedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get lastOpenedSectionId => $composableBuilder(
      column: $table.lastOpenedSectionId, builder: (column) => column);

  GeneratedColumn<String> get lastOpenedBookKey => $composableBuilder(
      column: $table.lastOpenedBookKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision, builder: (column) => column);
}

class $$UserReadingPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserReadingPlansTable,
    UserReadingPlan,
    $$UserReadingPlansTableFilterComposer,
    $$UserReadingPlansTableOrderingComposer,
    $$UserReadingPlansTableAnnotationComposer,
    $$UserReadingPlansTableCreateCompanionBuilder,
    $$UserReadingPlansTableUpdateCompanionBuilder,
    (
      UserReadingPlan,
      BaseReferences<_$AppDatabase, $UserReadingPlansTable, UserReadingPlan>
    ),
    UserReadingPlan,
    PrefetchHooks Function()> {
  $$UserReadingPlansTableTableManager(
      _$AppDatabase db, $UserReadingPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserReadingPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserReadingPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserReadingPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> localUserId = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> subscribedAt = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> lastOpenedSectionId = const Value.absent(),
            Value<String?> lastOpenedBookKey = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserReadingPlansCompanion(
            id: id,
            localUserId: localUserId,
            templateId: templateId,
            title: title,
            status: status,
            subscribedAt: subscribedAt,
            startedAt: startedAt,
            completedAt: completedAt,
            archivedAt: archivedAt,
            isActive: isActive,
            lastOpenedSectionId: lastOpenedSectionId,
            lastOpenedBookKey: lastOpenedBookKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String localUserId,
            required String templateId,
            required String title,
            Value<String> status = const Value.absent(),
            required DateTime subscribedAt,
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime?> archivedAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> lastOpenedSectionId = const Value.absent(),
            Value<String?> lastOpenedBookKey = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserReadingPlansCompanion.insert(
            id: id,
            localUserId: localUserId,
            templateId: templateId,
            title: title,
            status: status,
            subscribedAt: subscribedAt,
            startedAt: startedAt,
            completedAt: completedAt,
            archivedAt: archivedAt,
            isActive: isActive,
            lastOpenedSectionId: lastOpenedSectionId,
            lastOpenedBookKey: lastOpenedBookKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserReadingPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserReadingPlansTable,
    UserReadingPlan,
    $$UserReadingPlansTableFilterComposer,
    $$UserReadingPlansTableOrderingComposer,
    $$UserReadingPlansTableAnnotationComposer,
    $$UserReadingPlansTableCreateCompanionBuilder,
    $$UserReadingPlansTableUpdateCompanionBuilder,
    (
      UserReadingPlan,
      BaseReferences<_$AppDatabase, $UserReadingPlansTable, UserReadingPlan>
    ),
    UserReadingPlan,
    PrefetchHooks Function()>;
typedef $$UserPlanChaptersTableCreateCompanionBuilder
    = UserPlanChaptersCompanion Function({
  required String id,
  required String userPlanId,
  required String sectionId,
  required String bookKey,
  required int chapterNumber,
  required int orderIndex,
  required DateTime createdAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});
typedef $$UserPlanChaptersTableUpdateCompanionBuilder
    = UserPlanChaptersCompanion Function({
  Value<String> id,
  Value<String> userPlanId,
  Value<String> sectionId,
  Value<String> bookKey,
  Value<int> chapterNumber,
  Value<int> orderIndex,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});

class $$UserPlanChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $UserPlanChaptersTable> {
  $$UserPlanChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sectionId => $composableBuilder(
      column: $table.sectionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnFilters(column));
}

class $$UserPlanChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPlanChaptersTable> {
  $$UserPlanChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sectionId => $composableBuilder(
      column: $table.sectionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnOrderings(column));
}

class $$UserPlanChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPlanChaptersTable> {
  $$UserPlanChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => column);

  GeneratedColumn<String> get sectionId =>
      $composableBuilder(column: $table.sectionId, builder: (column) => column);

  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision, builder: (column) => column);
}

class $$UserPlanChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserPlanChaptersTable,
    UserPlanChapter,
    $$UserPlanChaptersTableFilterComposer,
    $$UserPlanChaptersTableOrderingComposer,
    $$UserPlanChaptersTableAnnotationComposer,
    $$UserPlanChaptersTableCreateCompanionBuilder,
    $$UserPlanChaptersTableUpdateCompanionBuilder,
    (
      UserPlanChapter,
      BaseReferences<_$AppDatabase, $UserPlanChaptersTable, UserPlanChapter>
    ),
    UserPlanChapter,
    PrefetchHooks Function()> {
  $$UserPlanChaptersTableTableManager(
      _$AppDatabase db, $UserPlanChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPlanChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPlanChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPlanChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userPlanId = const Value.absent(),
            Value<String> sectionId = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserPlanChaptersCompanion(
            id: id,
            userPlanId: userPlanId,
            sectionId: sectionId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            orderIndex: orderIndex,
            createdAt: createdAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userPlanId,
            required String sectionId,
            required String bookKey,
            required int chapterNumber,
            required int orderIndex,
            required DateTime createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserPlanChaptersCompanion.insert(
            id: id,
            userPlanId: userPlanId,
            sectionId: sectionId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            orderIndex: orderIndex,
            createdAt: createdAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserPlanChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserPlanChaptersTable,
    UserPlanChapter,
    $$UserPlanChaptersTableFilterComposer,
    $$UserPlanChaptersTableOrderingComposer,
    $$UserPlanChaptersTableAnnotationComposer,
    $$UserPlanChaptersTableCreateCompanionBuilder,
    $$UserPlanChaptersTableUpdateCompanionBuilder,
    (
      UserPlanChapter,
      BaseReferences<_$AppDatabase, $UserPlanChaptersTable, UserPlanChapter>
    ),
    UserPlanChapter,
    PrefetchHooks Function()>;
typedef $$PlanCompletionEventsTableCreateCompanionBuilder
    = PlanCompletionEventsCompanion Function({
  required String id,
  required String localUserId,
  required String userPlanId,
  required String templateId,
  required int completionNumber,
  required DateTime completedAt,
  required DateTime createdAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});
typedef $$PlanCompletionEventsTableUpdateCompanionBuilder
    = PlanCompletionEventsCompanion Function({
  Value<String> id,
  Value<String> localUserId,
  Value<String> userPlanId,
  Value<String> templateId,
  Value<int> completionNumber,
  Value<DateTime> completedAt,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});

class $$PlanCompletionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanCompletionEventsTable> {
  $$PlanCompletionEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completionNumber => $composableBuilder(
      column: $table.completionNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnFilters(column));
}

class $$PlanCompletionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanCompletionEventsTable> {
  $$PlanCompletionEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completionNumber => $composableBuilder(
      column: $table.completionNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnOrderings(column));
}

class $$PlanCompletionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanCompletionEventsTable> {
  $$PlanCompletionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => column);

  GeneratedColumn<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
      column: $table.templateId, builder: (column) => column);

  GeneratedColumn<int> get completionNumber => $composableBuilder(
      column: $table.completionNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision, builder: (column) => column);
}

class $$PlanCompletionEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanCompletionEventsTable,
    PlanCompletionEvent,
    $$PlanCompletionEventsTableFilterComposer,
    $$PlanCompletionEventsTableOrderingComposer,
    $$PlanCompletionEventsTableAnnotationComposer,
    $$PlanCompletionEventsTableCreateCompanionBuilder,
    $$PlanCompletionEventsTableUpdateCompanionBuilder,
    (
      PlanCompletionEvent,
      BaseReferences<_$AppDatabase, $PlanCompletionEventsTable,
          PlanCompletionEvent>
    ),
    PlanCompletionEvent,
    PrefetchHooks Function()> {
  $$PlanCompletionEventsTableTableManager(
      _$AppDatabase db, $PlanCompletionEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanCompletionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanCompletionEventsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanCompletionEventsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> localUserId = const Value.absent(),
            Value<String> userPlanId = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<int> completionNumber = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanCompletionEventsCompanion(
            id: id,
            localUserId: localUserId,
            userPlanId: userPlanId,
            templateId: templateId,
            completionNumber: completionNumber,
            completedAt: completedAt,
            createdAt: createdAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String localUserId,
            required String userPlanId,
            required String templateId,
            required int completionNumber,
            required DateTime completedAt,
            required DateTime createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanCompletionEventsCompanion.insert(
            id: id,
            localUserId: localUserId,
            userPlanId: userPlanId,
            templateId: templateId,
            completionNumber: completionNumber,
            completedAt: completedAt,
            createdAt: createdAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanCompletionEventsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PlanCompletionEventsTable,
        PlanCompletionEvent,
        $$PlanCompletionEventsTableFilterComposer,
        $$PlanCompletionEventsTableOrderingComposer,
        $$PlanCompletionEventsTableAnnotationComposer,
        $$PlanCompletionEventsTableCreateCompanionBuilder,
        $$PlanCompletionEventsTableUpdateCompanionBuilder,
        (
          PlanCompletionEvent,
          BaseReferences<_$AppDatabase, $PlanCompletionEventsTable,
              PlanCompletionEvent>
        ),
        PlanCompletionEvent,
        PrefetchHooks Function()>;
typedef $$ChapterProgressEntriesTableCreateCompanionBuilder
    = ChapterProgressEntriesCompanion Function({
  required String id,
  required String localUserId,
  required String userPlanId,
  required String bookKey,
  required int chapterNumber,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});
typedef $$ChapterProgressEntriesTableUpdateCompanionBuilder
    = ChapterProgressEntriesCompanion Function({
  Value<String> id,
  Value<String> localUserId,
  Value<String> userPlanId,
  Value<String> bookKey,
  Value<int> chapterNumber,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});

class $$ChapterProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ChapterProgressEntriesTable> {
  $$ChapterProgressEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnFilters(column));
}

class $$ChapterProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChapterProgressEntriesTable> {
  $$ChapterProgressEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnOrderings(column));
}

class $$ChapterProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChapterProgressEntriesTable> {
  $$ChapterProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => column);

  GeneratedColumn<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => column);

  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision, builder: (column) => column);
}

class $$ChapterProgressEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChapterProgressEntriesTable,
    ChapterProgressEntry,
    $$ChapterProgressEntriesTableFilterComposer,
    $$ChapterProgressEntriesTableOrderingComposer,
    $$ChapterProgressEntriesTableAnnotationComposer,
    $$ChapterProgressEntriesTableCreateCompanionBuilder,
    $$ChapterProgressEntriesTableUpdateCompanionBuilder,
    (
      ChapterProgressEntry,
      BaseReferences<_$AppDatabase, $ChapterProgressEntriesTable,
          ChapterProgressEntry>
    ),
    ChapterProgressEntry,
    PrefetchHooks Function()> {
  $$ChapterProgressEntriesTableTableManager(
      _$AppDatabase db, $ChapterProgressEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChapterProgressEntriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ChapterProgressEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChapterProgressEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> localUserId = const Value.absent(),
            Value<String> userPlanId = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChapterProgressEntriesCompanion(
            id: id,
            localUserId: localUserId,
            userPlanId: userPlanId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            isCompleted: isCompleted,
            completedAt: completedAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String localUserId,
            required String userPlanId,
            required String bookKey,
            required int chapterNumber,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChapterProgressEntriesCompanion.insert(
            id: id,
            localUserId: localUserId,
            userPlanId: userPlanId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            isCompleted: isCompleted,
            completedAt: completedAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChapterProgressEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ChapterProgressEntriesTable,
        ChapterProgressEntry,
        $$ChapterProgressEntriesTableFilterComposer,
        $$ChapterProgressEntriesTableOrderingComposer,
        $$ChapterProgressEntriesTableAnnotationComposer,
        $$ChapterProgressEntriesTableCreateCompanionBuilder,
        $$ChapterProgressEntriesTableUpdateCompanionBuilder,
        (
          ChapterProgressEntry,
          BaseReferences<_$AppDatabase, $ChapterProgressEntriesTable,
              ChapterProgressEntry>
        ),
        ChapterProgressEntry,
        PrefetchHooks Function()>;
typedef $$ReadingActivitiesTableCreateCompanionBuilder
    = ReadingActivitiesCompanion Function({
  required String id,
  required String localUserId,
  required String userPlanId,
  required String bookKey,
  required int chapterNumber,
  required String action,
  required String activityDate,
  required String timezone,
  required DateTime happenedAt,
  required DateTime createdAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});
typedef $$ReadingActivitiesTableUpdateCompanionBuilder
    = ReadingActivitiesCompanion Function({
  Value<String> id,
  Value<String> localUserId,
  Value<String> userPlanId,
  Value<String> bookKey,
  Value<int> chapterNumber,
  Value<String> action,
  Value<String> activityDate,
  Value<String> timezone,
  Value<DateTime> happenedAt,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
  Value<String?> serverId,
  Value<DateTime?> lastSyncedAt,
  Value<int> clientRevision,
  Value<int> rowid,
});

class $$ReadingActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingActivitiesTable> {
  $$ReadingActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activityDate => $composableBuilder(
      column: $table.activityDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get happenedAt => $composableBuilder(
      column: $table.happenedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnFilters(column));
}

class $$ReadingActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingActivitiesTable> {
  $$ReadingActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activityDate => $composableBuilder(
      column: $table.activityDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timezone => $composableBuilder(
      column: $table.timezone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get happenedAt => $composableBuilder(
      column: $table.happenedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision,
      builder: (column) => ColumnOrderings(column));
}

class $$ReadingActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingActivitiesTable> {
  $$ReadingActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localUserId => $composableBuilder(
      column: $table.localUserId, builder: (column) => column);

  GeneratedColumn<String> get userPlanId => $composableBuilder(
      column: $table.userPlanId, builder: (column) => column);

  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get activityDate => $composableBuilder(
      column: $table.activityDate, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get happenedAt => $composableBuilder(
      column: $table.happenedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<int> get clientRevision => $composableBuilder(
      column: $table.clientRevision, builder: (column) => column);
}

class $$ReadingActivitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingActivitiesTable,
    ReadingActivity,
    $$ReadingActivitiesTableFilterComposer,
    $$ReadingActivitiesTableOrderingComposer,
    $$ReadingActivitiesTableAnnotationComposer,
    $$ReadingActivitiesTableCreateCompanionBuilder,
    $$ReadingActivitiesTableUpdateCompanionBuilder,
    (
      ReadingActivity,
      BaseReferences<_$AppDatabase, $ReadingActivitiesTable, ReadingActivity>
    ),
    ReadingActivity,
    PrefetchHooks Function()> {
  $$ReadingActivitiesTableTableManager(
      _$AppDatabase db, $ReadingActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingActivitiesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> localUserId = const Value.absent(),
            Value<String> userPlanId = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> activityDate = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<DateTime> happenedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingActivitiesCompanion(
            id: id,
            localUserId: localUserId,
            userPlanId: userPlanId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            action: action,
            activityDate: activityDate,
            timezone: timezone,
            happenedAt: happenedAt,
            createdAt: createdAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String localUserId,
            required String userPlanId,
            required String bookKey,
            required int chapterNumber,
            required String action,
            required String activityDate,
            required String timezone,
            required DateTime happenedAt,
            required DateTime createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<String?> serverId = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> clientRevision = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingActivitiesCompanion.insert(
            id: id,
            localUserId: localUserId,
            userPlanId: userPlanId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            action: action,
            activityDate: activityDate,
            timezone: timezone,
            happenedAt: happenedAt,
            createdAt: createdAt,
            syncStatus: syncStatus,
            serverId: serverId,
            lastSyncedAt: lastSyncedAt,
            clientRevision: clientRevision,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadingActivitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingActivitiesTable,
    ReadingActivity,
    $$ReadingActivitiesTableFilterComposer,
    $$ReadingActivitiesTableOrderingComposer,
    $$ReadingActivitiesTableAnnotationComposer,
    $$ReadingActivitiesTableCreateCompanionBuilder,
    $$ReadingActivitiesTableUpdateCompanionBuilder,
    (
      ReadingActivity,
      BaseReferences<_$AppDatabase, $ReadingActivitiesTable, ReadingActivity>
    ),
    ReadingActivity,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSetting,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (AppSetting, BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>),
    AppSetting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BibleBooksTableTableManager get bibleBooks =>
      $$BibleBooksTableTableManager(_db, _db.bibleBooks);
  $$BibleChaptersTableTableManager get bibleChapters =>
      $$BibleChaptersTableTableManager(_db, _db.bibleChapters);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$PlanTemplatesTableTableManager get planTemplates =>
      $$PlanTemplatesTableTableManager(_db, _db.planTemplates);
  $$PlanTemplateSectionsTableTableManager get planTemplateSections =>
      $$PlanTemplateSectionsTableTableManager(_db, _db.planTemplateSections);
  $$PlanTemplateItemsTableTableManager get planTemplateItems =>
      $$PlanTemplateItemsTableTableManager(_db, _db.planTemplateItems);
  $$PlanTagsTableTableManager get planTags =>
      $$PlanTagsTableTableManager(_db, _db.planTags);
  $$PlanTemplateTagsTableTableManager get planTemplateTags =>
      $$PlanTemplateTagsTableTableManager(_db, _db.planTemplateTags);
  $$UserReadingPlansTableTableManager get userReadingPlans =>
      $$UserReadingPlansTableTableManager(_db, _db.userReadingPlans);
  $$UserPlanChaptersTableTableManager get userPlanChapters =>
      $$UserPlanChaptersTableTableManager(_db, _db.userPlanChapters);
  $$PlanCompletionEventsTableTableManager get planCompletionEvents =>
      $$PlanCompletionEventsTableTableManager(_db, _db.planCompletionEvents);
  $$ChapterProgressEntriesTableTableManager get chapterProgressEntries =>
      $$ChapterProgressEntriesTableTableManager(
          _db, _db.chapterProgressEntries);
  $$ReadingActivitiesTableTableManager get readingActivities =>
      $$ReadingActivitiesTableTableManager(_db, _db.readingActivities);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
