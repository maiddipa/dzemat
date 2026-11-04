import 'package:flutter/material.dart';

import '../models/cloudinary_image.dart';
import '../services/cloudinary_service.dart';

class ImageViewerPage
    extends StatefulWidget {
  final CloudinaryImage image;

  const ImageViewerPage({
    super.key,
    required this.image,
  });

  @override
  State<ImageViewerPage> createState() =>
      _ImageViewerPageState();
}

class _ImageViewerPageState
    extends State<ImageViewerPage> {
  final CloudinaryService _service =
      CloudinaryService();

  final TransformationController
      _transformationController =
      TransformationController();

  TapDownDetails?
      _doubleTapDetails;

  bool _showControls = true;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls =
          !_showControls;
    });
  }

  void _onDoubleTapDown(
    TapDownDetails details,
  ) {
    _doubleTapDetails = details;
  }

  /*
   * Dupli klik:
   * - ako je slika normalna, povećava je
   * - ako je povećana, vraća je na početak
   */
  void _onDoubleTap() {
    final currentScale =
        _transformationController
            .value
            .getMaxScaleOnAxis();

    if (currentScale > 1.0) {
      _resetZoom();
      return;
    }

    final position =
        _doubleTapDetails
                ?.localPosition ??
            Offset.zero;

    const zoomScale = 2.5;

    final matrix =
        Matrix4.identity()
          ..translate(
            -position.dx *
                (zoomScale - 1),
            -position.dy *
                (zoomScale - 1),
          )
          ..scale(
            zoomScale,
          );

    _transformationController.value =
        matrix;
  }

  void _resetZoom() {
    _transformationController.value =
        Matrix4.identity();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final imageUrl =
        _service.fullImageUrl(
      widget.image,
    );

    return Scaffold(
      backgroundColor:
          Colors.black,

      extendBodyBehindAppBar:
          true,

      appBar:
          _showControls
              ? AppBar(
                  title:
                      const Text(
                    'Fotografija',
                  ),

                  foregroundColor:
                      Colors.white,

                  backgroundColor:
                      Colors.black54,

                  elevation: 0,

                  actions: [
                    IconButton(
                      tooltip:
                          'Vrati veličinu',

                      onPressed:
                          _resetZoom,

                      icon:
                          const Icon(
                        Icons
                            .center_focus_strong,
                      ),
                    ),
                  ],
                )
              : null,

      body: SafeArea(
        top: false,
        bottom: false,

        child: GestureDetector(
          behavior:
              HitTestBehavior.opaque,

          onTap:
              _toggleControls,

          onDoubleTapDown:
              _onDoubleTapDown,

          onDoubleTap:
              _onDoubleTap,

          child: Center(
            child: InteractiveViewer(
              transformationController:
                  _transformationController,

              minScale: 0.5,
              maxScale: 6.0,

              panEnabled: true,
              scaleEnabled: true,

              boundaryMargin:
                  const EdgeInsets.all(
                100,
              ),

              clipBehavior:
                  Clip.none,

              child: Image.network(
                imageUrl,

                fit:
                    BoxFit.contain,

                width:
                    MediaQuery.sizeOf(
                  context,
                ).width,

                height:
                    MediaQuery.sizeOf(
                  context,
                ).height,

                filterQuality:
                    FilterQuality.high,

                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (
                    loadingProgress ==
                    null
                  ) {
                    return child;
                  }

                  final totalBytes =
                      loadingProgress
                          .expectedTotalBytes;

                  final loadedBytes =
                      loadingProgress
                          .cumulativeBytesLoaded;

                  final progress =
                      totalBytes == null
                          ? null
                          : loadedBytes /
                              totalBytes;

                  return Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        CircularProgressIndicator(
                          value:
                              progress,

                          color:
                              Colors.white,
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Text(
                          progress == null
                              ? 'Učitavanje slike...'
                              : '${(progress * 100).round()}%',

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  debugPrint(
                    'Image viewer error: '
                    '$error',
                  );

                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets
                              .all(
                        24,
                      ),

                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [
                          const Icon(
                            Icons
                                .broken_image_outlined,

                            size: 70,

                            color:
                                Colors.white70,
                          ),

                          const SizedBox(
                            height: 16,
                          ),

                          const Text(
                            'Slika se nije mogla učitati.',

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                              color:
                                  Colors.white,

                              fontSize:
                                  17,
                            ),
                          ),

                          const SizedBox(
                            height: 18,
                          ),

                          FilledButton.icon(
                            onPressed: () {
                              setState(
                                () {},
                              );
                            },

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
                },
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar:
          _showControls
              ? SafeArea(
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),

                    color:
                        Colors.black54,

                    child:
                        const Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        Icon(
                          Icons
                              .pinch_outlined,

                          color:
                              Colors.white70,

                          size: 20,
                        ),

                        SizedBox(
                          width: 8,
                        ),

                        Flexible(
                          child: Text(
                            'Raširi prstima za povećanje • '
                            'dupli klik za zoom',

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                              color:
                                  Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
    );
  }
}