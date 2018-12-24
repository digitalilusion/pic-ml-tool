import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'help.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picture ML Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Picture ML Tool'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  String _uri = "";
  bool _isUploading = false;
  String _lastURL = null;
  TextStyle _stepsStyle = TextStyle(fontFamily: "Roboto", fontSize: 20.0);
  TextEditingController _urlController = TextEditingController();
  TextEditingController _annController = TextEditingController();

  void _getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  void _upload(BuildContext ctx) async {
    var stream = new http.ByteStream(DelegatingStream.typed(_image.openRead()));
    var length = await _image.length();
    var uri = Uri.parse(_uri);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(_image.path));
    request.files.add(multipartFile);
    request.fields["annotation"] = _annController.text;
    setState(() {
      _isUploading = true;
    });
    try {
      var response = await request.send();
      setState(() {
        _isUploading = false;
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        var prefs = await SharedPreferences.getInstance();
        if (prefs != null) {
          prefs.setString("lastURL", _uri);
          prefs.setString("lastAnn", _annController.text);
        }
        var content = await response.stream.transform(utf8.decoder).join();
        _showAlert(ctx, true, content);
      } else {
        var codeErr = response.statusCode;
        _showAlert(ctx, false, "$codeErr");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isUploading = false;
      });
      _showAlert(ctx, false, e.toString());
    }
  }

  void _showAlert(BuildContext ctx, bool isOk, String msg) {
    var body = isOk ? "Uploaded" : msg;
    if (isOk && msg != "") {
      body += " => " + msg;
    }
    showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isOk ? "Success!" : "Error"),
            content: Text(body),
            actions: <Widget>[
              new FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    _urlController.addListener(() {
      setState(() {
        if (_urlController.text == "") {
          _uri = "";
          return;
        }
        var urlPattern =
            r"^([a-z0-9+.-]+):(?://(?:((?:[a-z0-9-._~!$&'()*+,;=:]|%[0-9A-F]{2})*)@)?((?:[a-z0-9-._~!$&'()*+,;=]|%[0-9A-F]{2})*)(?::(\d*))?(/(?:[a-z0-9-._~!$&'()*+,;=:@/]|%[0-9A-F]{2})*)?|(/?(?:[a-z0-9-._~!$&'()*+,;=:@]|%[0-9A-F]{2})+(?:[a-z0-9-._~!$&'()*+,;=:@/]|%[0-9A-F]{2})*)?)(?:\?((?:[a-z0-9-._~!$&'()*+,;=:/?@]|%[0-9A-F]{2})*))?(?:#((?:[a-z0-9-._~!$&'()*+,;=:/?@]|%[0-9A-F]{2})*))?$";
        var ret = RegExp(urlPattern, caseSensitive: false)
            .firstMatch(_urlController.text);
        if (ret != null) {
          _uri = ret.group(0);
        } else {
          _uri = null;
        }
        ;
      });
    });
    if (_lastURL == null) {
      SharedPreferences.getInstance().then((prefs) {
        _lastURL = prefs.getString("lastURL");
        if (_lastURL != null) {
          setState(() {
            _uri = _lastURL;
            _urlController.text = _lastURL;
          });
        }
        _annController.text = prefs.getString("lastAnn");
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpPage()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Theme(
                        data: ThemeData(
                            primaryColor: _uri != null
                                ? Colors.blueAccent
                                : Colors.redAccent,
                            primaryColorDark:
                                _uri != null ? Colors.blue : Colors.red),
                        child: TextField(
                          decoration: InputDecoration(
                              labelText: '1. Enter URI EP',
                              hintText: 'https://myserver.com/ml-pic-upload',
                              helperText: _uri == null
                                  ? "You must enter a valid URL Endpoint"
                                  : "",
                              helperStyle: TextStyle(color: Colors.red)),
                          keyboardType: TextInputType.url,
                          controller: _urlController,
                        )),
                    TextField(
                      decoration: InputDecoration(
                        labelText: '2. Enter pic annotation (optional)',
                        hintText: 'cat',
                        helperText: "for supervised learning",
                      ),
                      controller: _annController,
                    )
                  ],
                ))),
            Center(
                child: _image == null
                    ? Text('Not image selected')
                    : Image.file(_image)),
            RaisedButton(
              child: Text(_isUploading ? "UPLOADING..." : "UPLOAD"),
              onPressed: _image != null &&
                      _uri != null &&
                      _uri.length > 0 &&
                      !_isUploading
                  ? () {
                      _upload(context);
                    }
                  : null,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
