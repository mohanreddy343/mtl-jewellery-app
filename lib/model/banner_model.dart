class BannerModel {
  final int id;
  final String image; // file name on the server
  final String imageUrl; // full address to show the picture
  final String link; // empty = no link

  const BannerModel({
    required this.id,
    required this.image,
    required this.imageUrl,
    required this.link,
  });

  bool get hasLink => link.trim().isNotEmpty;

  factory BannerModel.fromJson(Map<String, dynamic> j) => BannerModel(
    id: (j['id'] as num).toInt(),
    image: (j['image'] ?? '').toString(),
    imageUrl: (j['imageUrl'] ?? '').toString(),
    link: (j['link'] ?? '').toString(),
  );
}