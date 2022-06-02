import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/providers/annotations.dart';
import 'package:translator_app/providers/complexPoem.dart';
import 'package:translator_app/screens/adminScreen.dart';

import './providers/textFieldManager.dart';
import './providers/canticle.dart';
import './providers/firebaseCommunicator.dart';

import './screens/authScreen.dart';
import './screens/homeScreen.dart';
import './screens/selectScreen.dart';
import './screens/complexPoemScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (ctx) => Annotations(),
            ),
            ChangeNotifierProvider(
              create: (ctx) => ComplexPoem(),
            ),
            ChangeNotifierProvider(
              create: (ctx) => FirebaseCommunicator(),
            ),
            ChangeNotifierProvider(
              create: (ctx) => Canticle(),
            ),
            ChangeNotifierProxyProvider<Canticle, TextFieldManager>(
              update: (ctx, canticle, previousTextFields) => TextFieldManager(
                previousTextFields == null ? [canticle.getVerse(0, canticle.currentCanto), canticle.getVerse(1, canticle.currentCanto), canticle.getVerse(2, canticle.currentCanto), canticle.translatedVerses] : previousTextFields.fieldData,
              ),
            ),
          ],
          child: Consumer<FirebaseCommunicator>(
            builder: (ctx, auth, _) => MaterialApp(
              title: 'Translator App',
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  accentColor: Colors.indigo,
                  textTheme: ThemeData.light().textTheme.copyWith(
                    subtitle2: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        decoration: TextDecoration.underline
                    ),
                    subtitle1: TextStyle(
                      fontSize: 13,
                    ),
                  )
              ),
              debugShowCheckedModeBanner: false,
              home: auth.isAuth ? HomeScreen() : AuthScreen(),
              routes: {
                AdminScreen.routeName: (ctx) => AdminScreen(),
                HomeScreen.routeName: (ctx) => HomeScreen(),
                AuthScreen.routeName: (ctx) => AuthScreen(),
                SelectScreen.routeName: (ctx) => SelectScreen(),
                ComplexPoemScreen.routeName: (ctx) => ComplexPoemScreen()
              },
            ),
          )
   );
  }
}