class Surah {
  final int id;
  final String name;
  final String arabic;
  final int verses;
  final String type;
  final String reciter;
  final String style;
  final int sizeBytes;
  final double sizeMb;
  final String safeFileName;
  final String audioUrl;

  bool isDownloaded;
  String? localPath;
  bool isFavorite;
  double downloadProgress;
  bool isDownloading;

  Surah({
    required this.id,
    required this.name,
    required this.arabic,
    required this.verses,
    required this.type,
    required this.reciter,
    required this.style,
    required this.sizeBytes,
    required this.sizeMb,
    required this.safeFileName,
    required this.audioUrl,
    this.isDownloaded = false,
    this.localPath,
    this.isFavorite = false,
    this.downloadProgress = 0.0,
    this.isDownloading = false,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'] as int,
      name: json['name'] as String,
      arabic: json['arabic'] as String,
      verses: json['verses'] as int,
      type: json['type'] as String,
      reciter: _normalizeReciter(json['reciter'] as String?),
      style: _normalizeStyle(json['style'] as String?),
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      sizeMb: (json['sizeMb'] as num?)?.toDouble() ?? 0.0,
      safeFileName: json['safeFileName'] as String,
      audioUrl: json['audioUrl'] as String,
    );
  }

  static String _normalizeReciter(String? reciter) {
    if (reciter == null || reciter.isEmpty || reciter.contains('Bauchi') || reciter.contains('Gwani')) {
      return 'Goni Dahir Idris Maiduguri';
    }
    return reciter;
  }

  static String _normalizeStyle(String? style) {
    if (style == null || style.isEmpty || style.contains('Warsh')) {
      return "Hafs 'an 'Asim";
    }
    return style;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic': arabic,
      'verses': verses,
      'type': type,
      'reciter': reciter,
      'style': style,
      'sizeBytes': sizeBytes,
      'sizeMb': sizeMb,
      'safeFileName': safeFileName,
      'audioUrl': audioUrl,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Surah && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
