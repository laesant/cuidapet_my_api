import 'package:cuidapet_my_api/application/middlewares/middlewares.dart';
import 'package:shelf/shelf.dart';

class DefaultContentType extends Middlewares {
  final String contentType;
  DefaultContentType({this.contentType = 'application/json;charset=UTF-8'});
  @override
  Future<Response> execute(Request request) async {
    final response = await innerHandler(request);

    return response.change(headers: {'content-type': contentType});
  }
}
