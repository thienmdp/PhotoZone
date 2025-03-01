import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_manager/screens/work/place_detail_screen.dart';
import '../../models/location.dart';
import '../../services/database_service.dart';
import 'components/work_header.dart';
import 'components/area_card.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Area> areas = [];
  String? selectedAreaId;
  String? selectedWardId;
  bool isLoading = true;
  List<dynamic> searchResults = [];
  bool isSearching = false;

  final List<Color> _areaColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
  ];

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas() async {
    setState(() => isLoading = true);
    try {
      final loadedAreas = await DatabaseService.instance.getAreas();
      setState(() {
        areas = loadedAreas;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Error loading areas: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
          child: Column(
            children: [
              WorkHeader(
                searchController: _searchController,
                onSearch: _handleSearch,
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isSearching
                        ? _buildSearchResults()
                        : areas.isEmpty
                            ? _buildEmptyState()
                            : _buildContent(), // Thay đổi ở đây
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      children: [
        _buildAddNewSection(), // Section thêm mới được đặt ở đầu ListView
        const SizedBox(height: 16), // Khoảng cách với phần content
        ...List.generate(
          areas.length,
          (index) {
            final area = areas[index];
            return AreaCard(
              area: area,
              areaColor: _areaColors[index % _areaColors.length],
              onAddWard: () {
                selectedAreaId = area.id;
                _showAddWardDialog();
              },
              onEditArea: (area) => _showEditAreaDialog(area),
              onDeleteArea: (area) => _showDeleteAreaConfirmation(area),
              onEditWard: (ward, area) => _showEditWardDialog(ward, area),
              onDeleteWard: (ward) => _showDeleteWardConfirmation(ward),
              onAddPlace: (ward) {
                selectedAreaId = ward.areaId;
                selectedWardId = ward.id;
                _showAddPlaceDialog();
              },
              onTapPlace: (place) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailScreen(place: place),
                ),
              ),
              onEditPlace: (place) => _showEditPlaceDialog(place),
              onDeletePlace: (place) => _showDeletePlaceConfirmation(place),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddNewSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: InkWell(
        onTap: _handleAddNew,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade200,
                Colors.orange.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_location_alt,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thêm địa điểm mới',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tạo khu vực, phường xã hoặc địa điểm',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blueGrey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.blueGrey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return const Center(
        child: Text('Không tìm thấy kết quả'),
      );
    }

    return ListView.builder(
      itemCount: searchResults.length,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      itemBuilder: (context, index) {
        final result = searchResults[index];
        IconData icon;
        String subtitle;
        VoidCallback? onTap;

        switch (result['type']) {
          case 'area':
            icon = Icons.location_city;
            subtitle = 'Khu vực';
            onTap = () {
              setState(() {
                selectedAreaId = result['id'];
                isSearching = false;
                _searchController.clear();
              });
            };
            break;
          case 'ward':
            icon = Icons.business;
            final area = areas.firstWhere(
              (a) => a.wards.any((w) => w.id == result['id']),
            );
            subtitle = 'Phường/Xã - ${area.name}';
            onTap = () {
              setState(() {
                selectedAreaId = area.id;
                selectedWardId = result['id'];
                isSearching = false;
                _searchController.clear();
              });
            };
            break;
          case 'place':
            icon = Icons.place;
            Ward? ward;
            Area? area;
            for (final a in areas) {
              for (final w in a.wards) {
                if (w.places.any((p) => p.id == result['id'])) {
                  ward = w;
                  area = a;
                  break;
                }
              }
              if (ward != null) break;
            }
            subtitle = 'Địa điểm - ${ward?.name} - ${area?.name}';
            final place = ward?.places.firstWhere((p) => p.id == result['id']);
            onTap = place != null
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailScreen(place: place),
                      ),
                    )
                : null;
            break;
          default:
            icon = Icons.error;
            subtitle = '';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(icon),
            title: Text(result['name']),
            subtitle: Text(subtitle),
            onTap: onTap,
          ),
        );
      },
    );
  }

  Future<void> _handleSearch(String query) async {
    setState(() => isSearching = query.isNotEmpty);

    if (query.isEmpty) {
      setState(() => searchResults.clear());
      return;
    }

    try {
      final results = await DatabaseService.instance.searchLocations(query);
      setState(() => searchResults = results);
    } catch (e) {
      _showError('Lỗi tìm kiếm: $e');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có khu vực nào',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showAddAreaDialog,
            icon: const Icon(Icons.add),
            label: const Text('Thêm khu vực'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTree() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      itemCount: areas.length,
      itemBuilder: (context, areaIndex) {
        final area = areas[areaIndex];
        return AreaCard(
          area: area,
          areaColor: _areaColors[areaIndex % _areaColors.length],
          onAddWard: () {
            selectedAreaId = area.id;
            _showAddWardDialog();
          },
          onEditArea: (area) => _showEditAreaDialog(area),
          onDeleteArea: (area) => _showDeleteAreaConfirmation(area),
          onEditWard: (ward, area) => _showEditWardDialog(ward, area),
          onDeleteWard: (ward) => _showDeleteWardConfirmation(ward),
          onAddPlace: (ward) {
            selectedAreaId = ward.areaId;
            selectedWardId = ward.id;
            _showAddPlaceDialog();
          },
          onTapPlace: (place) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaceDetailScreen(place: place),
            ),
          ),
          onEditPlace: (place) => _showEditPlaceDialog(place),
          onDeletePlace: (place) => _showDeletePlaceConfirmation(place),
        );
      },
    );
  }

  void _showAreaOptions(Area area) {
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
              _showEditAreaDialog(area);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title:
                const Text('Xóa khu vực', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteAreaConfirmation(area);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditAreaDialog(Area area) async {
    final nameController = TextEditingController(text: area.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa tên khu vực'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên khu vực'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != area.name) {
      try {
        await DatabaseService.instance.updateArea(area.id, result);
        await _loadAreas();
      } catch (e) {
        _showError('Lỗi cập nhật khu vực: $e');
      }
    }
  }

  Future<void> _showDeleteAreaConfirmation(Area area) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa khu vực "${area.name}"?\n'
            'Tất cả phường/xã và địa điểm trong khu vực này sẽ bị xóa.'),
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
        await DatabaseService.instance.deleteArea(area.id);
        await _loadAreas();
      } catch (e) {
        _showError('Lỗi xóa khu vực: $e');
      }
    }
  }

  void _showWardOptions(Ward ward, Area area) {
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
              _showEditWardDialog(ward, area);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa phường/xã',
                style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteWardConfirmation(ward);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditWardDialog(Ward ward, Area area) async {
    final nameController = TextEditingController(text: ward.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa tên phường/xã'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên phường/xã'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != ward.name) {
      try {
        await DatabaseService.instance.updateWard(ward.id, result);
        await _loadAreas();
      } catch (e) {
        _showError('Lỗi cập nhật phường/xã: $e');
      }
    }
  }

  Future<void> _showDeleteWardConfirmation(Ward ward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa phường/xã "${ward.name}"?\n'
            'Tất cả địa điểm trong phường/xã này sẽ bị xóa.'),
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
        await DatabaseService.instance.deleteWard(ward.id);
        await _loadAreas();
      } catch (e) {
        _showError('Lỗi xóa phường/xã: $e');
      }
    }
  }

  void _handleAddNew() {
    if (selectedWardId != null) {
      _showAddPlaceDialog();
    } else if (selectedAreaId != null) {
      _showAddWardDialog();
    } else {
      _showAddAreaDialog();
    }
  }

  Future<void> _showAddAreaDialog() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm khu vực mới'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên khu vực'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await DatabaseService.instance.createArea(result);
        await _loadAreas();
      } catch (e) {
        _showError('Error creating area: $e');
      }
    }
  }

  Future<void> _showAddWardDialog() async {
    final nameController = TextEditingController();
    final selectedArea = areas.firstWhere((a) => a.id == selectedAreaId);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm Phường/Xã cho ${selectedArea.name}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên Phường/Xã'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await DatabaseService.instance.createWard(result, selectedAreaId!);
        await _loadAreas();
      } catch (e) {
        _showError('Error creating ward: $e');
      }
    }
  }

  Future<void> _showAddPlaceDialog() async {
    final nameController = TextEditingController();
    final selectedArea = areas.firstWhere((a) => a.id == selectedAreaId);
    final selectedWard =
        selectedArea.wards.firstWhere((w) => w.id == selectedWardId);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm địa điểm cho ${selectedWard.name}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên địa điểm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await DatabaseService.instance.createPlace(result, selectedWardId!);
        await _loadAreas();
      } catch (e) {
        _showError('Error creating place: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _handleAddNew,
          backgroundColor: Colors.orange.withOpacity(0.4),
          elevation: 0, // Bỏ shadow mặc định
          shape: const CircleBorder(), // Đảm bảo hình tròn hoàn toàn
          child: const Icon(
            Icons.add,
            color: Colors.orange,
            size: 28, // Tăng kích thước icon
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceCard(Place place, Color areaColor) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(place: place),
          ),
        ),
        onLongPress: () => _showPlaceOptions(place),
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
                child: place.images.isEmpty
                    ? Container(
                        width: double.infinity,
                        alignment: Alignment.center, // Canh giữa icon
                        child: Icon(
                          Icons.place,
                          size: 50,
                          color: areaColor.withOpacity(0.8),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Image.file(
                          File(place.images.first.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${place.images.length} ảnh',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceOptions(Place place) {
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
              _showEditPlaceDialog(place);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title:
                const Text('Xóa địa điểm', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeletePlaceConfirmation(place);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPlaceDialog(Place place) async {
    final nameController = TextEditingController(text: place.name);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa tên địa điểm'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Tên địa điểm'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != place.name) {
      try {
        await DatabaseService.instance.updatePlace(place.id, result);
        await _loadAreas();
      } catch (e) {
        _showError('Lỗi cập nhật địa điểm: $e');
      }
    }
  }

  Future<void> _showDeletePlaceConfirmation(Place place) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa địa điểm "${place.name}"?\n'
            'Tất cả hình ảnh của địa điểm này sẽ bị xóa.'),
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
        await DatabaseService.instance.deletePlace(place.id);
        await _loadAreas();
      } catch (e) {
        _showError('Lỗi xóa địa điểm: $e');
      }
    }
  }
}
