import 'package:uuid/uuid.dart';

enum CheckType {
  rss('RSS'),
  htmlStandard('HTML_STANDARD'),
  htmlCustom('HTML_CUSTOM');

  const CheckType(this.value);
  final String value;

  static CheckType fromString(String value) {
    return CheckType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CheckType.htmlStandard,
    );
  }
}

enum HtmlCustomCondition {
  or('OR'),
  and('AND');

  const HtmlCustomCondition(this.value);
  final String value;

  static HtmlCustomCondition fromString(String value) {
    return HtmlCustomCondition.values.firstWhere(
      (cond) => cond.value == value,
      orElse: () => HtmlCustomCondition.or,
    );
  }
}

class UrlItem {
  final String id;
  final String url;
  final String title;
  final String? thumbnailPath;
  final CheckType checkType;
  final String? htmlSelector;
  final HtmlCustomCondition? htmlCustomCondition;
  final String? lastContentHash;
  final DateTime? lastUpdatedAt;
  final DateTime? lastCheckedAt;
  final bool isActive;
  final int errorCount;
  final String? lastErrorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  UrlItem({
    String? id,
    required this.url,
    required this.title,
    this.thumbnailPath,
    this.checkType = CheckType.htmlStandard,
    this.htmlSelector,
    this.htmlCustomCondition,
    this.lastContentHash,
    this.lastUpdatedAt,
    this.lastCheckedAt,
    this.isActive = true,
    this.errorCount = 0,
    this.lastErrorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'thumbnail_path': thumbnailPath,
      'check_type': checkType.value,
      'html_selector': htmlSelector,
      'html_custom_condition': htmlCustomCondition?.value,
      'last_content_hash': lastContentHash,
      'last_updated_at': lastUpdatedAt?.toIso8601String(),
      'last_checked_at': lastCheckedAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'error_count': errorCount,
      'last_error_message': lastErrorMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UrlItem.fromMap(Map<String, dynamic> map) {
    return UrlItem(
      id: map['id'] as String,
      url: map['url'] as String,
      title: map['title'] as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      checkType: CheckType.fromString(map['check_type'] as String),
      htmlSelector: map['html_selector'] as String?,
      htmlCustomCondition: map['html_custom_condition'] != null
          ? HtmlCustomCondition.fromString(map['html_custom_condition'] as String)
          : null,
      lastContentHash: map['last_content_hash'] as String?,
      lastUpdatedAt: map['last_updated_at'] != null
          ? DateTime.parse(map['last_updated_at'] as String)
          : null,
      lastCheckedAt: map['last_checked_at'] != null
          ? DateTime.parse(map['last_checked_at'] as String)
          : null,
      isActive: (map['is_active'] as int) == 1,
      errorCount: map['error_count'] as int,
      lastErrorMessage: map['last_error_message'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  UrlItem copyWith({
    String? id,
    String? url,
    String? title,
    String? thumbnailPath,
    CheckType? checkType,
    String? htmlSelector,
    HtmlCustomCondition? htmlCustomCondition,
    String? lastContentHash,
    DateTime? lastUpdatedAt,
    DateTime? lastCheckedAt,
    bool? isActive,
    int? errorCount,
    String? lastErrorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UrlItem(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      checkType: checkType ?? this.checkType,
      htmlSelector: htmlSelector ?? this.htmlSelector,
      htmlCustomCondition: htmlCustomCondition ?? this.htmlCustomCondition,
      lastContentHash: lastContentHash ?? this.lastContentHash,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      isActive: isActive ?? this.isActive,
      errorCount: errorCount ?? this.errorCount,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
