/// Metadata model for TMDB information
class Metadata {

  const Metadata({
    this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage,
    this.releaseDate,
    this.genres,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      title: json['title'] ?? json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: json['vote_average']?.toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'],
      genres: json['genres'] != null
          ? List<String>.from(json['genres'].map((g) => g['name']))
          : null,
    );
  }
  final String? title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final String? releaseDate;
  final List<String>? genres;

  String? get fullPosterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : null;

  String? get fullBackdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : null;
}