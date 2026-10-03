class AlbumModel {
  final int id;
  final String album;
  final String? artist;
  final int numOfSongs;
  const AlbumModel({required this.id, required this.album, this.artist, this.numOfSongs = 1});
}

class ArtistModel {
  final int id;
  final String artist;
  final int numberOfTracks;
  const ArtistModel({required this.id, required this.artist, this.numberOfTracks = 1});
}
