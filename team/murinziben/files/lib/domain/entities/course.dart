/// A short training course — the `courses/{id}` document.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.level,
    required this.topic,
    required this.lessons,
    required this.image,
  });

  final String id;
  final String title;
  final String level;
  final String topic;
  final int lessons;
  final String image;
}
