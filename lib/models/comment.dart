class Comment {
  final String id;
  final int star;
  final String timestamps;
  final String content;
  final Place? place; // Có thể null nếu `place_id` chỉ là chuỗi
  final String? placeId; // Nullable nếu `place_id` là object
  final List<CommentImage> listImg;
  final String createdAt;
  final String updatedAt;
  final String? accountId; // Optional
  final String? username;  // Optional

  Comment({
    required this.id,
    required this.star,
    required this.timestamps,
    required this.content,
    this.place,
    this.placeId,
    required this.listImg,
    required this.createdAt,
    required this.updatedAt,
    this.accountId,
    this.username,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      star: json['star'],
      timestamps: json['timestamps'],
      content: json['content'],
      place: json['place_id'] is Map<String, dynamic>
          ? Place.fromJson(json['place_id']) // Parse object Place
          : null,
      placeId: json['place_id'] is String ? json['place_id'] : null, // Parse String ID
      listImg: (json['listImg'] as List)
          .map((img) => CommentImage.fromJson(img))
          .toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      accountId: json['account_id'], // Optional
      username: json['username'], // Optional
    );
  }
}

class Place {
  final String id;
  final String type;
  final String name;
  final int star;
  final String img;

  Place({
    required this.id,
    required this.type,
    required this.name,
    required this.star,
    required this.img,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['_id'],
      type: json['type'],
      name: json['name'],
      star: json['star'],
      img: json['img'],
    );
  }
}

class CommentImage {
  final String image;
  final String id;

  CommentImage({
    required this.image,
    required this.id,
  });

  factory CommentImage.fromJson(Map<String, dynamic> json) {
    return CommentImage(
      image: json['image'],
      id: json['_id'],
    );
  }
}
