class Memo {
  final int? id;
  final int number;
  final String genre;
  final String title;
  final String artist;
  final String key;
  final String machine;
  final String notes;

  Memo({
    this.id,
    required this.number,
    this.genre = '',
    this.title = '',
    this.artist = '',
    this.key = '',
    this.machine = '',
    this.notes = '',
  });

  Memo copyWith({
    int? id,
    int? number,
    String? genre,
    String? title,
    String? artist,
    String? key,
    String? machine,
    String? notes,
  }) {
    return Memo(
      id: id ?? this.id,
      number: number ?? this.number,
      genre: genre ?? this.genre,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      key: key ?? this.key,
      machine: machine ?? this.machine,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'genre': genre,
      'title': title,
      'artist': artist,
      'key': key,
      'machine': machine,
      'notes': notes,
    };
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(
      id: map['id'] as int?,
      number: map['number'] as int,
      genre: map['genre'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      key: map['key'] ?? '',
      machine: map['machine'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
