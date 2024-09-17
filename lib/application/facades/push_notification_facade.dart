import 'dart:convert';

import 'package:cuidapet_my_api/application/logger/i_logger.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@LazySingleton()
class PushNotificationFacade {
  final ILogger _log;

  PushNotificationFacade({required ILogger log}) : _log = log;

  Future<void> sendMessage({
    required List<String?> devices,
    required String title,
    required String body,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final request = {
        'notification': {
          'title': title,
          'body': body,
        },
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': 1,
          'status': 'done',
          'payload': payload,
        },
      };

      final firebaseKey =
          DotEnv()['FIREBASE_PUSH_KEY'] ?? DotEnv()['firebasePushKey'];

      if (firebaseKey == null) {
        _log.warning('Firebase key não encontrado.');
        return;
      }

      for (var device in devices) {
        if (device != null) {
          request['to'] = device;
          _log.info('Enviando mensagem para: $device');
          final result = await http.post(
              Uri.parse('https://fcm.googleapis.com/fcm/send'),
              body: jsonEncode(request),
              headers: {
                'Authorization': 'key=$firebaseKey',
                'Content-Type': 'application/json',
              });

          final responseData = jsonDecode(result.body);
          if (responseData['failure'] == 1) {
            _log.error(
                'Erro ao enviar notificação $device, erro: ${responseData['results'][0]['error']}');
          } else {
            _log.info('Notificação enviada com sucesso: $device');
          }
        }
      }
    } catch (e, s) {
      _log.error('Erro ao enviar notificação', e, s);
    }
  }
}
