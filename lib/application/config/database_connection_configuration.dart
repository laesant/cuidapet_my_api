class DatabaseConnectionConfiguration {
  final String host;
  final String user;
  final String port;
  final String password;
  final String database;

  DatabaseConnectionConfiguration(
      {required this.host,
      required this.user,
      required this.port,
      required this.password,
      required this.database});
}
