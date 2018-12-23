# Picture ML Tool

Basic [Flutter](http://flutter.io) app that saves the boilerplate code to upload annotated images for your machine learning projects.

## Getting Started

Clone the repository and open it with `Android Studio`.

## Example backend

To test it you can use this simple backend written in NodeJS

```javascript
var http = require('http');
var formidable = require('formidable');
var fs = require('fs');

const PORT = 8080;

console.log("Pic ML Tool - Example backend in node.js");
console.log("Listening in: " + PORT);

http.createServer(function (req, res) {
  if (req.method != "POST") {
    res.writeHead(405);
    res.end();
    return;
  }
  var form = new formidable.IncomingForm();
  form.parse(req, function (err, fields, files) {
    if (!('file' in files)) {
      res.writeHead(404)
      res.end();
      return;
    }
    var f = files['file'];
    console.log("File: \""+ f.name +"\" (" + f.size + " bytes)");
    if ('annotation' in fields) {
      console.log("Annotation: \"" + fields['annotation'] + "\"");
    }
    try {
      fs.rename(f.path, "/tmp/" + f.name, function (err) {
        if (err) throw err;
      });
    } catch (err) {
      res.writeHead(500);
      res.end();
      return;
    }
    console.log("Saved in: /tmp/" + f.name);
    res.writeHead(201)
    //res.write("Paco")
    res.end();
  })
}).listen(PORT);
```

If you prefer, you can clone it from its [repository](https://github.com/digitalilusion/pic-ml-tool-backend).

## License

Apache 2.0
