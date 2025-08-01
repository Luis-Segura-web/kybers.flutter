/// Channel model for IPTV streams
class Channel {
  final String id;
  final String name;
  final String streamUrl;
  final String? logo;
  final String categoryId;
  final String? epgChannelId;

  const Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.logo,
    required this.categoryId,
    this.epgChannelId,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['stream_id']?.toString() ?? '',
      name: json['name'] ?? '',
      streamUrl: json['stream_url'] ?? '',
      logo: json['stream_icon'],
      categoryId: json['category_id']?.toString() ?? '',
      epgChannelId: json['epg_channel_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stream_id': id,
      'name': name,
      'stream_url': streamUrl,
      'stream_icon': logo,
      'category_id': categoryId,
      'epg_channel_id': epgChannelId,
    };
  }
}