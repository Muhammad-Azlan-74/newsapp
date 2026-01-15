/// Hall of Fame Model
///
/// Represents a user's Hall of Fame data with images
class HallOfFameModel {
  final String userId;
  final List<HofImage> images;
  final int likes;
  final List<String> likedBy;
  final String createdAt;
  final String updatedAt;

  HallOfFameModel({
    required this.userId,
    required this.images,
    required this.likes,
    required this.likedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HallOfFameModel.fromJson(Map<String, dynamic> json) {
    return HallOfFameModel(
      userId: json['userId'] ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => HofImage.fromJson(img as Map<String, dynamic>))
              .toList() ??
          [],
      likes: json['likes'] ?? 0,
      likedBy: (json['likedBy'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'images': images.map((img) => img.toJson()).toList(),
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

/// HOF Image Model
class HofImage {
  final String url;

  HofImage({required this.url});

  factory HofImage.fromJson(Map<String, dynamic> json) {
    return HofImage(
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
    };
  }
}

/// Hall of Fame Response
class HallOfFameResponse {
  final HallOfFameModel hallOfFame;

  HallOfFameResponse({required this.hallOfFame});

  factory HallOfFameResponse.fromJson(Map<String, dynamic> json) {
    return HallOfFameResponse(
      hallOfFame: HallOfFameModel.fromJson(
        json['hallOfFame'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hallOfFame': hallOfFame.toJson(),
    };
  }
}

/// Upload Picture Response
class UploadPictureResponse {
  final String message;
  final String imageUrl;

  UploadPictureResponse({
    required this.message,
    required this.imageUrl,
  });

  factory UploadPictureResponse.fromJson(Map<String, dynamic> json) {
    return UploadPictureResponse(
      message: json['message'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'imageUrl': imageUrl,
    };
  }
}

/// Like Response
class LikeResponse {
  final String message;
  final int likes;

  LikeResponse({
    required this.message,
    required this.likes,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    return LikeResponse(
      message: json['message'] ?? '',
      likes: json['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'likes': likes,
    };
  }
}
