import 'dart:convert';

import 'package:cuidapet_my_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_my_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_my_api/application/helpers/cripty_helper.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_my_api/modules/user/data/i_user_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../core/fixture/fixture_reader.dart';
import '../../../core/log/mock_logger.dart';
import '../../../core/mysql/mock_database_connection.dart';
import '../../../core/mysql/mock_mysql_exception.dart';
import '../../../core/mysql/mock_results.dart';

void main() {
  late MockDatabaseConnection database;
  late ILogger log;
  late IUserRepository userRepository;

  setUp(() {
    database = MockDatabaseConnection();
    log = MockLogger();
    userRepository = IUserRepositoryImpl(
      connection: database,
      log: log,
    );
  });

  group('Group test find by id', () {
    test('should return user by id', () async {
      final userId = 1;
      final userFixtureDB = FixtureReader.getJsonData(
          'modules/user/data/fixture/find_by_id_sucess_fixture.json');

      final mockResults = MockResults(userFixtureDB, [
        'ios_token',
        'android_token',
        'refresh_token',
        'img_avatar',
      ]);
      database.mockQuery(mockResults);

      final userMap = jsonDecode(userFixtureDB);
      final userExpected = User(
        id: userMap['id'],
        email: userMap['email'],
        registerType: userMap['tipo_cadastro'],
        iosToken: userMap['ios_token'],
        androidToken: userMap['android_token'],
        refreshToken: userMap['refresh_token'],
        imageAvatar: userMap['img_avatar'],
        supplierId: userMap['fornecedor_id'],
      );

      final user = await userRepository.findById(userId);
      expect(user, isA<User>());
      expect(user, userExpected);
      database.verifyConnectionClose();
    });

    test('should return exception UserNotFoundException', () async {
      //Arrange
      final id = 1;
      final mockResults = MockResults();
      database.mockQuery(mockResults, [id]);
      //Act

      expect(
        () => userRepository.findById(id),
        throwsA(isA<UserNotfoundException>()),
      );
      await Future.delayed(Duration(seconds: 1));
      database.verifyConnectionClose();
    });
  });

  group('Group test create user', () {
    test('Should create user with success', () async {
      //Arrange
      final userId = 1;
      final mockResults = MockResults();
      when(() => mockResults.insertId).thenReturn(userId);
      database.mockQuery(mockResults);

      final userExpected = User(
          id: userId,
          email: 'email@email.com',
          registerType: 'APP',
          imageAvatar: '',
          password: '');

      //Act
      final user = await userRepository.createUser(
        User(
          email: 'email@email.com',
          registerType: 'APP',
          password: 'password',
          imageAvatar: '',
        ),
      );

      //Assert
      expect(user, userExpected);
    });

    test('Should throw DatabaseException', () async {
      //Arrange
      database.mockQueryException();
      //Assert
      expect(
        () => userRepository.createUser(User(password: '')),
        throwsA(isA<DatabaseException>()),
      );
    });
    test('Should throw UserExistsException', () async {
      //Arrange
      final mockException = MockMysqlException();
      when(() => mockException.message).thenReturn('usuario.email_UNIQUE');
      database.mockQueryException(mockException: mockException);
      //Assert
      expect(
        () => userRepository
            .createUser(User(email: 'email@email.com', password: '')),
        throwsA(isA<UserExistsException>()),
      );
    });
  });

  group('Group test LoginWithEmailAndPassword', () {
    test('Should login with email and password', () async {
      //Arrange
      final userFixtureDB = FixtureReader.getJsonData(
          '/modules/user/data/fixture/login_with_email_and_password_success.json');
      final mockResults = MockResults(userFixtureDB, [
        'ios_token',
        'android_token',
        'refresh_token',
        'img_avatar',
      ]);

      final email = 'email@email.com';
      final password = 'password';
      database.mockQuery(
          mockResults, [email, CriptyHelper.generateSha256Hash(password)]);
      final userData = jsonDecode(userFixtureDB);
      final userExpected = User(
        id: userData['id'],
        email: userData['email'],
        registerType: userData['tipo_cadastro'],
        iosToken: userData['ios_token'],
        androidToken: userData['android_token'],
        refreshToken: userData['refresh_token'],
        imageAvatar: userData['img_avatar'],
        supplierId: userData['fornecedor_id'],
      );
      //Act
      final user = await userRepository.loginWithEmailAndPassword(
          email, password, false);
      //Assert
      expect(user, userExpected);
      database.verifyConnectionClose();
    });
    test(
        'Should login with email and password and return exception UserNotfoundException',
        () async {
      //Arrange

      final mockResults = MockResults();

      final email = 'email@email.com';
      final password = 'password';
      database.mockQuery(
          mockResults, [email, CriptyHelper.generateSha256Hash(password)]);

      //Assert
      expect(
          () =>
              userRepository.loginWithEmailAndPassword(email, password, false),
          throwsA(isA<UserNotfoundException>()));
      await Future.delayed(Duration(milliseconds: 200));
      database.verifyConnectionClose();
    });

    test(
        'Should login with email and password and return exception DatabaseException',
        () async {
      //Arrange
      final email = 'email@email.com';
      final password = 'password';

      database.mockQueryException(
          params: [email, CriptyHelper.generateSha256Hash(password)]);
      //Assert
      expect(
          () =>
              userRepository.loginWithEmailAndPassword(email, password, false),
          throwsA(isA<DatabaseException>()));
      await Future.delayed(Duration(milliseconds: 200));
      database.verifyConnectionClose();
    });
  });
}
