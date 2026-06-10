class WardrobeResponse {
  final List<String> clothes;

  WardrobeResponse({required this.clothes});

  factory WardrobeResponse.fromJson(Map<String, dynamic> json) {
    return WardrobeResponse(clothes: List<String>.from(json['clothes'] ?? []));
  }

  Map<String, dynamic> toJson() => {'clothes': clothes};
}
