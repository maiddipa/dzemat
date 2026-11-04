class SurahInfo {
  final int number;
  final String name;
  final String englishName;
  final String translatedName;
  final int numberOfAyahs;
  final String revelationType;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.englishName,
    required this.translatedName,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  factory SurahInfo.fromJson(
    Map<String, dynamic> json,
  ) {
    return SurahInfo(
      number: json['number'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      englishName:
          json['englishName'] as String? ?? '',
      translatedName:
          json['englishNameTranslation']
                  as String? ??
              '',
      numberOfAyahs:
          json['numberOfAyahs'] as int? ?? 0,
      revelationType:
          json['revelationType'] as String? ??
              '',
    );
  }
}

class QuranAyah {
  final int number;
  final int numberInSurah;
  final int juz;
  final String arabicText;
  final String translation;
  final String audioUrl;

  const QuranAyah({
    required this.number,
    required this.numberInSurah,
    required this.juz,
    required this.arabicText,
    required this.translation,
    required this.audioUrl,
  });
}

class SurahContent {
  final SurahInfo surah;
  final List<QuranAyah> ayahs;

  const SurahContent({
    required this.surah,
    required this.ayahs,
  });
}

class QuranApiException implements Exception {
  final String message;

  const QuranApiException(this.message);

  @override
  String toToString() => message;

  @override
  String toString() => message;
}