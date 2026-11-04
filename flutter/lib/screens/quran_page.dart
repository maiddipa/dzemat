import 'package:flutter/material.dart';

import '../models/quran_models.dart';
import '../services/quran_service.dart';
import 'surah_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() =>
      _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final QuranService _service =
      QuranService();

  final TextEditingController
      _searchController =
      TextEditingController();

  List<SurahInfo> _surahs = [];
  List<SurahInfo> _filteredSurahs = [];

  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();

    _loadSurahs();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadSurahs() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }

    try {
      final List<SurahInfo> surahs =
          await _service.getSurahs();

      if (!mounted) return;

      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _search(String value) {
    final String query =
        value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = _surahs;
        return;
      }

      _filteredSurahs =
          _surahs.where((SurahInfo surah) {
        final String number =
            surah.number.toString();

        final String arabicName =
            surah.name.toLowerCase();

        final String englishName =
            surah.englishName.toLowerCase();

        final String translatedName =
            surah.translatedName.toLowerCase();

        return number.contains(query) ||
            arabicName.contains(query) ||
            englishName.contains(query) ||
            translatedName.contains(query);
      }).toList(growable: false);
    });
  }

  void _clearSearch() {
    _searchController.clear();

    _search('');
  }

  void _openSurah(SurahInfo surah) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (
          BuildContext context,
        ) {
          return SurahPage(
            surahNumber: surah.number,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text("Kur'an"),
        backgroundColor:
            const Color(0xFF006962),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Osvježi',
            onPressed:
                _loading ? null : _loadSurahs,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadSurahs,
        color: const Color(0xFF006962),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _surahs.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 230),
          Center(
            child: CircularProgressIndicator(
              color: Color(0xFF006962),
            ),
          ),
        ],
      );
    }

    if (_error.isNotEmpty &&
        _surahs.isEmpty) {
      return _buildErrorPage();
    }

    return Column(
      children: [
        _buildSearchField(),
        Expanded(
          child: _buildSurahList(),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: TextField(
        controller: _searchController,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: 'Pretraži suru ili broj',
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                      tooltip:
                          'Obriši pretragu',
                      onPressed: _clearSearch,
                      icon: const Icon(
                        Icons.close,
                      ),
                    )
                  : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF006962),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    if (_filteredSurahs.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Nema pronađenih sura.',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        14,
        0,
        14,
        24,
      ),
      itemCount: _filteredSurahs.length,
      separatorBuilder: (
        BuildContext context,
        int index,
      ) {
        return const SizedBox(height: 8);
      },
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        final SurahInfo surah =
            _filteredSurahs[index];

        return _buildSurahItem(surah);
      },
    );
  }

  Widget _buildSurahItem(
    SurahInfo surah,
  ) {
    return Card(
      elevation: 1,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: () => _openSurah(surah),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    const Color(
                  0xFF006962,
                ),
                foregroundColor:
                    Colors.white,
                child: Text(
                  '${surah.number}',
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.englishName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${surah.numberOfAyahs} ajeta'
                      ' • '
                      '${surah.revelationType}',
                      style: TextStyle(
                        color:
                            Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    surah.name,
                    textDirection:
                        TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF006962),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorPage() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 110),
        const Icon(
          Icons.cloud_off_outlined,
          size: 72,
          color: Color(0xFF006962),
        ),
        const SizedBox(height: 20),
        const Text(
          'Sure se nisu mogle učitati',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _error,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        Center(
          child: FilledButton.icon(
            onPressed: _loadSurahs,
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text(
              'Pokušaj ponovo',
            ),
            style: FilledButton.styleFrom(
              backgroundColor:
                  const Color(
                0xFF006962,
              ),
            ),
          ),
        ),
      ],
    );
  }
}