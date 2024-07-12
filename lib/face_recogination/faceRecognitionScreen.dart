import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:flutter/material.dart';
import 'detector_painters.dart';
import 'utils.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:quiver/collection.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  final storageStatus = await Permission.manageExternalStorage.request();

  if (storageStatus == PermissionStatus.granted) {
    // Permission granted, proceed with storage access
    print('Storage permission granted');
  } else if (storageStatus == PermissionStatus.permanentlyDenied) {
    // Handle permanently denied permission (optional)
    await openAppSettings(); // Open app settings to allow permission
  } else {
    // Explain why storage access is necessary and request again
  }
}

class FaceRecognition extends StatefulWidget {
  FaceRecognition({required this.type, required this.classId});
  String type;
  String classId;
  @override
  _FaceRecognitionState createState() => _FaceRecognitionState();
  
}

class _FaceRecognitionState extends State<FaceRecognition> {
  File? jsonFile;
  dynamic _scanResults;
  CameraController? _camera;
  var interpreter;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;
  dynamic data = {};
  double threshold = 1.0;
  Directory? tempDir;
  List? e1;
  bool _faceFound = false;
  final TextEditingController _name = new TextEditingController();
  final TextEditingController _regNo = new TextEditingController();

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _initializeCamera();
  }

  Future loadModel() async {
    try {
      // final gpuDelegateV2 = tfl.GpuDelegateV2(
      //     options: tfl.GpuDelegateOptionsV2(
      //   isPrecisionLossAllowed: false,
      //   inferencePreference: tfl.TfLiteGpuInferenceUsage.fastSingleAnswer,
      //   inferencePriority1: tfl.TfLiteGpuInferencePriority.minLatency,
      //   inferencePriority2: tfl.TfLiteGpuInferencePriority.auto,
      //   inferencePriority3: tfl.TfLiteGpuInferencePriority.auto,
      // ));
      //
      // var interpreterOptions = tfl.InterpreterOptions()
      //   ..addDelegate(gpuDelegateV2);
      interpreter = await tfl.Interpreter.fromAsset('assets/model/mobilefacenet.tflite',
          );
    } on Exception {
      print('Failed to load model.');
    }
  }

  // void _initializeCamera() async {
  //   await loadModel();
  //   CameraDescription description = await getCamera(_direction);
  //
  //   ImageRotation rotation = rotationIntToImageRotation(
  //     description.sensorOrientation,
  //   );
  //
  //   _camera =
  //       CameraController(description, ResolutionPreset.low, enableAudio: false);
  //   await _camera!.initialize();
  //   await Future.delayed(Duration(milliseconds: 500));
  //   tempDir = await getApplicationDocumentsDirectory();
  //   String _embPath = tempDir!.path + '/emb.json';
  //   jsonFile = new File(_embPath);
  //   if (jsonFile!.existsSync()) data = json.decode(jsonFile!.readAsStringSync());
  //
  //   _camera!.startImageStream((CameraImage image) {
  //     if (_camera != null) {
  //       if (_isDetecting) return;
  //       _isDetecting = true;
  //       String res;
  //       dynamic finalResult = Multimap<String, Face>();
  //       detect(image, _getDetectionMethod(), rotation).then(
  //         (dynamic result) async {
  //           if (result.length == 0)
  //             _faceFound = false;
  //           else
  //             _faceFound = true;
  //           Face _face;
  //           imglib.Image convertedImage =
  //               _convertCameraImage(image, _direction);
  //           for (_face in result) {
  //             double x, y, w, h;
  //             x = (_face.boundingBox.left - 10);
  //             y = (_face.boundingBox.top - 10);
  //             w = (_face.boundingBox.width + 10);
  //             h = (_face.boundingBox.height + 10);
  //             imglib.Image croppedImage = imglib.copyCrop(
  //                 convertedImage, x.round(), y.round(), w.round(), h.round());
  //             croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
  //             // int startTime = new DateTime.now().millisecondsSinceEpoch;
  //             res = _recog(croppedImage);
  //             // int endTime = new DateTime.now().millisecondsSinceEpoch;
  //             // print("Inference took ${endTime - startTime}ms");
  //             finalResult.add(res, _face);
  //           }
  //           setState(() {
  //             _scanResults = finalResult;
  //           });
  //
  //           _isDetecting = false;
  //         },
  //       ).catchError(
  //         (_) {
  //           _isDetecting = false;
  //         },
  //       );
  //     }
  //   });
  // }

  void _initializeCamera() async {
    await loadModel();
    CameraDescription description = await getCamera(_direction);


    _camera = CameraController(
        description,
        ResolutionPreset.low, enableAudio: false,

    );
    await _camera!.initialize();
    await Future.delayed(Duration(milliseconds: 500));

    // Fetch student data from Firestore
    String classId = widget.classId; // Replace with your actual class ID
    var classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    classRef.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Safely retrieve students data from Firestore
        Map<String, dynamic>? studentsData = documentSnapshot.data() as Map<String, dynamic>?;

        if (studentsData != null) {
          // Ensure 'students' field exists and is correctly typed
          data = studentsData['students'] ?? {};


          _camera!.startImageStream((CameraImage image) {
            if (_camera != null) {
              if (_isDetecting) return;
              _isDetecting = true;

              ImageRotation rotation = rotationIntToImageRotation(description.sensorOrientation);
              String res;
              dynamic finalResult = Multimap<String, Face>();
              detect(image, _getDetectionMethod(), rotation).then(
                    (dynamic result) async {
                  if (result.length == 0)
                    _faceFound = false;
                  else
                    _faceFound = true;

                  Face _face;
                  imglib.Image convertedImage = _convertCameraImage(image, _direction);

                  for (_face in result) {
                    double x, y, w, h;
                    x = (_face.boundingBox.left - 10);
                    y = (_face.boundingBox.top - 10);
                    w = (_face.boundingBox.width + 10);
                    h = (_face.boundingBox.height + 10);

                    imglib.Image croppedImage = imglib.copyCrop(
                        convertedImage, x.round(), y.round(), w.round(), h.round());

                    croppedImage = imglib.copyResizeCropSquare(croppedImage, 112);
                    res = _recog(croppedImage);
                    finalResult.add(res, _face);
                  }

                  setState(() {
                    _scanResults = finalResult;
                  });

                  _isDetecting = false;
                },
              ).catchError(
                    (_) {
                  _isDetecting = false;
                },
              );
            }
          });
        } else {
          print('No students data found in Firestore');
        }
      } else {
        print('Document does not exist in Firestore');
      }
    }).catchError((error) {
      print('Failed to fetch document from Firestore: $error');
    });
  }


  HandleDetection _getDetectionMethod() {
    final faceDetector = GoogleVision.instance.faceDetector(
      FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
    return faceDetector.processImage;
  }

  Widget _buildResults() {
    const Text noResultsText = const Text('');
    if (_scanResults == null ||
        _camera == null ||
        !_camera!.value.isInitialized) {
      return noResultsText;
    }
    CustomPainter painter;

    final Size imageSize = Size(
      _camera!.value.previewSize!.height,
      _camera!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, _scanResults);
    return CustomPaint(
      painter: painter,
    );
  }

  Widget _buildImage() {
    if (_camera == null || !_camera!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(_camera!),
                _buildResults(),
              ],
            ),
    );
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }
    await _camera!.stopImageStream();
    await _camera!.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face recognition'),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: (Choice result) {
              if (result == Choice.delete)
                _resetFile();
              else
                _viewLabels();
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Choice>>[
              const PopupMenuItem<Choice>(
                child: Text('View Saved Faces'),
                value: Choice.view,
              ),
              const PopupMenuItem<Choice>(
                child: Text('Remove all faces'),
                value: Choice.delete,
              )
            ],
          ),
        ],
      ),
      body: _buildImage(),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        widget.type=="addNew"?
        FloatingActionButton(
          backgroundColor: (_faceFound) ? Colors.blue : Colors.blueGrey,
          child: Icon(Icons.add),
          onPressed: () {
            if (_faceFound) _addLabel();
          },
          heroTag: null,
        ):
        FloatingActionButton(
          onPressed: ()async{
            print("*********Rresults ******************");

            //markAttendance(widget.classId, regNo, 'P');
            print(await _scanResults.keys);
            await markAllStudentsAttendance();

          },
          child: Icon(Icons.compare),
        ),
        SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          onPressed: _toggleCameraDirection,
          heroTag: null,
          child: _direction == CameraLensDirection.back
              ? const Icon(Icons.camera_front)
              : const Icon(Icons.camera_rear),
        ),
      ]),
    );
  }

  imglib.Image _convertCameraImage(
      CameraImage image, CameraLensDirection _dir) {
    int width = image.width;
    int height = image.height;
    // imglib -> Image package from https://pub.dartlang.org/packages/image
    var img = imglib.Image(width, height); // Create Image buffer
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    var img1 = (_dir == CameraLensDirection.front)
        ? imglib.copyRotate(img, -90)
        : imglib.copyRotate(img, 90);
    return img1;
  }

  String _recog(imglib.Image img) {
    List input = imageToByteListFloat32(img, 112, 128, 128);
    input = input.reshape([1, 112, 112, 3]);
    List output = List.filled(1 * 192,0).reshape([1, 192]);
    interpreter.run(input, output);
    output = output.reshape([192]);
    e1 = List.from(output);
    return compare(e1!).toUpperCase();
  }

  String compare(List currEmb) {
    if (data.length == 0) return "No Face saved";
    double minDist = 999;
    double currDist = 0.0;
    String predRes = "NOT RECOGNIZED";
    for (String label in data.keys) {
      currDist = euclideanDistance(data[label], currEmb);
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = label;
      }
    }
    print(minDist.toString() + " " + predRes);
    return predRes;
  }

  void _resetFile() {
    data = {};
    jsonFile!.deleteSync();
  }

  void _viewLabels() {
    setState(() {
      _camera = null;
    });
    String name;
    var alert = new AlertDialog(
      title: new Text("Saved Faces"),
      content: new ListView.builder(
          padding: new EdgeInsets.all(2),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            name = data.keys.elementAt(index);
            return new Column(
              children: <Widget>[
                new ListTile(
                  title: new Text(
                    name,
                    style: new TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                new Padding(
                  padding: EdgeInsets.all(2),
                ),
                new Divider(),
              ],
            );
          }),
      actions: <Widget>[
        new ElevatedButton(
          child: Text("OK"),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }
  
  void _addLabel() {
    setState(() {
      _camera = null;
    });
    print("Adding new face");
    var alert =  AlertDialog(
      title: Text(
        "Add Face",
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Name",
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Icons.face,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _regNo,
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Reg No",
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(
                Icons.face,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text(
            "Save",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            _handle(_name.text.toUpperCase(), _regNo.text.toUpperCase());
            _name.clear();
            _regNo.clear();
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: Text(
            "Cancel",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            _initializeCamera();
            Navigator.pop(context);
          },
        ),
      ],
    );

    showDialog(
        context: context,
        builder: (context) {
          return alert;
        });
  }

  // void _handle(String text,String regNo) {
  //   String fullName = text +","+ regNo;
  //   data[fullName] = e1;
  //   jsonFile!.writeAsStringSync(json.encode(data));
  //   _initializeCamera();
  // }



  void _handle(String text, String regNo) {
    String fullName = '$text,$regNo';
    // Assuming `jsonFile` and `data` are defined somewhere in your class
    // Update `data` with new student information
    data[fullName] = e1;


    // Save student data to Firestore
    String classId = widget.classId; // Replace with your actual class ID
    var classRef = FirebaseFirestore.instance.collection('classes').doc(classId);

    // Fetch current document snapshot
    classRef.get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // Get current students map from Firestore document
        Map<String, dynamic>? currentData = documentSnapshot.data() as Map<String, dynamic>?;

        if (currentData != null) {
          // Ensure 'students' field exists and is a map
          Map<String, dynamic> currentStudents = currentData['students'] ?? {};

          // Add or update new student data in the map
          currentStudents[fullName] = e1;

          // Update Firestore document with updated students map
          classRef.update({'students': currentStudents}).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Student saved successfully!')),
            );
            print('Student added/updated successfully in Firestore!');
          }).catchError((error) {
            print('Failed to update student in Firestore: $error');
          });
        } else {
          print('Document data is null');
        }
      } else {
        print('Document does not exist in Firestore');
      }
    }).catchError((error) {
      print('Failed to fetch document from Firestore: $error');
    });

    // Initialize camera or any other operations
    _initializeCamera();
  }


  Future<void> markAllAttendance(String classId, List<String> keys, String status) async {
    var classRef = FirebaseFirestore.instance.collection('classes').doc(classId);
    String todayDate = DateTime.now().toIso8601String().substring(0, 10); // Format as 'YYYY-MM-DD'

    // Fetch the current document snapshot
    DocumentSnapshot documentSnapshot = await classRef.get();

    if (documentSnapshot.exists) {
      Map<String, dynamic>? currentData = documentSnapshot.data() as Map<String, dynamic>?;

      if (currentData != null) {
        // Ensure 'attendance' field exists and is a map
        Map<String, dynamic> currentAttendance = currentData['attendance'] ?? {};

        // Check if today's date already exists in the attendance map
        if (currentAttendance.containsKey(todayDate)) {
          // Update the attendance for all students for today
          for (var key in keys) {
            List<String> parts = key.split(',');
            if (parts.length >= 1) {
              String regNo = parts[1].trim();
              currentAttendance[todayDate][regNo] = status;
            }
          }
        }
        else {
          // Create a new attendance record for today
          Map<String, dynamic> newAttendanceRecord = {};

          // Mark all students as absent initially
          Map<String, dynamic> currentStudents = currentData['students'] ?? {};
          currentStudents.forEach((key, value) {
            String studentRegNo = key.split(',')[1]; // Extract regNo from 'fullName'
            newAttendanceRecord[key] = 'A';
          });

          // Mark the specified students' attendance
          for (var key in keys) {
            List<String> parts = key.split(',');
            if (parts.length >= 1) {
              String regNo = parts[1].trim();
              newAttendanceRecord[key] = status;
            }
          }

          // Add the new attendance record to the attendance map
          currentAttendance[todayDate] = newAttendanceRecord;
        }

        // Update Firestore document with the updated attendance map
        await classRef.update({'attendance': currentAttendance});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked successfully!')),
        );
        print('Attendance marked successfully!');
      }
      else {
        print('Failed to retrieve current data from Firestore');
      }
    } else {
      print('Document does not exist in Firestore');
    }
  }

  Future<void> markAllStudentsAttendance() async {
    List<String> keys = _scanResults.keys.toList();

    // Call markAllAttendance with the list of keys
    await markAllAttendance(widget.classId, keys, "P");
  }




