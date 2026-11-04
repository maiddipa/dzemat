import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../i18n/dzemat_locale_controller.dart';

import '../models/cloudinary_image.dart';
import '../services/cloudinary_service.dart';
import '../widgets/cloudinary_grid_item.dart';
import 'image_viewer_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({
    super.key,
  });

  @override
  State<GalleryPage> createState() =>
      _GalleryPageState();
}

class _GalleryPageState
    extends State<GalleryPage> {
  final CloudinaryService _service =
      CloudinaryService();

  final PageController _pageController =
      PageController();

 static const String _galleriesJsonUrl =
    'https://res.cloudinary.com/dgyy4rc34/raw/upload/v1790158917/dg9t9evbpzgdis4kmgnu.json';

  List<GalleryItem> _galleries =
      const [];

  List<CloudinaryImage> _images =
      const [];

  String _selectedTag = '';

  int _currentIndex = 0;

  bool _loadingGalleries = true;
  bool _loadingImages = false;

  String? _error;

  bool get _isLoading =>
      _loadingGalleries ||
      _loadingImages;

  CloudinaryImage? get _currentImage {
    if (_images.isEmpty) {
      return null;
    }

    if (
      _currentIndex < 0 ||
      _currentIndex >=
          _images.length
    ) {
      return _images.first;
    }

    return _images[_currentIndex];
  }

  @override
  void initState() {
    super.initState();
    _loadGalleries();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /*
   * Učitava galerije iz Cloudinary JSON-a.
   */
  Future<void> _loadGalleries() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _loadingGalleries = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        '$_galleriesJsonUrl'
        '?refresh='
        '${DateTime.now().millisecondsSinceEpoch}',
      );

      debugPrint(
        'Loading galleries JSON: $uri',
      );

      final response =
          await http.get(
        uri,
        headers: const {
          'Accept':
              'application/json',
        },
      );

      if (
        response.statusCode < 200 ||
        response.statusCode >= 300
      ) {
        throw Exception(
          'JSON HTTP '
          '${response.statusCode}',
        );
      }

      final dynamic decoded =
          jsonDecode(
        response.body,
      );

      final List<dynamic> values;

      if (decoded is List) {
        values = decoded;
      } else if (
        decoded is Map &&
        decoded['galleries'] is List
      ) {
        values =
            decoded['galleries']
                as List<dynamic>;
      } else {
        values = [];
      }

      final galleries =
          values
              .map(
                _convertGallery,
              )
              .whereType<
                  GalleryItem>()
              .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _galleries = galleries;
        _loadingGalleries = false;

        final selectedExists =
            galleries.any(
          (gallery) =>
              gallery.tag ==
              _selectedTag,
        );

        if (
          !selectedExists &&
          galleries.isNotEmpty
        ) {
          _selectedTag =
              galleries.first.tag;
        }
      });

      if (_selectedTag.isNotEmpty) {
        await _loadImages();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingGalleries = false;

        _error =
            'Galerije se nisu mogle '
            'učitati.\n$error';
      });
    }
  }

  GalleryItem? _convertGallery(
    dynamic value,
  ) {
    if (value is String) {
      final tag =
          value.trim();

      if (tag.isEmpty) {
        return null;
      }

      return GalleryItem(
        name: tag,
        tag: tag,
      );
    }

    if (value is Map) {
      final tag =
          value['tag']
                  ?.toString()
                  .trim() ??
              '';

      if (tag.isEmpty) {
        return null;
      }

      final rawName =
          value['name']
                  ?.toString()
                  .trim() ??
              '';

      return GalleryItem(
        name:
            rawName.isEmpty
                ? tag
                : rawName,
        tag: tag,
      );
    }

    return null;
  }

  /*
   * Učitava slike iz izabrane galerije.
   */
  Future<void> _loadImages() async {
    final tag =
        _selectedTag.trim();

    if (tag.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _loadingImages = true;
      _error = null;
      _images = const [];
      _currentIndex = 0;
    });

    try {
      final images =
          await _service
              .getImagesByTag(
        tag,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _images = images;
        _currentIndex = 0;
        _loadingImages = false;
      });

      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) {
          if (
            _pageController.hasClients
          ) {
            _pageController.jumpToPage(
              0,
            );
          }
        },
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _images = const [];
        _currentIndex = 0;
        _loadingImages = false;

        _error =
            'Slike se nisu mogle '
            'učitati.\n$error';
      });
    }
  }

  /*
   * Ponovo učitava JSON i slike.
   */
  Future<void> _reloadAll() async {
    await _loadGalleries();
  }

  /*
   * Promjena galerije.
   */
  Future<void> _selectGallery(
    String? tag,
  ) async {
    if (
      tag == null ||
      tag.trim().isEmpty
    ) {
      return;
    }

    setState(() {
      _selectedTag =
          tag.trim();

      _currentIndex = 0;
    });

    await _loadImages();
  }

  void _previousPhoto() {
    if (_images.isEmpty) {
      return;
    }

    final targetIndex =
        _currentIndex == 0
            ? _images.length - 1
            : _currentIndex - 1;

    _goToPhoto(
      targetIndex,
    );
  }

  void _nextPhoto() {
    if (_images.isEmpty) {
      return;
    }

    final targetIndex =
        _currentIndex ==
                _images.length - 1
            ? 0
            : _currentIndex + 1;

    _goToPhoto(
      targetIndex,
    );
  }

  void _goToPhoto(
    int index,
  ) {
    if (
      index < 0 ||
      index >= _images.length
    ) {
      return;
    }

    _pageController.animateToPage(
      index,
      duration:
          const Duration(
        milliseconds: 280,
      ),
      curve:
          Curves.easeInOut,
    );
  }

  void _openImage(
    CloudinaryImage image,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ImageViewerPage(
          image: image,
        ),
      ),
    );
  }

  void _openCurrentImage() {
    final image =
        _currentImage;

    if (image == null) {
      return;
    }

    _openImage(image);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Džemat Bochum',
        ),

        actions: [
          IconButton(
            tooltip: DzematLocaleController.instance.isGerman ? 'Aktualisieren' : 'Osvježi',

            onPressed:
                _isLoading
                    ? null
                    : _reloadAll,

            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _reloadAll,

        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.all(
            16,
          ),

          children: [
            Text(
              'Galerija',

              style:
                  Theme.of(context)
                      .textTheme
                      .headlineMedium,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              'Izaberite galeriju '
              'i pregledajte slike.',

              style:
                  Theme.of(context)
                      .textTheme
                      .bodyMedium,
            ),

            const SizedBox(
              height: 20,
            ),

            if (_galleries.isNotEmpty)
              DropdownButtonFormField<
                  String>(
                value:
                    _selectedTag.isEmpty
                        ? null
                        : _selectedTag,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Izaberite galeriju',

                  border:
                      OutlineInputBorder(),
                ),

                items:
                    _galleries
                        .map(
                          (
                            gallery,
                          ) =>
                              DropdownMenuItem<
                                  String>(
                            value:
                                gallery.tag,

                            child:
                                Text(
                              gallery.name,
                            ),
                          ),
                        )
                        .toList(),

                onChanged:
                    _isLoading
                        ? null
                        : _selectGallery,
              ),

            const SizedBox(
              height: 20,
            ),

            if (_isLoading)
              const Padding(
                padding:
                    EdgeInsets.all(
                  40,
                ),

                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              ),

            if (
              !_isLoading &&
              _error != null
            )
              ErrorCard(
                message: _error!,
                onRetry: _reloadAll,
              ),

            if (
              !_isLoading &&
              _error == null &&
              _images.isEmpty
            )
              const Padding(
                padding:
                    EdgeInsets.all(
                  40,
                ),

                child: Center(
                  child: Text(
                    'Galerija nema slika.',
                    textAlign:
                        TextAlign.center,
                  ),
                ),
              ),

            if (
              !_isLoading &&
              _images.isNotEmpty
            )
              _buildCarousel(
                context,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(
    BuildContext context,
  ) {
    final screenWidth =
        MediaQuery.sizeOf(
      context,
    ).width;

    final carouselHeight =
        screenWidth < 600
            ? 400.0
            : 600.0;

    return Column(
      children: [
        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            18,
          ),

          child: Container(
            width:
                double.infinity,

            height:
                carouselHeight,

            color:
                Colors.black,

            child: Stack(
              alignment:
                  Alignment.center,

              children: [
                PageView.builder(
                  controller:
                      _pageController,

                  itemCount:
                      _images.length,

                  onPageChanged:
                      (index) {
                    setState(() {
                      _currentIndex =
                          index;
                    });
                  },

                  itemBuilder:
                      (
                    context,
                    index,
                  ) {
                    final image =
                        _images[index];

                    return CloudinaryGridItem(
                      image: image,

                      onTap: () =>
                          _openImage(
                        image,
                      ),
                    );
                  },
                ),

                if (
                  _images.length > 1
                )
                  Positioned(
                    left: 8,

                    child:
                        CarouselButton(
                      icon:
                          Icons
                              .chevron_left,

                      tooltip:
                          'Prethodna slika',

                      onPressed:
                          _previousPhoto,
                    ),
                  ),

                if (
                  _images.length > 1
                )
                  Positioned(
                    right: 8,

                    child:
                        CarouselButton(
                      icon:
                          Icons
                              .chevron_right,

                      tooltip:
                          'Sljedeća slika',

                      onPressed:
                          _nextPhoto,
                    ),
                  ),

                Positioned(
                  right: 12,
                  bottom: 12,

                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.black54,

                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child: Text(
                      '${_currentIndex + 1}'
                      ' / '
                      '${_images.length}',

                      style:
                          const TextStyle(
                        color:
                            Colors.white,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 12,
                  bottom: 12,

                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          Colors.black54,

                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child:
                        const Row(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        Icon(
                          Icons.zoom_in,

                          color:
                              Colors.white,

                          size: 18,
                        ),

                        SizedBox(
                          width: 6,
                        ),

                        Text(
                          'Klikni za veću sliku',

                          style:
                              TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (
          _images.length > 1
        ) ...[
          const SizedBox(
            height: 16,
          ),

          Wrap(
            alignment:
                WrapAlignment.center,

            spacing: 8,
            runSpacing: 8,

            children:
                List.generate(
              _images.length,

              (index) =>
                  GestureDetector(
                onTap: () =>
                    _goToPhoto(
                  index,
                ),

                child:
                    AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),

                  width:
                      index ==
                              _currentIndex
                          ? 24
                          : 10,

                  height: 10,

                  decoration:
                      BoxDecoration(
                    color:
                        index ==
                                _currentIndex
                            ? Theme.of(
                                context,
                              )
                                .colorScheme
                                .primary
                            : Colors.grey
                                .shade400,

                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

        const SizedBox(
          height: 12,
        ),

        TextButton.icon(
          onPressed:
              _openCurrentImage,

          icon:
              const Icon(
            Icons.fullscreen,
          ),

          label:
              const Text(
            'Otvori punu veličinu',
          ),
        ),
      ],
    );
  }
}

class GalleryItem {
  final String name;
  final String tag;

  const GalleryItem({
    required this.name,
    required this.tag,
  });
}

class CarouselButton
    extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const CarouselButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,

      style:
          IconButton.styleFrom(
        backgroundColor:
            Colors.black54,

        foregroundColor:
            Colors.white,
      ),

      icon: Icon(
        icon,
        size: 34,
      ),
    );
  }
}

class ErrorCard
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      color:
          Theme.of(context)
              .colorScheme
              .errorContainer,

      child: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              message,
              textAlign:
                  TextAlign.center,
            ),

            const SizedBox(
              height: 16,
            ),

            FilledButton.icon(
              onPressed:
                  onRetry,

              icon:
                  const Icon(
                Icons.refresh,
              ),

              label:
                  const Text(
                'Pokušaj ponovo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}