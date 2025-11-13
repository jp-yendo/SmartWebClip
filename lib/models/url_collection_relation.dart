class UrlCollectionRelation {
  final String urlItemId;
  final String collectionId;
  final DateTime createdAt;

  UrlCollectionRelation({
    required this.urlItemId,
    required this.collectionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'url_item_id': urlItemId,
      'collection_id': collectionId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UrlCollectionRelation.fromMap(Map<String, dynamic> map) {
    return UrlCollectionRelation(
      urlItemId: map['url_item_id'] as String,
      collectionId: map['collection_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