//
  // Future<void> markAttendance(String classId, String regNo, String status) async {
  //   var classRef = FirebaseFirestore.instance.collection('classes').doc(classId);
  //   String todayDate = DateTime.now().toIso8601String().substring(0, 10); // Format as 'YYYY-MM-DD'
  //
  //   // Fetch the current document snapshot
  //   DocumentSnapshot documentSnapshot = await classRef.get();
  //
  //   if (documentSnapshot.exists) {
  //     Map<String, dynamic>? currentData = documentSnapshot.data() as Map<String, dynamic>?;
  //
  //     if (currentData != null) {
  //       // Ensure 'attendance' field exists and is a map
  //       Map<String, dynamic> currentAttendance = currentData['attendance'] ?? {};
  //
  //       // Check if today's date already exists in the attendance map
  //       if (currentAttendance.containsKey(todayDate)) {
  //         // Update the student's attendance for today
  //         currentAttendance[todayDate][regNo] = status;
  //       }
  //       else {
  //         // Create a new attendance record for today
  //         Map<String, dynamic> newAttendanceRecord = {};
  //
  //         // Mark all students as absent initially
  //         Map<String, dynamic> currentStudents = currentData['students'] ?? {};
  //         currentStudents.forEach((key, value) {
  //           String studentRegNo = key.split(',')[1]; // Extract regNo from 'fullName'
  //           newAttendanceRecord[studentRegNo] = 'A';
  //         });
  //
  //         // Mark the specified student's attendance
  //         newAttendanceRecord[regNo] = status;
  //
  //         // Add the new attendance record to the attendance map
  //         currentAttendance[todayDate] = newAttendanceRecord;
  //       }
  //
  //       // Update Firestore document with the updated attendance map
  //       await classRef.update({'attendance': currentAttendance});
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Attendance marked successfully!')),
  //       );
  //       print('Attendance marked successfully!');
  //     }
  //     else {
  //       print('Failed to retrieve current data from Firestore');
  //     }
  //   }
  //   else {
  //     print('Document does not exist in Firestore');
  //   }
  // }
  //



}

