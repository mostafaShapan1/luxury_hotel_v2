import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../providers/room_provider.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 1000);
  List<String> _selectedAmenities = [];
  int _selectedCapacity = 1;
  String? _selectedType;
  List<Room> _filteredRooms = [];

  final List<String> _amenities = [
    'WiFi',
    'Mini Bar',
    'TV',
    'Air Conditioning',
    'Balcony',
    'City View',
    'Room Service',
    'Spa Bath',
    'Work Desk',
  ];

  final List<String> _roomTypes = [
    'Standard',
    'Deluxe',
    'Suite',
    'Executive',
    'Presidential',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize rooms from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roomProvider = Provider.of<RoomProvider>(context, listen: false);
      _updateFilteredRooms(roomProvider.rooms);
    });
  }

  void _updateFilteredRooms(List<Room> allRooms) {
    setState(() {
      _filteredRooms = allRooms.where((room) {
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = room.name.toLowerCase().contains(searchQuery) ||
            room.description.toLowerCase().contains(searchQuery) ||
            room.type.toLowerCase().contains(searchQuery);

        final matchesPrice =
            room.price >= _priceRange.start && room.price <= _priceRange.end;

        final matchesAmenities = _selectedAmenities.isEmpty ||
            _selectedAmenities
                .every((amenity) => room.amenities.contains(amenity));

        final matchesCapacity = room.capacity >= _selectedCapacity;

        final matchesType = _selectedType == null ||
            room.type.toLowerCase() == _selectedType!.toLowerCase();

        return matchesSearch &&
            matchesPrice &&
            matchesAmenities &&
            matchesCapacity &&
            matchesType;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = Provider.of<RoomProvider>(context);
    final allRooms = roomProvider.rooms;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Rooms'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search rooms...',
                prefixIcon:
                    const Icon(Icons.search, color: AppTheme.primaryGold),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list,
                      color: AppTheme.primaryGold),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryGold),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryGold, width: 2),
                ),
              ),
              onChanged: (value) => _updateFilteredRooms(allRooms),
            ),
          ),
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_filteredRooms.isEmpty) {
      return const Center(
        child: Text(
          'No rooms found matching your criteria',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRooms.length,
      itemBuilder: (context, index) {
        final room = _filteredRooms[index];
        return _buildRoomCard(room);
      },
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/room-details',
            arguments: room,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                room.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${room.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.amenities
                        .take(3)
                        .map((amenity) => Chip(
                              label: Text(
                                amenity,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor:
                                  AppTheme.primaryGold.withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            room.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' (${room.reviews})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/booking',
                            arguments: room,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Book Now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _priceRange = const RangeValues(0, 1000);
                                _selectedAmenities = [];
                                _selectedCapacity = 1;
                                _selectedType = null;
                              });
                              _updateFilteredRooms(
                                Provider.of<RoomProvider>(context,
                                        listen: false)
                                    .rooms,
                              );
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        labels: RangeLabels(
                          '\$${_priceRange.start.round()}',
                          '\$${_priceRange.end.round()}',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                          _updateFilteredRooms(
                            Provider.of<RoomProvider>(context, listen: false)
                                .rooms,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Room Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _roomTypes.map((type) {
                          final isSelected = _selectedType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedType = selected ? type : null;
                              });
                              _updateFilteredRooms(
                                Provider.of<RoomProvider>(context,
                                        listen: false)
                                    .rooms,
                              );
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Capacity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_selectedCapacity > 1) {
                                setState(() {
                                  _selectedCapacity--;
                                });
                                _updateFilteredRooms(
                                  Provider.of<RoomProvider>(context,
                                          listen: false)
                                      .rooms,
                                );
                              }
                            },
                            icon: const Icon(Icons.remove_circle),
                          ),
                          Text(
                            _selectedCapacity.toString(),
                            style: const TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedCapacity++;
                              });
                              _updateFilteredRooms(
                                Provider.of<RoomProvider>(context,
                                        listen: false)
                                    .rooms,
                              );
                            },
                            icon: const Icon(Icons.add_circle),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Amenities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _amenities.map((amenity) {
                          final isSelected =
                              _selectedAmenities.contains(amenity);
                          return FilterChip(
                            label: Text(amenity),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenities.add(amenity);
                                } else {
                                  _selectedAmenities.remove(amenity);
                                }
                              });
                              _updateFilteredRooms(
                                Provider.of<RoomProvider>(context,
                                        listen: false)
                                    .rooms,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
