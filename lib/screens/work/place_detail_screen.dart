import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/location.dart';
import '../../services/camera_service.dart';
import '../../services/database_service.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;
  const PlaceDetailScreen({super.key, required this.place});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final CameraService _cameraService = CameraService();
  bool isLoading = false;
  bool isTakingPhoto = false;

  Future<void> _takePhoto() async {
    if (isTakingPhoto || isLoading) return;

    try {
      setState(() {
        isTakingPhoto = true;
        isLoading = true;
      });

      final imagePath = await _cameraService.takePhoto();
      if (imagePath == null) {
        throw Exception('Failed to take photo');
      }

      // Verify file exists before saving to database
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Saved file not found');
      }

      await DatabaseService.instance.addImageToPlace(
        widget.place.id,
        imagePath,
      );

      // Refresh place data
      if (!mounted) return;
      await _refreshPlaceData();
    } catch (e) {
      if (!mounted) return;
      String errorMessage = 'Lỗi chụp ảnh';

      if (e.toString().contains('Permission')) {
        errorMessage = 'Vui lòng cấp quyền camera để chụp ảnh';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Không thể kết nối với camera';
      } else if (e.toString().contains('already active')) {
        errorMessage = 'Đang xử lý ảnh trước đó';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) {
        setState(() {
          isTakingPhoto = false;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshPlaceData() async {
    final places =
        await DatabaseService.instance.getPlacesForWard(widget.place.wardId);
    final updatedPlace = places.firstWhere((p) => p.id == widget.place.id);

    setState(() {
      widget.place.images.clear();
      widget.place.images.addAll(updatedPlace.images);
    });
  }

  void _showImageOptions(String imagePath) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa ảnh', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await _deleteImage(imagePath);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(String imagePath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa ảnh này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => isLoading = true);
        await DatabaseService.instance.deleteImage(widget.place.id, imagePath);

        // Refresh images list
        final places = await DatabaseService.instance
            .getPlacesForWard(widget.place.wardId);
        final updatedPlace = places.firstWhere((p) => p.id == widget.place.id);

        setState(() {
          widget.place.images.clear();
          widget.place.images.addAll(updatedPlace.images);
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa ảnh: $e')),
        );
      } finally {
        if (mounted) {
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPhotoGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: (isLoading || isTakingPhoto) ? null : _takePhoto,
        child: isLoading || isTakingPhoto
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (widget.place.images.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: widget.place.images.length,
      itemBuilder: (context, index) {
        final image = widget.place.images[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Tooltip(
            message: _getImageInfo(image),
            child: InkWell(
              onTap: () => _showImageDetails(image),
              onLongPress: () => _showImageOptions(image.path),
              child: Hero(
                tag: image.path,
                child: Image.file(
                  File(image.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có ảnh nào\nHãy chụp một số ảnh!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getImageInfo(PlaceImage image) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    return 'Chụp lúc: ${dateFormat.format(image.createdAt)}';
  }

  void _showImageDetails(PlaceImage image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: image.path,
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.contain, // Add fit property
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      // Wrap IconButton with Material
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Thông tin ảnh',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getImageInfo(image),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Xóa ảnh',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showImageOptions(image.path);
                      },
                    ),
                    const SizedBox(height: 8), // Add bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
