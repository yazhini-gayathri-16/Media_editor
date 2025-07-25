import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  // State variables
  AssetPathEntity? _selectedAlbum;
  List<AssetPathEntity> _albums = [];
  List<AssetEntity> _mediaList = [];
  final List<AssetEntity> _selectedMedia = [];

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  // Request permission and load albums
  Future<void> _loadMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      // Permission is granted
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image, // We only want images here
      );
      if (albums.isNotEmpty) {
        setState(() {
          _albums = albums;
          _selectedAlbum = _albums.first;
        });
        _loadAssets();
      }
    } else {
      // Permission is denied, handle it
      // You can show a dialog or a snackbar to the user
      PhotoManager.openSetting(); // Opens app settings for the user to manually grant permission
    }
  }

  // Load assets from the selected album
  Future<void> _loadAssets() async {
    if (_selectedAlbum == null) return;
    final List<AssetEntity> assets = await _selectedAlbum!.getAssetListRange(
      start: 0,
      end: await _selectedAlbum!.assetCountAsync,
    );
    setState(() {
      _mediaList = assets;
    });
  }

  void _onMediaTap(AssetEntity asset) {
    setState(() {
      if (_selectedMedia.contains(asset)) {
        // If it's already selected, deselect it
        _selectedMedia.remove(asset);
      } else {
        // If not selected, add it (up to the limit)
        if (_selectedMedia.length < 30) {
          _selectedMedia.add(asset);
        } else {
          // Optional: Show a message that the limit is reached
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can only select up to 30 items.')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Images (${_selectedMedia.length}/30)'),
        actions: [
          // "Done" button
          TextButton(
            onPressed: _selectedMedia.isEmpty ? null : () {
              // TODO: Navigate to the actual editing page with the selected media
              print('Selected ${_selectedMedia.length} Images.');
            },
            child: const Text('Done'),
          )
        ],
      ),
      body: Column(
        children: [
          // Album dropdown selector
          if (_albums.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<AssetPathEntity>(
                value: _selectedAlbum,
                onChanged: (AssetPathEntity? newValue) {
                  setState(() {
                    _selectedAlbum = newValue;
                  });
                  _loadAssets();
                },
                items: _albums.map<DropdownMenuItem<AssetPathEntity>>((album) {
                  return DropdownMenuItem<AssetPathEntity>(
                    value: album,
                    child: FutureBuilder<int>(
                      future: album.assetCountAsync,
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return Text('${album.name} ($count)');
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          
          // Media grid
          Expanded(
            child: _mediaList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: _mediaList.length,
                    itemBuilder: (context, index) {
                      final asset = _mediaList[index];
                      final isSelected = _selectedMedia.contains(asset);

                      return GestureDetector(
                        onTap: () => _onMediaTap(asset),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Thumbnail
                            AssetEntityImage(
                              asset,
                              isOriginal: false, // for faster loading
                              fit: BoxFit.cover,
                            ),
                            // Play icon for images
                            // Selection overlay
                            if (isSelected)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                child: const Icon(Icons.check_circle, color: Colors.blue),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}