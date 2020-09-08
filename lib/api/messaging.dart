import 'package:http/http.dart';
import 'dart:convert';
import 'package:meta/meta.dart';

class Messaging {
  static final Client client = Client();
  // from 'https://console.firebase.google.com'
  // --> project settings --> cloud messaging --> "Server key"

  static const String serverKey =
      'AAAAlici0Qo:APA91bFvROcjJlrvYNrR4PH6ZBe3QXnJaMem5yyi6rgcNFWrV52_6U-KfikThPvaICVvvxqsJzbgeJZg9Ny_Jokwu6gt6jyDrwR6ZTbDMYtJACXlqhvsd3YBZw2dQey5rqbCLrYD33dZ';
  static Future<Response> sendToAll({
    @required String title,
    @required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: 'all');

  static Future<Response> sendToTopic(
          {@required String title,
          @required String body,
          @required String topic}) =>
      sendTo(title: title, body: body, fcmToken: '/topics/$topic');

  static Future<Response> sendTo({
    @required String title,
    @required String body,
    @required String fcmToken,
  }) =>
      client.post(
        'https://fcm.googleapis.com/fcm/send',
        body: json.encode({
          'notification': {'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
          },
          'to': '$fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );
}
