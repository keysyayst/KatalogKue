import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  final double initialLat;
  final double initialLng;

  const MapPickerPage({
    Key? key,
    this.initialLat = -7.959770,
    this.initialLng = 112.636911,
  }) : super(key: key);

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late MapController mapController;
  late LatLng selectedLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    selectedLocation = LatLng(widget.initialLat, widget.initialLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Lokasi')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final position = await Geolocator.getCurrentPosition();
                        setState(() {
                          selectedLocation = LatLng(
                            position.latitude,
                            position.longitude,
                          );
                        });
                        mapController.move(selectedLocation, 15);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Lokasi Saya'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, selectedLocation);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Pilih'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFE8C00),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
