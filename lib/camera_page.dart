import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    required this.onDataSelected,
  });

  final CameraDescription camera;
  final ImageCallback onDataSelected;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

typedef ImageCallback = void Function(Uint8List data);

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            final compressedImage = await compressImage(image, 1024);
            if (!mounted) return;

            // If the picture was taken, display it on a new screen.

            widget.onDataSelected(compressedImage);
            Navigator.of(context).pop();
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e.toString());
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

Future<Uint8List> compressImage(XFile file, int maxSizeInKB) async {
  int currentSize;
  Uint8List? result2 = await file.readAsBytes();
  for (int quality = 100; quality > 0; quality -= 5) {
    result2 =
        await FlutterImageCompress.compressWithList(result2!, quality: quality);

    currentSize = result2.lengthInBytes;
    debugPrint("Current Image size: $currentSize bytes, Quality: $quality");

    if (currentSize < maxSizeInKB * 100) {
      break;
    }
  }

  return result2!;
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final Uint8List data;

  const DisplayPictureScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Column(children: [
        Image.memory(data),
        Text('size is:${data.lengthInBytes}')
      ]),
    );
  }
}
