import 'dart:io';

import 'package:test/test.dart';

import 'fixture_reader.dart';

void main() {
  setUp(() {});

  test('should return json', () async {
    final json =
        FixtureReader.getJsonData('/core/fixture/fixture_reader_test.json');
    expect(json, isNotEmpty);
  });

  test('should return Map<String, dynamic>', () async {
    final data = FixtureReader.getData<Map<String, dynamic>>(
        '/core/fixture/fixture_reader_test.json');
    expect(data, isA<Map<String, dynamic>>());
    expect(data['id'], 1);
  });

  test('should return List', () async {
    final data = FixtureReader.getData<List>(
        '/core/fixture/fixture_reader_list_test.json');
    expect(data, isA<List>());
    expect(data, isNotEmpty);
  });

  test('should return FileSystemException if is file not found', () async {
    expect(
      () => FixtureReader.getJsonData('/core/fixture/not_found.json'),
      throwsA(isA<FileSystemException>()),
    );
  });
}
