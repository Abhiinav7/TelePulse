class Channel {
  final String id;
  final String name;
  final String logoUrl;
  final String streamUrl;
  final String category;
  final String language;
  final bool isEnabled;

  Channel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.streamUrl,
    required this.category,
    required this.language,
    required this.isEnabled,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    String cleanName = json['name'] as String? ?? 'Unknown Channel';
    
    // Aggressively remove ANYTHING inside parentheses or brackets
    cleanName = cleanName.replaceAll(RegExp(r'\s*\([^)]*\)'), ''); // Removes (1080p), (USA), (Local), etc.
    cleanName = cleanName.replaceAll(RegExp(r'\s*\[[^\]]*\]'), ''); // Removes [Geo-blocked], [Not 24/7], etc.
    
    // Also remove resolutions even if they don't have parentheses (e.g., "MyChannel 1080p")
    cleanName = cleanName.replaceAll(RegExp(r'\s*\b(360p|480p|576p|720p|1080p|1440p|2160p|4k|8k|HD|FHD|UHD)\b', caseSensitive: false), '');
    
    // Extra cleanup for trailing hyphens or commas
    cleanName = cleanName.replaceAll(RegExp(r'[\-\,]\s*$'), '');
    cleanName = cleanName.trim();

    return Channel(
      id: json['id'] as String? ?? '',
      name: cleanName,
      logoUrl: json['logo_url'] as String? ?? '',
      streamUrl: json['stream_url'] as String? ?? '',
      category: json['category'] as String? ?? 'Uncategorized',
      language: json['language'] as String? ?? 'Unknown',
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'stream_url': streamUrl,
      'category': category,
      'language': language,
      'is_enabled': isEnabled,
    };
  }
}
