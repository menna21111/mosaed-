class OnboardSlide {
  const OnboardSlide({
    required this.id,
    required this.title,
    required this.description,
    this.titleAr,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.imageUrl,
    this.order = 0,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String description;
  final String? titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? imageUrl;
  final int order;
  final bool isActive;

  String localizedTitle(String languageCode) {
    if (languageCode == 'ar') {
      return _firstNonEmpty([titleAr, title, titleEn]) ?? '';
    }
    return _firstNonEmpty([titleEn, title, titleAr]) ?? '';
  }

  String localizedDescription(String languageCode) {
    if (languageCode == 'ar') {
      return _firstNonEmpty([descriptionAr, description, descriptionEn]) ?? '';
    }
    return _firstNonEmpty([descriptionEn, description, descriptionAr]) ?? '';
  }

  factory OnboardSlide.fromJson(Map<String, dynamic> json) {
    final image = json['image']?.toString() ??
        json['image_url']?.toString() ??
        json['photo']?.toString() ??
        json['media']?.toString() ??
        json['icon']?.toString();

    final orderRaw = json['order'] ??
        json['sort_order'] ??
        json['position'] ??
        json['index'] ??
        0;

    final activeRaw = json['is_active'] ?? json['active'] ?? json['enabled'];
    final isActive = activeRaw == null
        ? true
        : activeRaw == true ||
            activeRaw.toString().toLowerCase() == 'true' ||
            activeRaw.toString() == '1';

    return OnboardSlide(
      id: json['id']?.toString() ??
          json['uuid']?.toString() ??
          '${json['title'] ?? json['title_ar'] ?? orderRaw}',
      title: json['title']?.toString() ??
          json['heading']?.toString() ??
          json['name']?.toString() ??
          '',
      description: json['description']?.toString() ??
          json['body']?.toString() ??
          json['subtitle']?.toString() ??
          json['content']?.toString() ??
          json['text']?.toString() ??
          '',
      titleAr: json['title_ar']?.toString() ?? json['ar_title']?.toString(),
      titleEn: json['title_en']?.toString() ?? json['en_title']?.toString(),
      descriptionAr: json['description_ar']?.toString() ??
          json['ar_description']?.toString() ??
          json['body_ar']?.toString(),
      descriptionEn: json['description_en']?.toString() ??
          json['en_description']?.toString() ??
          json['body_en']?.toString(),
      imageUrl: (image != null && image.trim().isNotEmpty) ? image.trim() : null,
      order: int.tryParse(orderRaw.toString()) ?? 0,
      isActive: isActive,
    );
  }

  static String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}
