import 'package:cuidapet_my_api/application/routers/i_router.dart';
import 'package:cuidapet_my_api/modules/categories/categories_router.dart';
import 'package:cuidapet_my_api/modules/chat/chat_router.dart';
import 'package:cuidapet_my_api/modules/schedules/schedule_router.dart';
import 'package:cuidapet_my_api/modules/supplier/supplier_router.dart';
import 'package:cuidapet_my_api/modules/user/user_router.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterConfigure {
  final Router _router;
  final List<IRouter> _routers = [
    UserRouter(),
    CategoriesRouter(),
    SupplierRouter(),
    ScheduleRouter(),
    ChatRouter(),
  ];

  RouterConfigure(this._router);

  void configure() {
    for (var r in _routers) {
      r.configure(_router);
    }
  }
}
