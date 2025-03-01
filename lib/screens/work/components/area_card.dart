import 'package:flutter/material.dart';
import '../../../models/location.dart';
import 'ward_tile.dart';

class AreaCard extends StatelessWidget {
  final Area area;
  final Color areaColor;
  final VoidCallback onAddWard;
  final Function(Area) onEditArea;
  final Function(Area) onDeleteArea;
  final Function(Ward, Area) onEditWard;
  final Function(Ward) onDeleteWard;
  final Function(Ward) onAddPlace;
  final Function(Place) onTapPlace;
  final Function(Place) onEditPlace;
  final Function(Place) onDeletePlace;

  const AreaCard({
    super.key,
    required this.area,
    required this.areaColor,
    required this.onAddWard,
    required this.onEditArea,
    required this.onDeleteArea,
    required this.onEditWard,
    required this.onDeleteWard,
    required this.onAddPlace,
    required this.onTapPlace,
    required this.onEditPlace,
    required this.onDeletePlace,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: areaColor.withOpacity(0.2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          collapsedShape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: areaColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_city, color: Colors.blueGrey[800]),
          ),
          title: GestureDetector(
            onLongPress: () => _showOptions(context),
            child: Text(
              area.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          subtitle: Text(
            '${area.wards.length} phường/xã',
            style: TextStyle(color: Colors.grey[600]),
          ),
          children: _buildChildren(context),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    return [
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: area.wards.length,
        itemBuilder: (context, index) {
          return WardTile(
            ward: area.wards[index],
            area: area,
            areaColor: areaColor,
            onEditWard: onEditWard,
            onDeleteWard: onDeleteWard,
            onAddPlace: onAddPlace,
            onTapPlace: onTapPlace,
            onEditPlace: onEditPlace,
            onDeletePlace: onDeletePlace,
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.all(12),
        child: OutlinedButton.icon(
          onPressed: onAddWard,
          icon: const Icon(Icons.add),
          label: const Text('Thêm Phường/Xã'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    ];
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Sửa tên khu vực'),
            onTap: () {
              Navigator.pop(context);
              onEditArea(area);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title:
                const Text('Xóa khu vực', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDeleteArea(area);
            },
          ),
        ],
      ),
    );
  }
}
