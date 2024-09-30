import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';
import 'package:test/test.dart';

class MockResultRow extends Mock implements ResultRow {
  @override
  List<Object?>? values;

  @override
  Map<String, dynamic> fields;

  List<String>? blobFields;

  MockResultRow(this.fields, [this.blobFields]);

  @override
  dynamic operator [](dynamic index) {
    if (index is int) {
      return values?[index];
    } else {
      var fieldName = index.toString();
      if (fields.containsKey(fieldName)) {
        if (blobFields != null && blobFields!.contains(fieldName)) {
          return Blob.fromString(fields[fieldName]);
        }
        return fields[fieldName];
      } else {
        fail('Field $fieldName not found in fixture');
      }
    }
  }
}
