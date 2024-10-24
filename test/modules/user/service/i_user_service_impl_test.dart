import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_my_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_my_api/modules/user/service/i_user_service_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../core/log/mock_logger.dart';

void main() {
  late ILogger log;
  late IUserRepository userRepository;
  late IUserService userService;
  setUp(() {
    userRepository = MockUserRepository();
    log = MockLogger();
    userService = IUserServiceImpl(userRepository: userRepository, log: log);
    registerFallbackValue(User());
  });

  group('Group test loginWithEmailAndPassword', () {
    test(
        'Should login with email and password and return UserNotFoundException',
        () async {
      //Arrange
      final email = 'email@gmail.com';
      final password = '123';
      final supplierUser = false;

      when(() => userRepository.loginWithEmailAndPassword(
          email, password, supplierUser)).thenThrow(UserNotfoundException());

      //Assert
      expect(
          () => userService.loginWithEmailAndPassword(
              email, password, supplierUser),
          throwsA(isA<UserNotfoundException>()));
      verify(() => userRepository.loginWithEmailAndPassword(
          email, password, supplierUser)).called(1);
    });
    test('Should login with email and password', () async {
      //Arrange
      final id = 1;
      final email = 'email@gmail.com';
      final password = '123';
      final supplierUser = false;
      final userMock = User(
        id: id,
        email: email,
      );
      when(() => userRepository.loginWithEmailAndPassword(
          email, password, supplierUser)).thenAnswer((_) async => userMock);
      //Act
      final user = await userService.loginWithEmailAndPassword(
          email, password, supplierUser);
      //Assert
      expect(user, userMock);
      verify(() => userRepository.loginWithEmailAndPassword(
          email, password, supplierUser)).called(1);
    });
  });

  group('Group test loginWithSocial', () {
    test('Should login with social success', () async {
      //Arrange
      final email = 'email@gmail.com';
      final socialKey = '123';
      final socialType = 'Facebook';
      final userReturnLogin = User(
          id: 1, email: email, socialKey: socialKey, registerType: socialType);
      when(() => userRepository.loginByEmailSocialKey(
            email,
            socialKey,
            socialType,
          )).thenAnswer((_) async => userReturnLogin);
      //Act
      final user = await userService.loginByEmailSocialKey(
          email, '', socialKey, socialType);
      //Assert

      expect(user, userReturnLogin);
      verify(() => userRepository.loginByEmailSocialKey(
            email,
            socialKey,
            socialType,
          )).called(1);
    });

    test(
        'Should login with social and return UserNotFoundException and create a new user',
        () async {
      //Arrange
      final email = 'email@gmail.com';
      final socialKey = '123';
      final socialType = 'Facebook';
      final userCreated = User(
          id: 1, email: email, socialKey: socialKey, registerType: socialType);
      when(() => userRepository.loginByEmailSocialKey(
            email,
            socialKey,
            socialType,
          )).thenThrow(UserNotfoundException());

      when(() => userRepository.createUser(any()))
          .thenAnswer((_) async => userCreated);
      final user = await userService.loginByEmailSocialKey(
          email, '', socialKey, socialType);
      //Assert
      expect(user, userCreated);
      verify(() => userRepository.loginByEmailSocialKey(
          email, socialKey, socialType)).called(1);
      verify(() => userRepository.createUser(any())).called(1);
    });
  });
}

class MockUserRepository extends Mock implements IUserRepository {}
