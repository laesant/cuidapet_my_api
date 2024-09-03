import 'package:mysql1/mysql1.dart';

abstract interface class IDatabaseConnection {
  Future<MySqlConnection> openConnection();
}
