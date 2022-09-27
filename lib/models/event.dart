class Event {
  final int id;
  final DateTime date;
  String name;
  String description;

  Event({required this.id, required this.date, required this.name, required this.description});

  @override
  String toString() => name;
}