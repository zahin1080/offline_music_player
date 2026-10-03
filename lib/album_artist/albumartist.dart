class Album1 {
  final int id;
  final String album;
  final String? artist;
  final int numOfSongs;
  const Album1({
    required this.id,
    required this.album,
    this.artist,
    this.numOfSongs = 1,
  });
}

class Artist1 {
  final int id;
  final String artist;
  final int numberOfTracks;
  const Artist1({
    required this.id,
    required this.artist,
    this.numberOfTracks = 1,
  });
}
