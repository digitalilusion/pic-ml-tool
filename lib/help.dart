import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatelessWidget {
  @override
  _launchGithub() async {
    const url = "https://github.com/digitalilusion/pic-ml-tool";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Can't launch GIT");
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help")),
      body: Column(
        children: <Widget>[
          Expanded(
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Text(
                          'Remove the boilerplate code to add images to your machine learning project. Define the upload endpoint and feed your algorithm with photos.'),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Text('The app upload using form multipart schema, the image taken under field "file" and an optional annotation under the field "annotation".'),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: RichText(text: TextSpan(
                          children: [
                            TextSpan(
                              text: "You can get a backend example in the ",
                              style: TextStyle(color: Colors.black)
                            ),

                            TextSpan(
                                text: "GitHub repository",
                                style: TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  _launchGithub();
                                }
                            )

                          ]
                        ))
                      )
                    ],
                  ))),
          Padding(
            child: Text("Made with Flutter"),
            padding: EdgeInsets.all(15),
          )
        ],
      ),
    );
  }
}
