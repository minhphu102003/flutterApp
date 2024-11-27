import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:flutterApp/models/notification.dart';

class WebSocketService {
  late WebSocketChannel channel;
  Function(TrafficNotification)? onNotificationReceived;

  void connect(String serverUrl) {
    channel = WebSocketChannel.connect(
      Uri.parse(serverUrl),
    );

    channel.stream.listen(
      (message) {
        try {
          // Chuyển đổi JSON thành TrafficNotification
          Map<String, dynamic> data = json.decode(message);
          TrafficNotification notification = TrafficNotification.fromJson(data);
          onNotificationReceived?.call(notification);
        } catch (e) {
          print('Error parsing WebSocket message: $e');
        }
      },
      onError: (error) {
        print('WebSocket Error: $error');
      },
      onDone: () {
        print('WebSocket closed');
      },
    );
  }

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void disconnect() {
    channel.sink.close(status.normalClosure);
  }
}