
class CyberPoster {
  final String title;
  final String description;
  final List<String> warningPoints;
  final List<String> safetyTips;
  final String footer;
  final List<String> hashtags;

  CyberPoster({
    required this.title,
    required this.description,
    required this.warningPoints,
    required this.safetyTips,
    required this.footer,
    required this.hashtags,
  });

  factory CyberPoster.fromJson(Map<String, dynamic> json) {
    return CyberPoster(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      warningPoints: List<String>.from(json['warningPoints'] ?? []),
      safetyTips: List<String>.from(json['safetyTips'] ?? []),
      footer: json['footer'] ?? 'Stay alert. Stay secure.',
      hashtags: List<String>.from(json['hashtags'] ?? []),
    );
  }
}
