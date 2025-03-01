import '../services/database_service.dart';

class Area {
  final String id;
  final String name;
  final List<Ward> wards;

  Area({required this.id, required this.name, required this.wards});
}

class Ward {
  final String id;
  final String name;
  final String areaId;
  final List<Place> places;

  Ward({
    required this.id,
    required this.name,
    required this.areaId,
    required this.places,
  });
}

class Place {
  final String id;
  final String name;
  final String wardId;
  final List<PlaceImage>
      images; // Changed from List<String> to List<PlaceImage>

  Place({
    required this.id,
    required this.name,
    required this.wardId,
    required this.images,
  });
}
