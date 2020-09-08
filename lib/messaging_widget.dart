import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification/page/first_page.dart';
import 'package:flutter_notification/page/second_page.dart';

import 'api/messaging.dart';
import 'model/message.dart';

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController titleController =
      TextEditingController(text: 'Title');
  final TextEditingController bodyController =
      TextEditingController(text: 'Body123');
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    //geting token
    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();

    //send to all
    _firebaseMessaging.subscribeToTopic('all');

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('OnMessage : $message');
        final notification = message['notification'];
        setState(() {
          messages.add(
            Message(title: notification['title'], body: notification['body']),
          );
        });
        handleRouting(notification);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('OnLaunch : $message');
        final notification = message['data'];
        setState(() {
          messages.add(
            Message(title: notification['title'], body: notification['body']),
          );
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print('OnResume : $message');
        final notification = message['data'];
        handleRouting(notification);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  void handleRouting(dynamic notification) {
    switch (notification['title']) {
      case 'first':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => FirstPage()));
        break;
      case 'second':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => SecondPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
          RaisedButton(
            onPressed: sendNotification,
            child: Text('Send notification to all'),
          ),
        ]..addAll(messages.map(buildMessage).toList()),
      );

  Widget buildMessage(Message message) => ListTile(
        title: Text('Title: ${message.title}'),
        subtitle: Text('Body: ${message.body}'),
      );

  Future sendNotification() async {
    final response = await Messaging.sendToAll(
      title: titleController.text,
      body: bodyController.text,
      // fcmToken: fcmToken,
    );
    if (response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text('[${response.statusCode}] Error message: ${response.body}'),
      ));
    }
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
    // send key to your server to allow server to use
    // this token to send push notifications
  }
}
