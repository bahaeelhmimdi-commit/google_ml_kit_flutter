import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async'; // <-- Add this import for Completer
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

double calculateDistanceRatio(double ax, double ay, double bx, double by, double cx, double cy) {
  // Calculate distance between A and B
  double distance1 = sqrt(pow(bx - ax, 2) + pow(by - ay, 2));

  // Calculate distance between C and B
  double distance2 = sqrt(pow(bx - cx, 2) + pow(by - cy, 2));

  if (distance2 == 0) {
    throw Exception("Distance between C and B is zero, ratio is undefined.");
  }

  // Calculate ratio and convert to percentage
  var rs=distance1 / distance2;
  if (rs>1){rs=1-rs;}
  return (rs) * 100;
}
final lands = {

};

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.green;

    for (final Face face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );

  //    canvas.drawRect(
    //    Rect.fromLTRB(left, top, right, bottom),
      //  paint1,
    //  );
     painting(canvas);
      void paintContour(FaceContourType type) {
        final contour = face.contours[type];

        if (contour?.points != null) {
          for (final Point point in contour!.points) {

            canvas.drawCircle(
                Offset(
                  translateX(
                    point.x.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                  translateY(
                    point.y.toDouble(),
                    size,
                    imageSize,
                    rotation,
                    cameraLensDirection,
                  ),
                ),
                1,
                paint1);
          }
        }
      }

      void paintLandmark(FaceLandmarkType type) {
        final landmark = face.landmarks[type];
        if (landmark?.position != null) {
              lands[type.name]=face.landmarks[type];





        //  canvas.drawCircle(
          //    Offset(
            //    translateX(
              //    landmark!.position.x.toDouble(),
            //      size,
            //      imageSize,
              //    rotation,
          //        cameraLensDirection,
         //       ),
         //       translateY(
         //         landmark.position.y.toDouble(),
         //         size,
         //         imageSize,
           //       rotation,
           //       cameraLensDirection,
          //      ),
          //    ),
          //    2,
          //    paint2);
        }
      }

   //   for (final type in FaceContourType.values) {
     //   paintContour(type);
   //   }

      for (final type in FaceLandmarkType.values) {
        paintLandmark(type);
        print(lands.length);
      }
      var ax = lands["leftMouth"]!.position.x.toDouble();
      var ay = lands["leftMouth"]!.position.y.toDouble();
      var bx = lands["noseBase"]!.position.x.toDouble();
      var by = lands["noseBase"]!.position.y.toDouble();
      var cx = lands["rightMouth"]!.position.x.toDouble();
      var cy = lands["rightMouth"]!.position.y.toDouble();

      int result = calculateDistanceRatio(ax, ay, bx, by, cx, cy).round();
      var direction;
      if(result>0){direction="<< left";} else{direction="right >>";};

      TextSpan span = new TextSpan(style: new TextStyle(color: Colors.blue[800],fontSize: 40.0), text: result.abs().toString()+"% to the "+direction);
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
      tp.layout();
      Future<void> sendData() async {
      final url = 'http://tlk.pythonanywhere.com/data'; // Use 10.0.2.2 for Android emulator
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nom":  "data",

        }),
      );}
      //sendData();
      tp.paint(canvas, new  Offset(
        translateX(
          lands["noseBase"]!.position.x.toDouble(),
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        ),
        translateY(
          lands["noseBase"]!.position.y.toDouble(),
          size,
          imageSize,
          rotation,
          cameraLensDirection,
        ),
      ));

    }
  }
  void painting(Canvas canvas) async {
    var file = await DefaultCacheManager().getSingleFile("https://diapo.pythonanywhere.com/static/alae_aaa.jpg");
    if (file != null && file.existsSync()) {
      final img = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(img);
      final frame = await codec.getNextFrame();
      canvas.drawImage(frame.image, Offset(0, 0), Paint());
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}


