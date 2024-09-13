import 'package:injectable/injectable.dart';

import './chat_repository.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {}
