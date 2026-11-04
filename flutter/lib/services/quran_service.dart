import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quran_models.dart';

class QuranService {
  static const String _baseUrl =
      'https://api.alquran.cloud/v1';

  static const String _arabicEdition =
      'quran-uthmani';

  static const String _translationEdition =
      'bs.korkut';

  static const String _audioEdition =
      'ar.alafasy';

  Future<List<SurahInfo>> getSurahs() async {
    final Uri uri = Uri.parse(
      '$_baseUrl/surah',
    );

    final http.Response response =
        await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw QuranApiException(
        'Nije moguće učitati sure. '
        'HTTP ${response.statusCode}',
      );
    }

    final dynamic decoded =
        jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const QuranApiException(
        'Neispravan odgovor servera.',
      );
    }

    final dynamic rawData = decoded['data'];

    if (rawData is! List) {
      throw const QuranApiException(
        'Lista sura nije pronađena.',
      );
    }

    return rawData
        .whereType<Map>()
        .map(
          (item) => SurahInfo.fromJson(
            item.map(
              (key, value) => MapEntry(
                key.toString(),
                value,
              ),
            ),
          ),
        )
        .where(
          (surah) => surah.number > 0,
        )
        .toList(growable: false);
  }

  Future<SurahContent> getSurah(
    int surahNumber,
  ) async {
    if (surahNumber < 1 ||
        surahNumber > 114) {
      throw const QuranApiException(
        'Broj sure mora biti između 1 i 114.',
      );
    }

    final List<dynamic> responses =
        await Future.wait([
      _getEdition(
        surahNumber,
        _arabicEdition,
      ),
      _getEdition(
        surahNumber,
        _translationEdition,
      ),
      _getEdition(
        surahNumber,
        _audioEdition,
      ),
    ]);

    final Map<String, dynamic> arabic =
        responses[0] as Map<String, dynamic>;

    final Map<String, dynamic> translation =
        responses[1] as Map<String, dynamic>;

    final Map<String, dynamic> audio =
        responses[2] as Map<String, dynamic>;

    final List<dynamic> arabicAyahs =
        arabic['ayahs'] as List? ?? [];

    final List<dynamic> translatedAyahs =
        translation['ayahs'] as List? ?? [];

    final List<dynamic> audioAyahs =
        audio['ayahs'] as List? ?? [];

    final int ayahCount = [
      arabicAyahs.length,
      translatedAyahs.length,
      audioAyahs.length,
    ].reduce(
      (current, next) =>
          current < next ? current : next,
    );

    final List<QuranAyah> ayahs = [];

    for (int index = 0;
        index < ayahCount;
        index++) {
      final Map<String, dynamic>
          arabicAyah = _asStringMap(
        arabicAyahs[index],
      );

      final Map<String, dynamic>
          translatedAyah = _asStringMap(
        translatedAyahs[index],
      );

      final Map<String, dynamic>
          audioAyah = _asStringMap(
        audioAyahs[index],
      );

      ayahs.add(
        QuranAyah(
          number:
              arabicAyah['number'] as int? ??
                  0,
          numberInSurah:
              arabicAyah['numberInSurah']
                      as int? ??
                  index + 1,
          juz:
              arabicAyah['juz'] as int? ??
                  0,
          arabicText:
              arabicAyah['text'] as String? ??
                  '',
          translation:
              translatedAyah['text']
                      as String? ??
                  '',
          audioUrl:
              audioAyah['audio'] as String? ??
                  '',
        ),
      );
    }

    final SurahInfo surahInfo = SurahInfo(
      number: arabic['number'] as int? ??
          surahNumber,
      name: arabic['name'] as String? ?? '',
      englishName:
          arabic['englishName'] as String? ??
              '',
      translatedName:
          arabic['englishNameTranslation']
                  as String? ??
              '',
      numberOfAyahs:
          arabic['numberOfAyahs'] as int? ??
              ayahs.length,
      revelationType:
          arabic['revelationType']
                  as String? ??
              '',
    );

    return SurahContent(
      surah: surahInfo,
      ayahs: ayahs,
    );
  }

  Future<Map<String, dynamic>> _getEdition(
    int surahNumber,
    String edition,
  ) async {
    final Uri uri = Uri.parse(
      '$_baseUrl/surah/'
      '$surahNumber/$edition',
    );

    final http.Response response =
        await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw QuranApiException(
        'Nije moguće učitati suru '
        '$surahNumber. '
        'HTTP ${response.statusCode}',
      );
    }

    final dynamic decoded =
        jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const QuranApiException(
        'Neispravan odgovor servera.',
      );
    }

    final dynamic data = decoded['data'];

    if (data is! Map) {
      throw const QuranApiException(
        'Sadržaj sure nije pronađen.',
      );
    }

    return data.map(
      (key, value) => MapEntry(
        key.toString(),
        value,
      ),
    );
  }

  Map<String, dynamic> _asStringMap(
    dynamic value,
  ) {
    if (value is! Map) {
      return {};
    }

    return value.map(
      (key, item) => MapEntry(
        key.toString(),
        item,
      ),
    );
  }
}