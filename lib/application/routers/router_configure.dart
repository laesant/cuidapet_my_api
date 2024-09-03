import 'package:cuidapet_my_api/application/routers/i_router.dart';
import 'package:cuidapet_my_api/modules/teste/teste_router.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterConfigure {
  final Router _router;
  final List<IRouter> _routers = [
    TesteRouter(),
  ];

  RouterConfigure(this._router);

  void configure() {
    for (var r in _routers) {
      r.configure(_router);
    }
  }
}
