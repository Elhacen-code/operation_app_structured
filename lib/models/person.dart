class Person implements Comparable {
  final int id;
  final String firstName;
  final String lastName;

  const Person(
      {required this.id, required this.firstName, required this.lastName});

  String get fulName => '$firstName $lastName';

  Person.fromRow(Map<String, Object?> row)
      : id = row['ID'] as int,
        firstName = row['FIRST_NAME'] as String,
        lastName = row['LAST_NAME'] as String;

  @override
  int compareTo(covariant Person other) => other.id.compareTo(id);

  @override
  bool operator ==(covariant Person other) => id == other.id;

  @override
  String toString() =>
      'Person, id = $id, firstName: $firstName, lastName: $lastName';
}
