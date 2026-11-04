import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/quran_models.dart';
import '../services/quran_service.dart';

class SurahPage extends StatefulWidget {
  final int surahNumber;

  const SurahPage({
    super.key,
    required this.surahNumber,
  });

  @override
  State<SurahPage> createState() =>
      _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  final QuranService _service = QuranService();
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<int?>? _indexSubscription;

  SurahContent? _content;

  bool _loading = true;
  bool _preparingAudio = false;

  String _error = '';
  int _currentAyahIndex = 0;

  @override
  void initState() {
    super.initState();

    _indexSubscription =
        _player.currentIndexStream.listen(
      (int? index) {
        if (index == null || !mounted) {
          return;
        }

        setState(() {
          _currentAyahIndex = index;
        });
      },
    );

    _loadSurah();
  }

  @override
  void dispose() {
    _indexSubscription?.cancel();
    _player.dispose();

    super.dispose();
  }

  Future<void> _loadSurah() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = '';
      });
    }

    try {
      await _player.stop();

      final SurahContent content =
          await _service.getSurah(
        widget.surahNumber,
      );

      if (!mounted) return;

      setState(() {
        _content = content;
        _loading = false;
        _currentAyahIndex = 0;
      });

      await _prepareAudio(content);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _prepareAudio(
    SurahContent content,
  ) async {
    final List<AudioSource> sources =
        content.ayahs
            .where(
              (QuranAyah ayah) =>
                  ayah.audioUrl.isNotEmpty,
            )
            .map(
              (QuranAyah ayah) =>
                  AudioSource.uri(
                Uri.parse(ayah.audioUrl),
              ),
            )
            .toList(growable: false);

    if (sources.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        _preparingAudio = true;
      });
    }

    try {
      await _player.setAudioSources(
        sources,
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
    } catch (error) {
      debugPrint(
        'Audio se nije mogao pripremiti: $error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _preparingAudio = false;
        });
      }
    }
  }

  Future<void> _playAyah(int index) async {
    if (_preparingAudio) return;

    try {
      await _player.seek(
        Duration.zero,
        index: index,
      );

      await _player.play();
    } catch (error) {
      _showAudioError(error);
    }
  }

  Future<void> _togglePlayback() async {
    if (_preparingAudio) return;

    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (error) {
      _showAudioError(error);
    }
  }

  Future<void> _previousAyah() async {
    if (_preparingAudio) return;

    try {
      if (_currentAyahIndex <= 0) {
        await _player.seek(
          Duration.zero,
          index: 0,
        );

        return;
      }

      await _player.seek(
        Duration.zero,
        index: _currentAyahIndex - 1,
      );

      await _player.play();
    } catch (error) {
      _showAudioError(error);
    }
  }

  Future<void> _nextAyah() async {
    if (_preparingAudio) return;

    final SurahContent? content = _content;

    if (content == null) return;

    final bool isLastAyah =
        _currentAyahIndex >=
        content.ayahs.length - 1;

    if (isLastAyah) {
      return;
    }

    try {
      await _player.seek(
        Duration.zero,
        index: _currentAyahIndex + 1,
      );

      await _player.play();
    } catch (error) {
      _showAudioError(error);
    }
  }

  void _showAudioError(Object error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Audio se ne može pokrenuti: $error',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: Text(
          _content?.surah.englishName ??
              'Sura ${widget.surahNumber}',
        ),
        backgroundColor:
            const Color(0xFF006962),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Osvježi',
            onPressed:
                _loading ? null : _loadSurah,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _content == null
              ? null
              : _buildAudioPlayer(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF006962),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return _buildErrorPage();
    }

    final SurahContent? content = _content;

    if (content == null ||
        content.ayahs.isEmpty) {
      return const Center(
        child: Text(
          'Sura nema dostupnih ajeta.',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        12,
        125,
      ),
      itemCount: content.ayahs.length + 1,
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        if (index == 0) {
          return _buildSurahHeader(
            content.surah,
          );
        }

        final int ayahIndex = index - 1;
        final QuranAyah ayah =
            content.ayahs[ayahIndex];

        return _buildAyahCard(
          ayah,
          ayahIndex,
        );
      },
    );
  }

  Widget _buildErrorPage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 72,
              color: Color(0xFF006962),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sura se nije mogla učitati',
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
            FilledButton.icon(
              onPressed: _loadSurah,
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Pokušaj ponovo',
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF006962),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahHeader(
    SurahInfo surah,
  ) {
    return Card(
      color: const Color(0xFF006962),
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Text(
              surah.name,
              textDirection:
                  TextDirection.rtl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              surah.englishName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${surah.numberOfAyahs} ajeta'
              ' • '
              '${surah.revelationType}',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAyahCard(
    QuranAyah ayah,
    int ayahIndex,
  ) {
    final bool isCurrent =
        ayahIndex == _currentAyahIndex;

    return Card(
      color: isCurrent
          ? const Color(0xFFE3F2EE)
          : Colors.white,
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
        side: BorderSide(
          color: isCurrent
              ? const Color(0xFF006962)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      const Color(
                    0xFF006962,
                  ),
                  foregroundColor:
                      Colors.white,
                  child: Text(
                    '${ayah.numberInSurah}',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Pusti ajet',
                  onPressed:
                      _preparingAudio
                          ? null
                          : () => _playAyah(
                                ayahIndex,
                              ),
                  icon: const Icon(
                    Icons.play_circle_outline,
                  ),
                  color: const Color(
                    0xFF006962,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ayah.arabicText,
              textAlign: TextAlign.right,
              textDirection:
                  TextDirection.rtl,
              style: const TextStyle(
                fontSize: 29,
                height: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Divider(height: 30),
            Text(
              ayah.translation,
              style: const TextStyle(
                fontSize: 17,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Prijevod: Besim Korkut',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return SafeArea(
      top: false,
      child: Material(
        elevation: 16,
        color: Colors.white,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          child: StreamBuilder<PlayerState>(
            stream:
                _player.playerStateStream,
            builder: (
              BuildContext context,
              AsyncSnapshot<PlayerState>
                  snapshot,
            ) {
              final PlayerState? state =
                  snapshot.data;

              final bool isPlaying =
                  state?.playing ?? false;

              final ProcessingState
                  processingState =
                  state?.processingState ??
                      ProcessingState.idle;

              final bool waiting =
                  _preparingAudio ||
                      processingState ==
                          ProcessingState
                              .loading ||
                      processingState ==
                          ProcessingState
                              .buffering;

              return Row(
                children: [
                  IconButton(
                    tooltip:
                        'Prethodni ajet',
                    onPressed: waiting
                        ? null
                        : _previousAyah,
                    icon: const Icon(
                      Icons.skip_previous,
                    ),
                  ),
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: waiting
                        ? const Padding(
                            padding:
                                EdgeInsets.all(
                              13,
                            ),
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Color(
                                0xFF006962,
                              ),
                            ),
                          )
                        : IconButton.filled(
                            tooltip:
                                isPlaying
                                    ? 'Pauza'
                                    : 'Pokreni',
                            onPressed:
                                _togglePlayback,
                            style:
                                IconButton
                                    .styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFF006962,
                              ),
                            ),
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          ),
                  ),
                  IconButton(
                    tooltip: 'Sljedeći ajet',
                    onPressed: waiting
                        ? null
                        : _nextAyah,
                    icon: const Icon(
                      Icons.skip_next,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ajet '
                      '${_currentAyahIndex + 1}'
                      ' / '
                      '${_content?.ayahs.length ?? 0}',
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}