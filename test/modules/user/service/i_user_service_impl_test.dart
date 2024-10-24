import 'package:cuidapet_my_api/application/config/application_config.dart';
import 'package:cuidapet_my_api/application/exceptions/service_exception.dart';
import 'package:cuidapet_my_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_my_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:cuidapet_my_api/entities/user.dart';
import 'package:cuidapet_my_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_my_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_my_api/modules/user/service/i_user_service_impl.dart';
import 'package:cuidapet_my_api/modules/user/view_models/refresh_token_model.dart';
import 'package:cuidapet_my_api/modules/user/view_models/user_refresh_token_input_model.dart';
import 'package:dotenv/dotenv.dart';
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
    ApplicationConfig.loadEnv();
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

  group('Group test refreshToken', () {
    test('Should refresh token with success', () async {
      //Arrange
      ApplicationConfig.env.clear();
      ApplicationConfig.env.addAll({
        'refresh_token_expire_days': '20',
        'refresh_token_not_before_hours': '0',
        'jwtSecret': '123',
      });
      final userId = 1;
      final accessToken = JwtHelper.generateJWT(userId, null);
      final refresToken = JwtHelper.refreshToken(accessToken);
      final model = UserRefreshTokenInputModel(
          '{"refresh_token": "$refresToken"}',
          user: userId,
          accessToken: accessToken);
      when(() => userRepository.updateRefreshToken(any()))
          .thenAnswer((invocation) async => invocation);
      //Act
      final responseToken = await userService.refreshToken(model);
      //Assert
      expect(responseToken, isA<RefreshTokenModel>());
      expect(responseToken.accessToken, isNotEmpty);
      expect(responseToken.refreshToken, isNotEmpty);
      verify(() => userRepository.updateRefreshToken(any())).called(1);
    });

    test('Should try refresh token JWT but return validate error (Bearer) ',
        () async {
      //Arrange
      final model = UserRefreshTokenInputModel('{"refresh_token": ""}',
          user: 1, accessToken: 'accessToken');

      //Assert
      expect(() => userService.refreshToken(model),
          throwsA(isA<ServiceException>()));
    });
    test(
        'Should try refresh token JWT but return validate error (JwtException) ',
        () async {
      //Arrange
      // ApplicationConfig.env.clear();
      ApplicationConfig.env.addAll({
        'refresh_token_expire_days': '20',
        'refresh_token_not_before_hours': '0',
        'jwtSecret': '123',
      });
      final userId = 1;
      final accessToken = JwtHelper.generateJWT(userId, null);
      final refreshToken = JwtHelper.refreshToken('123');
      final model = UserRefreshTokenInputModel(
          '{"refresh_token": "$refreshToken"}',
          user: 1,
          accessToken: accessToken);

      //Assert
      expect(() => userService.refreshToken(model),
          throwsA(isA<ServiceException>()));
    });
  });
}

class MockUserRepository extends Mock implements IUserRepository {}
