import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Calling App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const VideoCallScreen(),
    );
  }
}

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> with WidgetsBindingObserver {
  late CameraController _cameraController;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isUsingFrontCamera = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final frontCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );
    _cameraController = CameraController(
      _isUsingFrontCamera ? frontCamera : _cameras.first,
      ResolutionPreset.high,
    );
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cameraController.initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    super.dispose();
  }

  void _flipCamera() {
    setState(() {
      _isUsingFrontCamera = !_isUsingFrontCamera;
      _initializeCamera();
    });
  }

  Widget buildCameraPreview(CameraController cameraController) {
    const double previewAspectRatio = 1.0;
    return AspectRatio(
      aspectRatio: 1 / previewAspectRatio,
      child: ClipRect(
        child: Transform.scale(
          scale: cameraController.value.aspectRatio / previewAspectRatio,
          child: Center(
            child: CameraPreview(cameraController),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _isCameraOff
                ? Container(
              color: Colors.grey[900],
              child: const Center(
                child: Text('Camera Off'),
              ),
            )
                : _cameraController.value.isInitialized
                ? buildCameraPreview(_cameraController)
                : Container(),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[800],
              child: const Center(
                child: Text('Video Feed 2'),
              ),
            ),
          ),
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                  },
                  icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isCameraOff = !_isCameraOff;
                      if (_isCameraOff) {
                        _cameraController.dispose();
                      } else {
                        _initializeCamera();
                      }
                    });
                  },
                  icon: Icon(_isCameraOff ? Icons.videocam_off : Icons.videocam),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: _flipCamera,
                  icon: const Icon(Icons.flip_camera_ios),
                  color: Colors.white,
                ),
                CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                    onPressed: () => {},
                    icon: const Icon(Icons.call_end),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
