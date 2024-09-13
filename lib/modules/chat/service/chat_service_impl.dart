import 'package:injectable/injectable.dart';

import './chat_service.dart';

@LazySingleton(as: ChatService)
class ChatServiceImpl implements ChatService {}
