import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart'; // Required for AssetEntityImage

class VideoEditorScreen extends StatefulWidget {
  const VideoEditorScreen({super.key});

  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
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
        type: RequestType.video, // We only want videos here
      );
      if (albums.isNotEmpty) {
        setState(() {
          _albums = albums;
          _selectedAlbum = _albums.first;
        });
        _loadAssets();
      }
    } else {
      // Permission is denied, prompt user to open settings
      PhotoManager.openSetting();
    }
  }

  // Load assets from the selected album
  Future<void> _loadAssets() async {
    if (_selectedAlbum == null) return;
    final List<AssetEntity> assets = await _selectedAlbum!.getAssetListRange(
      start: 0,
      end: await _selectedAlbum!.assetCountAsync, // Use async count
    );
    setState(() {
      _mediaList = assets;
    });
  }

  void _onMediaTap(AssetEntity asset) {
    setState(() {
      if (_selectedMedia.contains(asset)) {
        _selectedMedia.remove(asset);
      } else {
        if (_selectedMedia.length < 30) {
          _selectedMedia.add(asset);
        } else {
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
        title: Text('Select Videos (${_selectedMedia.length}/30)'),
        actions: [
          TextButton(
            onPressed: _selectedMedia.isEmpty
                ? null
                : () {
                    // TODO: Navigate to the actual editing page with the selected media
                    print('Selected ${_selectedMedia.length} videos.');
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
                isExpanded: true,
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
                        return Text(
                          '${album.name} ($count)',
                          overflow: TextOverflow.ellipsis,
                        );
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
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.error));
                              },
                            ),
                            // Play icon for videos
                            if (asset.type == AssetType.video)
                              const Center(
                                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                              ),
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