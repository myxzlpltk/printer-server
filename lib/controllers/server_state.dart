import 'package:equatable/equatable.dart';

class ServerState extends Equatable {
  const ServerState({
    this.serverStarted = false,
    this.wifiIpAddress = "127.0.0.1",
    this.ipAddress = "127.0.0.1",
    this.port = 8080,
    this.engineName = "esc2html.php",
    this.enginePath = "D:\\Github\\escpos-tools",
  });

  final bool serverStarted;
  final String wifiIpAddress;
  final String ipAddress;
  final int port;
  final String engineName;
  final String enginePath;

  ServerState copyWith({
    bool? serverStarted,
    String? wifiIpAddress,
    String? ipAddress,
    int? port,
    String? engineName,
    String? enginePath,
  }) {
    return ServerState(
      serverStarted: serverStarted ?? this.serverStarted,
      wifiIpAddress: wifiIpAddress ?? this.wifiIpAddress,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      engineName: engineName ?? this.engineName,
      enginePath: enginePath ?? this.enginePath,
    );
  }

  @override
  List<Object?> get props => [serverStarted, wifiIpAddress, ipAddress, port, engineName, enginePath];
}
