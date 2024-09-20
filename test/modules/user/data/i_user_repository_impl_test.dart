import 'package:cuidapet_my_api/application/database/i_database_connection.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/data/i_user_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';
import 'package:test/test.dart';

import '../../../core/log/mock_logger.dart';
import '../../../core/mysql/mock_database_connection.dart';
import '../../../core/mysql/mock_mysql_connection.dart';
import '../../../core/mysql/mock_result_row.dart';
import '../../../core/mysql/mock_results.dart';

void main() {
  late IDatabaseConnection database;
  late ILogger log;
  late MockMysqlConnection mysqlConnection;
  late Results mysqlResults;
  late ResultRow mysqlResultRow;

  setUp(() {
    database = MockDatabaseConnection();
    log = MockLogger();
    mysqlConnection = MockMysqlConnection();
    mysqlResults = MockResults();
    mysqlResultRow = MockResultRow();
  });

  group('Group test find by id', () {
    test('should return user by id', () async {
      final userId = 1;
      final userRepository = IUserRepositoryImpl(
        connection: database,
        log: log,
      );
      when(() => database.openConnection())
          .thenAnswer((_) async => mysqlConnection);
      when(() => mysqlConnection.close()).thenAnswer((a) async => a);
      when(() => mysqlConnection.query(any(), any()))
          .thenAnswer((_) async => mysqlResults);
      when(() => mysqlResults.isEmpty).thenReturn(false);
      when(() => mysqlResults.first).thenReturn(mysqlResultRow);
      when(() => mysqlResultRow['id']).thenReturn(userId);
      final user = await userRepository.findById(userId);
      expect(user, isA<User>());
      expect(user.id, userId);
    });
  });
}
