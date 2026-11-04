import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cloudinary_image.dart';

class CloudinaryService {
  static const String cloudName =
      'dgyy4rc34';

  static const String defaultTag =
      'DzematBochum';

  /*
   * Stara funkcija ostaje radi kompatibilnosti.
   */
  Future<List<CloudinaryImage>>
      getImages() {
    return getImagesByTag(
      defaultTag,
    );
  }

  /*
   * Dinamički učitava slike prema tagu
   * izabranom u GalleryPage.
   */
  Future<List<CloudinaryImage>>
      getImagesByTag(
    String tag,
  ) async {
    final cleanTag =
        tag.trim();

    if (cleanTag.isEmpty) {
      throw const CloudinaryException(
        'Cloudinary tag nije unesen.',
      );
    }

    final uri = Uri.https(
      'res.cloudinary.com',
      '/$cloudName/image/list/'
      '$cleanTag.json',
      {
        /*
         * Sprječava učitavanje stare
         * cacheirane JSON liste.
         */
        'refresh':
            DateTime.now()
                .millisecondsSinceEpoch
                .toString(),
      },
    );

    print(
      'Loading Cloudinary tag: '
      '$cleanTag',
    );

    print(
      'Cloudinary URL: $uri',
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
      response.statusCode == 401
    ) {
      throw const CloudinaryException(
        '401 Unauthorized. U Cloudinaryju '
        'omogući Resource list: Settings → '
        'Security → Restricted image types → '
        'Resource list.',
      );
    }

    /*
     * Tag postoji, ali nema slika.
     */
    if (
      response.statusCode == 404
    ) {
      return const [];
    }

    if (
      response.statusCode != 200
    ) {
      throw CloudinaryException(
        'Cloudinary je vratio HTTP '
        '${response.statusCode}.',
      );
    }

    final dynamic decoded;

    try {
      decoded =
          jsonDecode(
        response.body,
      );
    } catch (_) {
      throw const CloudinaryException(
        'Cloudinary odgovor nije ispravan JSON.',
      );
    }

    if (
      decoded is!
          Map<String, dynamic>
    ) {
      throw const CloudinaryException(
        'Neispravan Cloudinary odgovor.',
      );
    }

    final rawResources =
        decoded['resources'];

    if (rawResources is! List) {
      return const [];
    }

    /*
     * Pretvara resurse u obične mape.
     */
    final resources =
        rawResources
            .whereType<Map>()
            .map(
              (item) =>
                  item.map(
                (key, value) =>
                    MapEntry(
                  key.toString(),
                  value,
                ),
              ),
            )
            .toList();

    /*
     * Najnovije slike idu na početak.
     */
    resources.sort(
      (first, second) {
        final firstDate =
            DateTime.tryParse(
                  first['created_at']
                          ?.toString() ??
                      '',
                ) ??
                DateTime.fromMillisecondsSinceEpoch(
                  0,
                );

        final secondDate =
            DateTime.tryParse(
                  second['created_at']
                          ?.toString() ??
                      '',
                ) ??
                DateTime.fromMillisecondsSinceEpoch(
                  0,
                );

        return secondDate.compareTo(
          firstDate,
        );
      },
    );

    final images =
        resources
            .map(
              CloudinaryImage
                  .fromJson,
            )
            .where(
              (image) =>
                  image.publicId
                      .isNotEmpty,
            )
            .toList(
              growable: false,
            );

    print(
      'Tag "$cleanTag": '
      '${images.length} slika',
    );

    return images;
  }

  /*
   * Mala slika za grid ili carousel.
   */
  String thumbnailUrl(
    CloudinaryImage image,
  ) {
    return _buildImageUrl(
      image,
      transformation:
          'f_auto,q_auto,'
          'c_fill,g_auto,'
          'w_900,h_900',
    );
  }

  /*
   * Originalna slika za ImageViewerPage.
   */
  String fullImageUrl(
    CloudinaryImage image,
  ) {
    return _buildImageUrl(
      image,
    );
  }

  String _buildImageUrl(
    CloudinaryImage image, {
    String? transformation,
  }) {
    final encodedPublicId =
        image.publicId
            .split('/')
            .map(
              Uri.encodeComponent,
            )
            .join('/');

    final versionPart =
        image.version == null
            ? ''
            : '/v${image.version}';

    final format =
        image.format.trim();

    final formatPart =
        format.isEmpty
            ? ''
            : '.$format';

    final transformationPart =
        transformation == null ||
                transformation.isEmpty
            ? ''
            : '/$transformation';

    return 'https://res.cloudinary.com/'
        '$cloudName/image/upload'
        '$transformationPart'
        '$versionPart/'
        '$encodedPublicId'
        '$formatPart';
  }
}

class CloudinaryException
    implements Exception {
  final String message;

  const CloudinaryException(
    this.message,
  );

  @override
  String toString() {
    return message;
  }
}