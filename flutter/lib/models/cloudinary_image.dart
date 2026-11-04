class CloudinaryImage {
  final String publicId;
  final String format;
  final int? version;
  final int? width;
  final int? height;

  const CloudinaryImage({
    required this.publicId,
    required this.format,
    this.version,
    this.width,
    this.height,
  });

  factory CloudinaryImage.fromJson(Map<String, dynamic> json) {
    return CloudinaryImage(
      publicId: json['public_id'] as String? ?? '',
      format: json['format'] as String? ?? 'jpg',
      version: (json['version'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );
  }
}
