import 'dart:convert';

import 'package:flourish_flutter_sdk/config/environment_enum.dart';
import 'package:flourish_flutter_sdk/config/language.dart';
import 'package:flourish_flutter_sdk/flourish.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Flourish _flourish;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint("[_MyAppState] Starting initState method");

    const platform = MethodChannel('flourish');
    platform.setMethodCallHandler((call) async {
      if (call.method == 'initialize') {
        dynamic arguments = call.arguments;

        debugPrint("Received arguments from Native App:");
        debugPrint(arguments);

        Map<String, dynamic> jsonObject = json.decode(arguments);

        debugPrint("Converted arguments to object: $jsonObject");
        debugPrint("Partner: ${jsonObject['partnerId']}");
        debugPrint("Secret: ${jsonObject['secret']}");
        debugPrint("Environment: ${jsonObject['env']}");
        debugPrint("Language: ${jsonObject['language']}");
        debugPrint("Customer Code: ${jsonObject['customerCode']}");

        debugPrint("Finished arguments conversion TESTE 2");

        late Language language;

        String lang = jsonObject['language'];

        switch (lang) {
          case 'es':
            language = Language.spanish;
            break;
          case 'en':
            language = Language.english;
            break;
          case 'pt':
            language = Language.portugues;
            break;
        }

        late Environment environment;

        String env = jsonObject['env'];

        switch (env) {
          case 'staging':
            environment = Environment.staging;
            break;
          case 'production':
            environment = Environment.production;
            break;
        }

        Flourish flourish = Flourish.initialize(
          partnerId: jsonObject['partnerId'],
          secret: jsonObject['secret'],
          env: environment,
          language: language,
        );
        debugPrint("Finished flourish sdk initialize method");

        debugPrint("Starting flourish sdk authenticate method");

        setState(() {
          _flourish = flourish;
        });

        flourish.authenticate(
            customerCode: jsonObject['customerCode']
        ).then((accessToken) {
          debugPrint("Success Token Received with success: $accessToken");
          setState(() {
            isLoading = false;
          });
        }
        ).catchError((er) {
          debugPrint(er);
        });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          home: Scaffold(
            body: Center(
              child: isLoading ?
                const CircularProgressIndicator():
                _flourish.home(),
            ),
          ),
        );
  }
}
