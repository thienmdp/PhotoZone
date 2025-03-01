import 'package:flutter/material.dart';
import '../../../models/location.dart';
import 'place_card.dart';

class WardTile extends StatelessWidget {
  final Ward ward;
  final Area area;
  final Color areaColor;
  final Function(Ward, Area) onEditWard;
  final Function(Ward) onDeleteWard;
  final Function(Ward) onAddPlace;
  final Function(Place) onTapPlace;
  final Function(Place) onEditPlace;
  final Function(Place) onDeletePlace;

  const WardTile({
    super.key,
    required this.ward,
    required this.area,
    required this.areaColor,
    required this.onEditWard,
    required this.onDeleteWard,
    required this.onAddPlace,
    required this.onTapPlace,
    required this.onEditPlace,
    required this.onDeletePlace,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: areaColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.business, color: Colors.blueGrey[700]),
      ),
      title: GestureDetector(
        onLongPress: () => _showOptions(context),
        child: Text(
          ward.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      subtitle: Text(
        '${ward.places.length} địa điểm',
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Changed from crossCount to crossAxisCount
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: ward.places.length + 1,
          itemBuilder: (context, index) {
            if (index == ward.places.length) {
              return PlaceCard.add(
                areaColor: areaColor,
                onTap: () => onAddPlace(ward),
              );
            }
            return PlaceCard(
              place: ward.places[index],
              areaColor: areaColor,
              onTap: () => onTapPlace(ward.places[index]),
              onEdit: () => onEditPlace(ward.places[index]),
              onDelete: () => onDeletePlace(ward.places[index]),
            );
          },
        ),
      ],
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Sửa tên phường/xã'),
            onTap: () {
              Navigator.pop(context);
              onEditWard(ward, area);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa phường/xã',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDeleteWard(ward);
            },
          ),
        ],
      ),
    );
  }
}
