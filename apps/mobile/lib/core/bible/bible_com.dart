/// YouVersion Bible.com deep links (`/bible/{versionId}/{BOOK}.{chapter}.{ABBR}`).
class BibleComVersion {
  const BibleComVersion({
    required this.id,
    required this.abbr,
    required this.label,
  });

  final String id;
  final String abbr;
  final String label;

  static const niv = BibleComVersion(
    id: '111',
    abbr: 'NIV',
    label: 'NIV',
  );

  static const kjv = BibleComVersion(
    id: '1',
    abbr: 'KJV',
    label: 'KJV',
  );

  static const esv = BibleComVersion(
    id: '59',
    abbr: 'ESV',
    label: 'ESV',
  );

  static const defaultVersion = niv;

  static const List<BibleComVersion> selectable = [niv, kjv, esv];

  static BibleComVersion? tryParse({required String? id, required String? abbr}) {
    if (id == null || abbr == null || id.isEmpty || abbr.isEmpty) return null;
    for (final version in selectable) {
      if (version.id == id && version.abbr == abbr) return version;
    }
    return BibleComVersion(id: id, abbr: abbr, label: abbr);
  }
}

abstract final class BibleCom {
  static const _bookKeyToUsfm = <String, String>{
    'genesis': 'GEN',
    'exodus': 'EXO',
    'leviticus': 'LEV',
    'numbers': 'NUM',
    'deuteronomy': 'DEU',
    'joshua': 'JOS',
    'judges': 'JDG',
    'ruth': 'RUT',
    '1_samuel': '1SA',
    '2_samuel': '2SA',
    '1_kings': '1KI',
    '2_kings': '2KI',
    '1_chronicles': '1CH',
    '2_chronicles': '2CH',
    'ezra': 'EZR',
    'nehemiah': 'NEH',
    'esther': 'EST',
    'job': 'JOB',
    'psalms': 'PSA',
    'proverbs': 'PRO',
    'ecclesiastes': 'ECC',
    'song_of_songs': 'SNG',
    'isaiah': 'ISA',
    'jeremiah': 'JER',
    'lamentations': 'LAM',
    'ezekiel': 'EZK',
    'daniel': 'DAN',
    'hosea': 'HOS',
    'joel': 'JOL',
    'amos': 'AMO',
    'obadiah': 'OBA',
    'jonah': 'JON',
    'micah': 'MIC',
    'nahum': 'NAH',
    'habakkuk': 'HAB',
    'zephaniah': 'ZEP',
    'haggai': 'HAG',
    'zechariah': 'ZEC',
    'malachi': 'MAL',
    'matthew': 'MAT',
    'mark': 'MRK',
    'luke': 'LUK',
    'john': 'JHN',
    'acts': 'ACT',
    'romans': 'ROM',
    '1_corinthians': '1CO',
    '2_corinthians': '2CO',
    'galatians': 'GAL',
    'ephesians': 'EPH',
    'philippians': 'PHP',
    'colossians': 'COL',
    '1_thessalonians': '1TH',
    '2_thessalonians': '2TH',
    '1_timothy': '1TI',
    '2_timothy': '2TI',
    'titus': 'TIT',
    'philemon': 'PHM',
    'hebrews': 'HEB',
    'james': 'JAS',
    '1_peter': '1PE',
    '2_peter': '2PE',
    '1_john': '1JN',
    '2_john': '2JN',
    '3_john': '3JN',
    'jude': 'JUD',
    'revelation': 'REV',
  };

  static String? bookUsfm(String bookKey) => _bookKeyToUsfm[bookKey];

  /// e.g. `https://www.bible.com/bible/111/GEN.1.NIV`
  static Uri? chapterUrl({
    required BibleComVersion version,
    required String bookKey,
    required int chapter,
  }) {
    final book = bookUsfm(bookKey);
    if (book == null || chapter < 1) return null;
    return Uri.parse(
      'https://www.bible.com/bible/${version.id}/$book.$chapter.${version.abbr}',
    );
  }
}
