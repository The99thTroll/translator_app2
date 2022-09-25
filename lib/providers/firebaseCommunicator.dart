import 'dart:convert';
import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/httpException.dart';

class FirebaseCommunicator with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  String _userName;
  Timer _authTimer;
  List cachedData;
  List cachedUserData;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if(_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())){
      return _token;
    }
    return null;
  }

  String get userName {
    return _userName;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlSegment, [dynamic data]) async {
    final url = 'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyC4FdZyjR4YHZnQnlUqIf-Lz_Ig81GQWxU';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
          Duration(
              seconds: int.parse(responseData['expiresIn'])
          )
      );

      if(urlSegment == "signupNewUser"){
        var url = "https://text-translator-53afd-default-rtdb.firebaseio.com/users.json?auth=$_token";
        final response = await http.post(
            url,
            body: json.encode({
              'name': data["name"],
              'userId': _userId,
              'signUpDate': DateTime.now().toIso8601String(),
              'signIns': [DateTime.now().toIso8601String()],
            })
        );
        _userName = data["name"];
      }else{
        var url = 'https://text-translator-53afd-default-rtdb.firebaseio.com/users.json?auth=$_token&orderBy="userId"&equalTo="$_userId"';
        final response = await http.get(
          url,
        );

        final extractedData = json.decode(response.body) as Map<String, dynamic>;
        var newData = extractedData.values.toList();
        var id = extractedData.keys.toList()[0];
        var loginDates = newData[0]['signIns'];
        loginDates.add(DateTime.now().toIso8601String());

        url = 'https://text-translator-53afd-default-rtdb.firebaseio.com/users/$id.json?auth=$_token';
        _userName = newData[0]['name'];
        final patchRequest = await http.patch(
          url,
          body: json.encode({
            'signIns': loginDates
          })
        );
      }

      _autoLogout();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password, String name) async {
    return _authenticate(email, password, 'signupNewUser', {'name': name});
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  void logout () {
    _token = null;
    _userId = null;
    _expiryDate = null;
    cachedData = null;
    cachedUserData = null;

    if(_authTimer != null){
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();
  }

  void _autoLogout() {
    if(_authTimer != null){
      _authTimer.cancel();
    }
    final timeToExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(
        Duration(seconds: timeToExpire),
        logout
    );
  }

  Future<void> savePoem({List data, String title, String original, int canticleIndex,
    int cantoIndex, List translators, List boxes, List annotations, int version = 1}) async {
    int start = DateTime.now().millisecondsSinceEpoch;

    var url = "https://text-translator-53afd-default-rtdb.firebaseio.com/userPoetry.json?auth=$_token";

    final response = await http.post(
        url,
        body: json.encode({
          'verses': data,
          'title': title,
          'boxData': boxes,
          'original': original,
          'canticleIndex': canticleIndex,
          'cantoIndex': cantoIndex,
          'translator1': {
            'name': translators[0][0],
            'index': translators[0][1]
          },
          'translator2': {
            'name': translators[1][0],
            'index': translators[1][1]
          },
          'userId': _userId,
          'userName': _userName,
          'postDate': DateTime.now().toIso8601String(),
          'version': version,
          'complex': false,
          'annotations': annotations
        })
    );

    if (response.statusCode >= 400) {
      throw HttpException("Error!");
    }

    notifyListeners();
    print("Data POST time taken: ${DateTime.now().millisecondsSinceEpoch - start} ms");
  }

  Future<void> saveComplexPoem(
      {List data, String title, String original, int canticleIndex, List annotations,
        int cantoIndex, List translators, List translatorIndex, int version = 1}) async {
    int start = DateTime.now().millisecondsSinceEpoch;
    var url = "https://text-translator-53afd-default-rtdb.firebaseio.com/userPoetry.json?auth=$_token";

    final response = await http.post(
        url,
        body: json.encode({
          'verses': data,
          'title': title,
          'original': original,
          'canticleIndex': canticleIndex,
          'cantoIndex': cantoIndex,
          'translators': translators,
          'translatorIndex': translatorIndex,
          'userId': _userId,
          'userName': _userName,
          'postDate': DateTime.now().toIso8601String(),
          'version': version,
          'complex': true,
          'annotations': annotations
        })
    );

    if (response.statusCode >= 400) {
      throw HttpException("Error!");
    }

    notifyListeners();
    print("Data POST time taken: ${DateTime.now().millisecondsSinceEpoch - start} ms");
  }

  Future<List> loadStoredPoems([bool forced = false]) async {
    if (cachedData == null || forced) {
      var url = "https://text-translator-53afd-default-rtdb.firebaseio.com/userPoetry.json?auth=$_token";
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      var items = [];

      if (extractedData != null) {
        extractedData.forEach(
          (key, value) {
            items.add([key, value]);
          }
        );
      }
      cachedData = items;
      return items;
    }else{
     return cachedData;
    }
  }

  Future<List> loadMyPoems([bool forced = false]) async {
    if (cachedUserData == null || forced) {
      var url = 'https://text-translator-53afd-default-rtdb.firebaseio.com/userPoetry.json?auth=$_token&orderBy="userId"&equalTo="$_userId"';
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      var items = [];

      if (extractedData != null) {
        extractedData.forEach(
                (key, value) {
              items.add([key, value]);
            }
        );
      }
      cachedUserData = items;
      return items;
    } else {
      return cachedUserData;
    }
  }

  bool userMatches(String userId){
    return userId == _userId;
  }

  deletePoem(String id) async {
    var url = 'https://text-translator-53afd-default-rtdb.firebaseio.com/userPoetry/$id.json?auth=$_token';
    final response = await http.delete(url);

    notifyListeners();
  }

  Future<List> getUsers([String filterName]) async {
    var url = filterName == null
        ? 'https://text-translator-53afd-default-rtdb.firebaseio.com/users.json?auth=$_token'
        : 'https://text-translator-53afd-default-rtdb.firebaseio.com/users.json?auth=$_token&orderBy="name"&equalTo="$filterName"';
    final response = await http.get(url);
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    var items = [];

    if (extractedData != null) {
      extractedData.forEach(
              (key, value) {
            items.add([key, value]);
          }
      );
    }

    return items;
  }

  addAnnotation(text, id, sentiment, index) async {
    final url = 'https://text-translator-53afd-default-rtdb.firebaseio.com/userPoetry/$id/annotations/$index.json?auth=$_token';
    final data = await http.get(url);
    var extractedData = json.decode(data.body);
    final url2 = 'https://text-translator-53afd-default-rtdb.firebaseio.com/userPoetry/$id/annotations.json?auth=$_token';

    var dataToSend = [

    ];

    var prevHash = 0;

    for(var x = 0; x < extractedData.length; x++){
      if(extractedData[x] == "FILLER"){
        dataToSend.add("FILLER");
      }else if(extractedData[x].containsKey("subAnnotations")){
        dataToSend.add({
          "annotation": extractedData[x]["annotation"],
          "time": extractedData[x]["time"],
          "username": extractedData[x]["username"],
          "id": extractedData[x]["id"],
          "subAnnotations": extractedData[x]["subAnnotations"]
        });
      }else{
        dataToSend.add({
          "annotation": extractedData[x]["annotation"],
          "time": extractedData[x]["time"],
          "username": extractedData[x]["username"],
          "id": extractedData[x]["id"],
        });
      }

      if(x == extractedData.length - 1){
        prevHash = extractedData[x]['currentHash'];
      }
    }

    var hashableData = {
      "annotation": {
        'data': text,
        'sentiment': sentiment
      },
      "time": DateTime.now().toIso8601String(),
      "username": userName,
      "previousHash": prevHash,
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var hash = sha256.convert(utf8.encode(hashableData.toString()));

    print(hash.toString());
    if(hash.toString().toUpperCase() == "A" || hash.toString() == "a"){

    }

    dataToSend.add(
        {
          "annotation": {
            'data': text,
            'sentiment': sentiment
          },
          "time": DateTime.now().toIso8601String(),
          "username": userName,
          "previousHash": prevHash,
          'currentHash': hash.toString(),
          "id": DateTime.now().millisecondsSinceEpoch
        }
    );

    var x = await http.patch(url2, body: json.encode({index.toString(): dataToSend}));
  }

  addNestedAnnotation(text, id, index, subIndex) async {
    final url = 'https://text-translator-53afd-default-rtdb.firebaseio.com/userPoetry/$id/annotations/$index/$subIndex.json?auth=$_token';
    final data = await http.get(url);
    var extractedData = json.decode(data.body);

    var dataToSend = [

    ];

    if (extractedData.containsKey("subAnnotations")) {
      for(var x = 0; x < extractedData["subAnnotations"].length; x++){
        dataToSend.add({
          "annotation": extractedData["subAnnotations"][x]["annotation"],
          "time": extractedData["subAnnotations"][x]["time"],
          "username": extractedData["subAnnotations"][x]["username"],
          "id": extractedData["subAnnotations"][x]["id"],
        });
      }
    }

    dataToSend.add(
        {
          "annotation": text,
          "time": DateTime.now().toIso8601String(),
          "username": userName,
          "id": DateTime.now().millisecondsSinceEpoch
        }
    );

    var x = await http.patch(url, body: json.encode({'subAnnotations': dataToSend}));
    print(x);

    if(x.persistentConnection != true){}
  }
}
