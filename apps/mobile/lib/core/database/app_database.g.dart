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

class $ReadingPlanTemplatesTable extends ReadingPlanTemplates
    with TableInfo<$ReadingPlanTemplatesTable, ReadingPlanTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingPlanTemplatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _planTypeMeta =
      const VerificationMeta('planType');
  @override
  late final GeneratedColumn<String> planType = GeneratedColumn<String>(
      'plan_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('free_order'));
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
        description,
        planType,
        isBuiltin,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_plan_templates';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReadingPlanTemplate> instance,
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
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('plan_type')) {
      context.handle(_planTypeMeta,
          planType.isAcceptableOrUnknown(data['plan_type']!, _planTypeMeta));
    }
    if (data.containsKey('is_builtin')) {
      context.handle(_isBuiltinMeta,
          isBuiltin.isAcceptableOrUnknown(data['is_builtin']!, _isBuiltinMeta));
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
  ReadingPlanTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingPlanTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_key'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      planType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_type'])!,
      isBuiltin: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_builtin'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ReadingPlanTemplatesTable createAlias(String alias) {
    return $ReadingPlanTemplatesTable(attachedDatabase, alias);
  }
}

class ReadingPlanTemplate extends DataClass
    implements Insertable<ReadingPlanTemplate> {
  final String id;
  final String templateKey;
  final String title;
  final String description;
  final String planType;
  final bool isBuiltin;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReadingPlanTemplate(
      {required this.id,
      required this.templateKey,
      required this.title,
      required this.description,
      required this.planType,
      required this.isBuiltin,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_key'] = Variable<String>(templateKey);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['plan_type'] = Variable<String>(planType);
    map['is_builtin'] = Variable<bool>(isBuiltin);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingPlanTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ReadingPlanTemplatesCompanion(
      id: Value(id),
      templateKey: Value(templateKey),
      title: Value(title),
      description: Value(description),
      planType: Value(planType),
      isBuiltin: Value(isBuiltin),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingPlanTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingPlanTemplate(
      id: serializer.fromJson<String>(json['id']),
      templateKey: serializer.fromJson<String>(json['templateKey']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      planType: serializer.fromJson<String>(json['planType']),
      isBuiltin: serializer.fromJson<bool>(json['isBuiltin']),
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
      'description': serializer.toJson<String>(description),
      'planType': serializer.toJson<String>(planType),
      'isBuiltin': serializer.toJson<bool>(isBuiltin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingPlanTemplate copyWith(
          {String? id,
          String? templateKey,
          String? title,
          String? description,
          String? planType,
          bool? isBuiltin,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ReadingPlanTemplate(
        id: id ?? this.id,
        templateKey: templateKey ?? this.templateKey,
        title: title ?? this.title,
        description: description ?? this.description,
        planType: planType ?? this.planType,
        isBuiltin: isBuiltin ?? this.isBuiltin,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ReadingPlanTemplate copyWithCompanion(ReadingPlanTemplatesCompanion data) {
    return ReadingPlanTemplate(
      id: data.id.present ? data.id.value : this.id,
      templateKey:
          data.templateKey.present ? data.templateKey.value : this.templateKey,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      planType: data.planType.present ? data.planType.value : this.planType,
      isBuiltin: data.isBuiltin.present ? data.isBuiltin.value : this.isBuiltin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingPlanTemplate(')
          ..write('id: $id, ')
          ..write('templateKey: $templateKey, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('planType: $planType, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateKey, title, description, planType,
      isBuiltin, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingPlanTemplate &&
          other.id == this.id &&
          other.templateKey == this.templateKey &&
          other.title == this.title &&
          other.description == this.description &&
          other.planType == this.planType &&
          other.isBuiltin == this.isBuiltin &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReadingPlanTemplatesCompanion
    extends UpdateCompanion<ReadingPlanTemplate> {
  final Value<String> id;
  final Value<String> templateKey;
  final Value<String> title;
  final Value<String> description;
  final Value<String> planType;
  final Value<bool> isBuiltin;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReadingPlanTemplatesCompanion({
    this.id = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.planType = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingPlanTemplatesCompanion.insert({
    required String id,
    required String templateKey,
    required String title,
    this.description = const Value.absent(),
    this.planType = const Value.absent(),
    this.isBuiltin = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateKey = Value(templateKey),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ReadingPlanTemplate> custom({
    Expression<String>? id,
    Expression<String>? templateKey,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? planType,
    Expression<bool>? isBuiltin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateKey != null) 'template_key': templateKey,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (planType != null) 'plan_type': planType,
      if (isBuiltin != null) 'is_builtin': isBuiltin,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingPlanTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateKey,
      Value<String>? title,
      Value<String>? description,
      Value<String>? planType,
      Value<bool>? isBuiltin,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ReadingPlanTemplatesCompanion(
      id: id ?? this.id,
      templateKey: templateKey ?? this.templateKey,
      title: title ?? this.title,
      description: description ?? this.description,
      planType: planType ?? this.planType,
      isBuiltin: isBuiltin ?? this.isBuiltin,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (planType.present) {
      map['plan_type'] = Variable<String>(planType.value);
    }
    if (isBuiltin.present) {
      map['is_builtin'] = Variable<bool>(isBuiltin.value);
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
    return (StringBuffer('ReadingPlanTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('templateKey: $templateKey, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('planType: $planType, ')
          ..write('isBuiltin: $isBuiltin, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
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
  static const VerificationMeta _templateKeyMeta =
      const VerificationMeta('templateKey');
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
      'template_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        templateKey,
        title,
        isActive,
        lastOpenedBookKey,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus
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
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
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
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
      templateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_key'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      lastOpenedBookKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_opened_book_key']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $UserReadingPlansTable createAlias(String alias) {
    return $UserReadingPlansTable(attachedDatabase, alias);
  }
}

class UserReadingPlan extends DataClass implements Insertable<UserReadingPlan> {
  final String id;
  final String templateKey;
  final String title;
  final bool isActive;
  final String? lastOpenedBookKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  const UserReadingPlan(
      {required this.id,
      required this.templateKey,
      required this.title,
      required this.isActive,
      this.lastOpenedBookKey,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_key'] = Variable<String>(templateKey);
    map['title'] = Variable<String>(title);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastOpenedBookKey != null) {
      map['last_opened_book_key'] = Variable<String>(lastOpenedBookKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  UserReadingPlansCompanion toCompanion(bool nullToAbsent) {
    return UserReadingPlansCompanion(
      id: Value(id),
      templateKey: Value(templateKey),
      title: Value(title),
      isActive: Value(isActive),
      lastOpenedBookKey: lastOpenedBookKey == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedBookKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory UserReadingPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserReadingPlan(
      id: serializer.fromJson<String>(json['id']),
      templateKey: serializer.fromJson<String>(json['templateKey']),
      title: serializer.fromJson<String>(json['title']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastOpenedBookKey:
          serializer.fromJson<String?>(json['lastOpenedBookKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateKey': serializer.toJson<String>(templateKey),
      'title': serializer.toJson<String>(title),
      'isActive': serializer.toJson<bool>(isActive),
      'lastOpenedBookKey': serializer.toJson<String?>(lastOpenedBookKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  UserReadingPlan copyWith(
          {String? id,
          String? templateKey,
          String? title,
          bool? isActive,
          Value<String?> lastOpenedBookKey = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncStatus}) =>
      UserReadingPlan(
        id: id ?? this.id,
        templateKey: templateKey ?? this.templateKey,
        title: title ?? this.title,
        isActive: isActive ?? this.isActive,
        lastOpenedBookKey: lastOpenedBookKey.present
            ? lastOpenedBookKey.value
            : this.lastOpenedBookKey,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  UserReadingPlan copyWithCompanion(UserReadingPlansCompanion data) {
    return UserReadingPlan(
      id: data.id.present ? data.id.value : this.id,
      templateKey:
          data.templateKey.present ? data.templateKey.value : this.templateKey,
      title: data.title.present ? data.title.value : this.title,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastOpenedBookKey: data.lastOpenedBookKey.present
          ? data.lastOpenedBookKey.value
          : this.lastOpenedBookKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserReadingPlan(')
          ..write('id: $id, ')
          ..write('templateKey: $templateKey, ')
          ..write('title: $title, ')
          ..write('isActive: $isActive, ')
          ..write('lastOpenedBookKey: $lastOpenedBookKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateKey, title, isActive,
      lastOpenedBookKey, createdAt, updatedAt, deletedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserReadingPlan &&
          other.id == this.id &&
          other.templateKey == this.templateKey &&
          other.title == this.title &&
          other.isActive == this.isActive &&
          other.lastOpenedBookKey == this.lastOpenedBookKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class UserReadingPlansCompanion extends UpdateCompanion<UserReadingPlan> {
  final Value<String> id;
  final Value<String> templateKey;
  final Value<String> title;
  final Value<bool> isActive;
  final Value<String?> lastOpenedBookKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const UserReadingPlansCompanion({
    this.id = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.title = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastOpenedBookKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserReadingPlansCompanion.insert({
    required String id,
    required String templateKey,
    required String title,
    this.isActive = const Value.absent(),
    this.lastOpenedBookKey = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateKey = Value(templateKey),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserReadingPlan> custom({
    Expression<String>? id,
    Expression<String>? templateKey,
    Expression<String>? title,
    Expression<bool>? isActive,
    Expression<String>? lastOpenedBookKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateKey != null) 'template_key': templateKey,
      if (title != null) 'title': title,
      if (isActive != null) 'is_active': isActive,
      if (lastOpenedBookKey != null) 'last_opened_book_key': lastOpenedBookKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserReadingPlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateKey,
      Value<String>? title,
      Value<bool>? isActive,
      Value<String?>? lastOpenedBookKey,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return UserReadingPlansCompanion(
      id: id ?? this.id,
      templateKey: templateKey ?? this.templateKey,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      lastOpenedBookKey: lastOpenedBookKey ?? this.lastOpenedBookKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
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
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
          ..write('templateKey: $templateKey, ')
          ..write('title: $title, ')
          ..write('isActive: $isActive, ')
          ..write('lastOpenedBookKey: $lastOpenedBookKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanScopeChaptersTable extends PlanScopeChapters
    with TableInfo<$PlanScopeChaptersTable, PlanScopeChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanScopeChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
      'plan_id', aliasedName, false,
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, planId, bookKey, chapterNumber, orderIndex, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_scope_chapters';
  @override
  VerificationContext validateIntegrity(Insertable<PlanScopeChapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {planId, bookKey, chapterNumber},
      ];
  @override
  PlanScopeChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanScopeChapter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_id'])!,
      bookKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_key'])!,
      chapterNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_number'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlanScopeChaptersTable createAlias(String alias) {
    return $PlanScopeChaptersTable(attachedDatabase, alias);
  }
}

class PlanScopeChapter extends DataClass
    implements Insertable<PlanScopeChapter> {
  final String id;
  final String planId;
  final String bookKey;
  final int chapterNumber;
  final int orderIndex;
  final DateTime createdAt;
  const PlanScopeChapter(
      {required this.id,
      required this.planId,
      required this.bookKey,
      required this.chapterNumber,
      required this.orderIndex,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['book_key'] = Variable<String>(bookKey);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['order_index'] = Variable<int>(orderIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlanScopeChaptersCompanion toCompanion(bool nullToAbsent) {
    return PlanScopeChaptersCompanion(
      id: Value(id),
      planId: Value(planId),
      bookKey: Value(bookKey),
      chapterNumber: Value(chapterNumber),
      orderIndex: Value(orderIndex),
      createdAt: Value(createdAt),
    );
  }

  factory PlanScopeChapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanScopeChapter(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'bookKey': serializer.toJson<String>(bookKey),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlanScopeChapter copyWith(
          {String? id,
          String? planId,
          String? bookKey,
          int? chapterNumber,
          int? orderIndex,
          DateTime? createdAt}) =>
      PlanScopeChapter(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        bookKey: bookKey ?? this.bookKey,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        orderIndex: orderIndex ?? this.orderIndex,
        createdAt: createdAt ?? this.createdAt,
      );
  PlanScopeChapter copyWithCompanion(PlanScopeChaptersCompanion data) {
    return PlanScopeChapter(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanScopeChapter(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, planId, bookKey, chapterNumber, orderIndex, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanScopeChapter &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.bookKey == this.bookKey &&
          other.chapterNumber == this.chapterNumber &&
          other.orderIndex == this.orderIndex &&
          other.createdAt == this.createdAt);
}

class PlanScopeChaptersCompanion extends UpdateCompanion<PlanScopeChapter> {
  final Value<String> id;
  final Value<String> planId;
  final Value<String> bookKey;
  final Value<int> chapterNumber;
  final Value<int> orderIndex;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlanScopeChaptersCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanScopeChaptersCompanion.insert({
    required String id,
    required String planId,
    required String bookKey,
    required int chapterNumber,
    required int orderIndex,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planId = Value(planId),
        bookKey = Value(bookKey),
        chapterNumber = Value(chapterNumber),
        orderIndex = Value(orderIndex),
        createdAt = Value(createdAt);
  static Insertable<PlanScopeChapter> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<String>? bookKey,
    Expression<int>? chapterNumber,
    Expression<int>? orderIndex,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (bookKey != null) 'book_key': bookKey,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (orderIndex != null) 'order_index': orderIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanScopeChaptersCompanion copyWith(
      {Value<String>? id,
      Value<String>? planId,
      Value<String>? bookKey,
      Value<int>? chapterNumber,
      Value<int>? orderIndex,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PlanScopeChaptersCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      bookKey: bookKey ?? this.bookKey,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanScopeChaptersCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
      'plan_id', aliasedName, false,
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
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local_only'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        planId,
        bookKey,
        chapterNumber,
        isCompleted,
        completedAt,
        updatedAt,
        deletedAt,
        syncStatus
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
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
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
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {planId, bookKey, chapterNumber},
      ];
  @override
  ChapterProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterProgressEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_id'])!,
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
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
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
  final String planId;
  final String bookKey;
  final int chapterNumber;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  const ChapterProgressEntry(
      {required this.id,
      required this.planId,
      required this.bookKey,
      required this.chapterNumber,
      required this.isCompleted,
      this.completedAt,
      required this.updatedAt,
      this.deletedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['book_key'] = Variable<String>(bookKey);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ChapterProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChapterProgressEntriesCompanion(
      id: Value(id),
      planId: Value(planId),
      bookKey: Value(bookKey),
      chapterNumber: Value(chapterNumber),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ChapterProgressEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterProgressEntry(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'bookKey': serializer.toJson<String>(bookKey),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ChapterProgressEntry copyWith(
          {String? id,
          String? planId,
          String? bookKey,
          int? chapterNumber,
          bool? isCompleted,
          Value<DateTime?> completedAt = const Value.absent(),
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncStatus}) =>
      ChapterProgressEntry(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        bookKey: bookKey ?? this.bookKey,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  ChapterProgressEntry copyWithCompanion(ChapterProgressEntriesCompanion data) {
    return ChapterProgressEntry(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterProgressEntry(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, bookKey, chapterNumber,
      isCompleted, completedAt, updatedAt, deletedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterProgressEntry &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.bookKey == this.bookKey &&
          other.chapterNumber == this.chapterNumber &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus);
}

class ChapterProgressEntriesCompanion
    extends UpdateCompanion<ChapterProgressEntry> {
  final Value<String> id;
  final Value<String> planId;
  final Value<String> bookKey;
  final Value<int> chapterNumber;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ChapterProgressEntriesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChapterProgressEntriesCompanion.insert({
    required String id,
    required String planId,
    required String bookKey,
    required int chapterNumber,
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planId = Value(planId),
        bookKey = Value(bookKey),
        chapterNumber = Value(chapterNumber),
        updatedAt = Value(updatedAt);
  static Insertable<ChapterProgressEntry> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<String>? bookKey,
    Expression<int>? chapterNumber,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (bookKey != null) 'book_key': bookKey,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChapterProgressEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? planId,
      Value<String>? bookKey,
      Value<int>? chapterNumber,
      Value<bool>? isCompleted,
      Value<DateTime?>? completedAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return ChapterProgressEntriesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      bookKey: bookKey ?? this.bookKey,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
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
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
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
          ..write('planId: $planId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
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
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
      'plan_id', aliasedName, false,
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        planId,
        bookKey,
        chapterNumber,
        action,
        activityDate,
        timezone,
        happenedAt,
        createdAt,
        syncStatus
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
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingActivity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingActivity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_id'])!,
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
    );
  }

  @override
  $ReadingActivitiesTable createAlias(String alias) {
    return $ReadingActivitiesTable(attachedDatabase, alias);
  }
}

class ReadingActivity extends DataClass implements Insertable<ReadingActivity> {
  final String id;
  final String planId;
  final String bookKey;
  final int chapterNumber;
  final String action;
  final String activityDate;
  final String timezone;
  final DateTime happenedAt;
  final DateTime createdAt;
  final String syncStatus;
  const ReadingActivity(
      {required this.id,
      required this.planId,
      required this.bookKey,
      required this.chapterNumber,
      required this.action,
      required this.activityDate,
      required this.timezone,
      required this.happenedAt,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['book_key'] = Variable<String>(bookKey);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['action'] = Variable<String>(action);
    map['activity_date'] = Variable<String>(activityDate);
    map['timezone'] = Variable<String>(timezone);
    map['happened_at'] = Variable<DateTime>(happenedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ReadingActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ReadingActivitiesCompanion(
      id: Value(id),
      planId: Value(planId),
      bookKey: Value(bookKey),
      chapterNumber: Value(chapterNumber),
      action: Value(action),
      activityDate: Value(activityDate),
      timezone: Value(timezone),
      happenedAt: Value(happenedAt),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ReadingActivity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingActivity(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      action: serializer.fromJson<String>(json['action']),
      activityDate: serializer.fromJson<String>(json['activityDate']),
      timezone: serializer.fromJson<String>(json['timezone']),
      happenedAt: serializer.fromJson<DateTime>(json['happenedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'bookKey': serializer.toJson<String>(bookKey),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'action': serializer.toJson<String>(action),
      'activityDate': serializer.toJson<String>(activityDate),
      'timezone': serializer.toJson<String>(timezone),
      'happenedAt': serializer.toJson<DateTime>(happenedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ReadingActivity copyWith(
          {String? id,
          String? planId,
          String? bookKey,
          int? chapterNumber,
          String? action,
          String? activityDate,
          String? timezone,
          DateTime? happenedAt,
          DateTime? createdAt,
          String? syncStatus}) =>
      ReadingActivity(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        bookKey: bookKey ?? this.bookKey,
        chapterNumber: chapterNumber ?? this.chapterNumber,
        action: action ?? this.action,
        activityDate: activityDate ?? this.activityDate,
        timezone: timezone ?? this.timezone,
        happenedAt: happenedAt ?? this.happenedAt,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  ReadingActivity copyWithCompanion(ReadingActivitiesCompanion data) {
    return ReadingActivity(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingActivity(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('action: $action, ')
          ..write('activityDate: $activityDate, ')
          ..write('timezone: $timezone, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, bookKey, chapterNumber, action,
      activityDate, timezone, happenedAt, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingActivity &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.bookKey == this.bookKey &&
          other.chapterNumber == this.chapterNumber &&
          other.action == this.action &&
          other.activityDate == this.activityDate &&
          other.timezone == this.timezone &&
          other.happenedAt == this.happenedAt &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class ReadingActivitiesCompanion extends UpdateCompanion<ReadingActivity> {
  final Value<String> id;
  final Value<String> planId;
  final Value<String> bookKey;
  final Value<int> chapterNumber;
  final Value<String> action;
  final Value<String> activityDate;
  final Value<String> timezone;
  final Value<DateTime> happenedAt;
  final Value<DateTime> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ReadingActivitiesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.action = const Value.absent(),
    this.activityDate = const Value.absent(),
    this.timezone = const Value.absent(),
    this.happenedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingActivitiesCompanion.insert({
    required String id,
    required String planId,
    required String bookKey,
    required int chapterNumber,
    required String action,
    required String activityDate,
    required String timezone,
    required DateTime happenedAt,
    required DateTime createdAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planId = Value(planId),
        bookKey = Value(bookKey),
        chapterNumber = Value(chapterNumber),
        action = Value(action),
        activityDate = Value(activityDate),
        timezone = Value(timezone),
        happenedAt = Value(happenedAt),
        createdAt = Value(createdAt);
  static Insertable<ReadingActivity> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<String>? bookKey,
    Expression<int>? chapterNumber,
    Expression<String>? action,
    Expression<String>? activityDate,
    Expression<String>? timezone,
    Expression<DateTime>? happenedAt,
    Expression<DateTime>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (bookKey != null) 'book_key': bookKey,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (action != null) 'action': action,
      if (activityDate != null) 'activity_date': activityDate,
      if (timezone != null) 'timezone': timezone,
      if (happenedAt != null) 'happened_at': happenedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingActivitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? planId,
      Value<String>? bookKey,
      Value<int>? chapterNumber,
      Value<String>? action,
      Value<String>? activityDate,
      Value<String>? timezone,
      Value<DateTime>? happenedAt,
      Value<DateTime>? createdAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return ReadingActivitiesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      bookKey: bookKey ?? this.bookKey,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      action: action ?? this.action,
      activityDate: activityDate ?? this.activityDate,
      timezone: timezone ?? this.timezone,
      happenedAt: happenedAt ?? this.happenedAt,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('bookKey: $bookKey, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('action: $action, ')
          ..write('activityDate: $activityDate, ')
          ..write('timezone: $timezone, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
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
  late final $ReadingPlanTemplatesTable readingPlanTemplates =
      $ReadingPlanTemplatesTable(this);
  late final $UserReadingPlansTable userReadingPlans =
      $UserReadingPlansTable(this);
  late final $PlanScopeChaptersTable planScopeChapters =
      $PlanScopeChaptersTable(this);
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
        readingPlanTemplates,
        userReadingPlans,
        planScopeChapters,
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
typedef $$ReadingPlanTemplatesTableCreateCompanionBuilder
    = ReadingPlanTemplatesCompanion Function({
  required String id,
  required String templateKey,
  required String title,
  Value<String> description,
  Value<String> planType,
  Value<bool> isBuiltin,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ReadingPlanTemplatesTableUpdateCompanionBuilder
    = ReadingPlanTemplatesCompanion Function({
  Value<String> id,
  Value<String> templateKey,
  Value<String> title,
  Value<String> description,
  Value<String> planType,
  Value<bool> isBuiltin,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ReadingPlanTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingPlanTemplatesTable> {
  $$ReadingPlanTemplatesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planType => $composableBuilder(
      column: $table.planType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBuiltin => $composableBuilder(
      column: $table.isBuiltin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ReadingPlanTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingPlanTemplatesTable> {
  $$ReadingPlanTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planType => $composableBuilder(
      column: $table.planType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBuiltin => $composableBuilder(
      column: $table.isBuiltin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ReadingPlanTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingPlanTemplatesTable> {
  $$ReadingPlanTemplatesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get planType =>
      $composableBuilder(column: $table.planType, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltin =>
      $composableBuilder(column: $table.isBuiltin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingPlanTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingPlanTemplatesTable,
    ReadingPlanTemplate,
    $$ReadingPlanTemplatesTableFilterComposer,
    $$ReadingPlanTemplatesTableOrderingComposer,
    $$ReadingPlanTemplatesTableAnnotationComposer,
    $$ReadingPlanTemplatesTableCreateCompanionBuilder,
    $$ReadingPlanTemplatesTableUpdateCompanionBuilder,
    (
      ReadingPlanTemplate,
      BaseReferences<_$AppDatabase, $ReadingPlanTemplatesTable,
          ReadingPlanTemplate>
    ),
    ReadingPlanTemplate,
    PrefetchHooks Function()> {
  $$ReadingPlanTemplatesTableTableManager(
      _$AppDatabase db, $ReadingPlanTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingPlanTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingPlanTemplatesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingPlanTemplatesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateKey = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> planType = const Value.absent(),
            Value<bool> isBuiltin = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingPlanTemplatesCompanion(
            id: id,
            templateKey: templateKey,
            title: title,
            description: description,
            planType: planType,
            isBuiltin: isBuiltin,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateKey,
            required String title,
            Value<String> description = const Value.absent(),
            Value<String> planType = const Value.absent(),
            Value<bool> isBuiltin = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingPlanTemplatesCompanion.insert(
            id: id,
            templateKey: templateKey,
            title: title,
            description: description,
            planType: planType,
            isBuiltin: isBuiltin,
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

typedef $$ReadingPlanTemplatesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ReadingPlanTemplatesTable,
        ReadingPlanTemplate,
        $$ReadingPlanTemplatesTableFilterComposer,
        $$ReadingPlanTemplatesTableOrderingComposer,
        $$ReadingPlanTemplatesTableAnnotationComposer,
        $$ReadingPlanTemplatesTableCreateCompanionBuilder,
        $$ReadingPlanTemplatesTableUpdateCompanionBuilder,
        (
          ReadingPlanTemplate,
          BaseReferences<_$AppDatabase, $ReadingPlanTemplatesTable,
              ReadingPlanTemplate>
        ),
        ReadingPlanTemplate,
        PrefetchHooks Function()>;
typedef $$UserReadingPlansTableCreateCompanionBuilder
    = UserReadingPlansCompanion Function({
  required String id,
  required String templateKey,
  required String title,
  Value<bool> isActive,
  Value<String?> lastOpenedBookKey,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$UserReadingPlansTableUpdateCompanionBuilder
    = UserReadingPlansCompanion Function({
  Value<String> id,
  Value<String> templateKey,
  Value<String> title,
  Value<bool> isActive,
  Value<String?> lastOpenedBookKey,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
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

  ColumnFilters<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastOpenedBookKey => $composableBuilder(
      column: $table.lastOpenedBookKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastOpenedBookKey => $composableBuilder(
      column: $table.lastOpenedBookKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get templateKey => $composableBuilder(
      column: $table.templateKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get lastOpenedBookKey => $composableBuilder(
      column: $table.lastOpenedBookKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
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
            Value<String> templateKey = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> lastOpenedBookKey = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserReadingPlansCompanion(
            id: id,
            templateKey: templateKey,
            title: title,
            isActive: isActive,
            lastOpenedBookKey: lastOpenedBookKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateKey,
            required String title,
            Value<bool> isActive = const Value.absent(),
            Value<String?> lastOpenedBookKey = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserReadingPlansCompanion.insert(
            id: id,
            templateKey: templateKey,
            title: title,
            isActive: isActive,
            lastOpenedBookKey: lastOpenedBookKey,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
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
typedef $$PlanScopeChaptersTableCreateCompanionBuilder
    = PlanScopeChaptersCompanion Function({
  required String id,
  required String planId,
  required String bookKey,
  required int chapterNumber,
  required int orderIndex,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PlanScopeChaptersTableUpdateCompanionBuilder
    = PlanScopeChaptersCompanion Function({
  Value<String> id,
  Value<String> planId,
  Value<String> bookKey,
  Value<int> chapterNumber,
  Value<int> orderIndex,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PlanScopeChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $PlanScopeChaptersTable> {
  $$PlanScopeChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PlanScopeChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanScopeChaptersTable> {
  $$PlanScopeChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PlanScopeChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanScopeChaptersTable> {
  $$PlanScopeChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
      column: $table.chapterNumber, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlanScopeChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanScopeChaptersTable,
    PlanScopeChapter,
    $$PlanScopeChaptersTableFilterComposer,
    $$PlanScopeChaptersTableOrderingComposer,
    $$PlanScopeChaptersTableAnnotationComposer,
    $$PlanScopeChaptersTableCreateCompanionBuilder,
    $$PlanScopeChaptersTableUpdateCompanionBuilder,
    (
      PlanScopeChapter,
      BaseReferences<_$AppDatabase, $PlanScopeChaptersTable, PlanScopeChapter>
    ),
    PlanScopeChapter,
    PrefetchHooks Function()> {
  $$PlanScopeChaptersTableTableManager(
      _$AppDatabase db, $PlanScopeChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanScopeChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanScopeChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanScopeChaptersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> planId = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanScopeChaptersCompanion(
            id: id,
            planId: planId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            orderIndex: orderIndex,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planId,
            required String bookKey,
            required int chapterNumber,
            required int orderIndex,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanScopeChaptersCompanion.insert(
            id: id,
            planId: planId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            orderIndex: orderIndex,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanScopeChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanScopeChaptersTable,
    PlanScopeChapter,
    $$PlanScopeChaptersTableFilterComposer,
    $$PlanScopeChaptersTableOrderingComposer,
    $$PlanScopeChaptersTableAnnotationComposer,
    $$PlanScopeChaptersTableCreateCompanionBuilder,
    $$PlanScopeChaptersTableUpdateCompanionBuilder,
    (
      PlanScopeChapter,
      BaseReferences<_$AppDatabase, $PlanScopeChaptersTable, PlanScopeChapter>
    ),
    PlanScopeChapter,
    PrefetchHooks Function()>;
typedef $$ChapterProgressEntriesTableCreateCompanionBuilder
    = ChapterProgressEntriesCompanion Function({
  required String id,
  required String planId,
  required String bookKey,
  required int chapterNumber,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$ChapterProgressEntriesTableUpdateCompanionBuilder
    = ChapterProgressEntriesCompanion Function({
  Value<String> id,
  Value<String> planId,
  Value<String> bookKey,
  Value<int> chapterNumber,
  Value<bool> isCompleted,
  Value<DateTime?> completedAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
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

  ColumnFilters<String> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnFilters(column));

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

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnOrderings(column));

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

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
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
            Value<String> planId = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChapterProgressEntriesCompanion(
            id: id,
            planId: planId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            isCompleted: isCompleted,
            completedAt: completedAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planId,
            required String bookKey,
            required int chapterNumber,
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChapterProgressEntriesCompanion.insert(
            id: id,
            planId: planId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            isCompleted: isCompleted,
            completedAt: completedAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
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
  required String planId,
  required String bookKey,
  required int chapterNumber,
  required String action,
  required String activityDate,
  required String timezone,
  required DateTime happenedAt,
  required DateTime createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$ReadingActivitiesTableUpdateCompanionBuilder
    = ReadingActivitiesCompanion Function({
  Value<String> id,
  Value<String> planId,
  Value<String> bookKey,
  Value<int> chapterNumber,
  Value<String> action,
  Value<String> activityDate,
  Value<String> timezone,
  Value<DateTime> happenedAt,
  Value<DateTime> createdAt,
  Value<String> syncStatus,
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

  ColumnFilters<String> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

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
            Value<String> planId = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<int> chapterNumber = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> activityDate = const Value.absent(),
            Value<String> timezone = const Value.absent(),
            Value<DateTime> happenedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingActivitiesCompanion(
            id: id,
            planId: planId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            action: action,
            activityDate: activityDate,
            timezone: timezone,
            happenedAt: happenedAt,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planId,
            required String bookKey,
            required int chapterNumber,
            required String action,
            required String activityDate,
            required String timezone,
            required DateTime happenedAt,
            required DateTime createdAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingActivitiesCompanion.insert(
            id: id,
            planId: planId,
            bookKey: bookKey,
            chapterNumber: chapterNumber,
            action: action,
            activityDate: activityDate,
            timezone: timezone,
            happenedAt: happenedAt,
            createdAt: createdAt,
            syncStatus: syncStatus,
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
  $$ReadingPlanTemplatesTableTableManager get readingPlanTemplates =>
      $$ReadingPlanTemplatesTableTableManager(_db, _db.readingPlanTemplates);
  $$UserReadingPlansTableTableManager get userReadingPlans =>
      $$UserReadingPlansTableTableManager(_db, _db.userReadingPlans);
  $$PlanScopeChaptersTableTableManager get planScopeChapters =>
      $$PlanScopeChaptersTableTableManager(_db, _db.planScopeChapters);
  $$ChapterProgressEntriesTableTableManager get chapterProgressEntries =>
      $$ChapterProgressEntriesTableTableManager(
          _db, _db.chapterProgressEntries);
  $$ReadingActivitiesTableTableManager get readingActivities =>
      $$ReadingActivitiesTableTableManager(_db, _db.readingActivities);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
