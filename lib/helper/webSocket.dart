import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:flutterApp/models/notification.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class WebSocketService {
  late WebSocketChannel channel;
  late Timer _pingTimer;
  Function(TrafficNotification)? onNotificationReceived;

  void connect(String mobileUrl, String webUrl){
    String serverUrl = kIsWeb ? webUrl : mobileUrl;

    channel = WebSocketChannel.connect(
      Uri.parse(serverUrl),
    );

    channel.stream.listen(
      (message) {
        try {
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
        _pingTimer.cancel();
      },
    );
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (channel != null && channel.sink != null) {
        channel.sink.add('ping');
        print("Ping sent to keep connection alive");
      }
    });
  }

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void disconnect() {
    channel.sink.close(status.normalClosure);
  }
}