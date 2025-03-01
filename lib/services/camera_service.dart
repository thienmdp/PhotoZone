import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final ImagePicker _picker = ImagePicker();
  bool _isPickerActive = false;
  DateTime? _lastPhotoTime;

  Future<String?> takePhoto() async {
    if (_isPickerActive) {
      print('Camera is already active');
      await Future.delayed(const Duration(milliseconds: 500));
      _isPickerActive = false;
    }

    try {
      _isPickerActive = true;

      // Kiểm tra quyền trước
      if (!await _checkAndRequestPermissions()) {
        _isPickerActive = false;
        return null;
      }

      // Tạo thư mục trước
      final String saveDir = await _createStorageDirectory();

      print('Opening camera...');
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1280, // Giảm kích thước để tránh vấn đề bộ nhớ
        maxHeight: 720,
        imageQuality: 85,
      );

      if (photo == null) {
        print('No photo taken');
        _isPickerActive = false;
        return null;
      }

      // Tạo tên file và đường dẫn lưu
      final String fileName =
          'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = path.join(saveDir, fileName);

      try {
        // Copy và verify file
        final File sourceFile = File(photo.path);
        final File savedFile = await sourceFile.copy(savedPath);

        if (await savedFile.exists()) {
          print('Photo saved to: ${savedFile.path}');
          return savedFile.path;
        }
      } catch (e) {
        print('Error saving file: $e');
        // Thử phương án backup nếu copy thất bại
        try {
          final bytes = await photo.readAsBytes();
          final File savedFile = File(savedPath);
          await savedFile.writeAsBytes(bytes);

          if (await savedFile.exists()) {
            print('Photo saved using backup method: ${savedFile.path}');
            return savedFile.path;
          }
        } catch (e) {
          print('Backup save method failed: $e');
        }
      }

      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    } finally {
      _isPickerActive = false;
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    // Kiểm tra và yêu cầu quyền camera
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        print('Camera permission denied');
        return false;
      }
    }

    // Kiểm tra và yêu cầu quyền storage trên Android
    if (Platform.isAndroid) {
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          print('Storage permission denied');
          return false;
        }
      }
    }

    return true;
  }

  Future<String> _createStorageDirectory() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String photosDir = path.join(appDir.path, 'photos');

      final Directory photosDirRef = Directory(photosDir);
      if (!await photosDirRef.exists()) {
        await photosDirRef.create(recursive: true);
        print('Created directory: $photosDir');
      }

      return photosDir;
    } catch (e) {
      print('Error creating storage directory: $e');
      rethrow;
    }
  }

  Future<bool> deletePhoto(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('Deleted file: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
