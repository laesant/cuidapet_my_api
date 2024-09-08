import 'package:cuidapet_my_api/modules/user/controller/auth_controller.dart';
import 'package:cuidapet_my_api/modules/user/controller/user_controller.dart';
import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../application/routers/i_router.dart';

class UserRouter implements IRouter {
  @override
  void configure(Router router) {
    final authController = GetIt.I.get<AuthController>();
    final userController = GetIt.I.get<UserController>();
    router.mount('/auth/', authController.router.call);
    router.mount('/user/', userController.router.call);
  }
}
