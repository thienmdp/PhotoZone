import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/location.dart';

class PlaceCard extends StatelessWidget {
  final Place? place;
  final Color areaColor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlaceCard({
    super.key,
    required this.place,
    required this.areaColor,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  const PlaceCard.add({
    super.key,
    required this.areaColor,
    this.onTap,
  })  : place = null,
        onEdit = null,
        onDelete = null;

  bool get isAddCard => place == null;

  @override
  Widget build(BuildContext context) {
    if (isAddCard) {
      return _buildAddCard();
    }
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showOptions(context), // Pass context here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: areaColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child:
                    place!.images.isEmpty ? _buildEmptyImage() : _buildImage(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: areaColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: areaColor.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_location_alt,
                size: 40,
                color: areaColor.withOpacity(0.8),
              ),
              const SizedBox(height: 8),
              Text(
                'Thêm địa điểm',
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyImage() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Icon(
        Icons.place,
        size: 50,
        color: areaColor.withOpacity(0.8),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Image.file(
        File(place!.images.first.path),
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place!.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${place!.images.length} ảnh',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    if (onEdit == null || onDelete == null || place == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Sửa tên địa điểm'),
            onTap: () {
              Navigator.pop(context);
              onEdit?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title:
                const Text('Xóa địa điểm', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDelete?.call();
            },
          ),
        ],
      ),
    );
  }
}
