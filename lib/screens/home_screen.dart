import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../models/category.dart';
import '../models/metadata.dart';
import '../services/xtream_service.dart';
import '../services/tmdb_service.dart';
import '../widgets/channel_card.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import '../widgets/connection_test_widget.dart';
import 'player_screen.dart';

/// Home screen showing list of channels and categories
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Channel> _channels = [];
  List<Category> _categories = [];
  Map<String, Metadata> _metadataCache = {};
  String? _selectedCategoryId;
  bool _isLoading = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load categories and channels in parallel
      final results = await Future.wait([
        XtreamService.getCategories(),
        XtreamService.getChannels(),
      ]);

      final categories = results[0] as List<Category>;
      final channels = results[1] as List<Channel>;

      setState(() {
        _categories = categories;
        _channels = channels;
      });

      // Load metadata for first few channels
      _loadMetadata(channels.take(10).toList());
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Error al cargar canales: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMetadata(List<Channel> channels) async {
    for (final channel in channels) {
      if (_metadataCache.containsKey(channel.id)) continue;

      try {
        final title = AppHelpers.extractTitle(channel.name);
        final metadata = await TMDBService.searchByTitle(title);
        
        if (metadata != null && mounted) {
          setState(() {
            _metadataCache[channel.id] = metadata;
          });
        }
      } catch (e) {
        // Silently fail for metadata - it's not critical
        continue;
      }
    }
  }

  Future<void> _loadChannelsForCategory(String? categoryId) async {
    setState(() {
      _isLoading = true;
      _selectedCategoryId = categoryId;
    });

    try {
      final channels = await XtreamService.getChannels(categoryId);
      setState(() {
        _channels = channels;
      });

      // Load metadata for new channels
      _loadMetadata(channels.take(10).toList());
    } catch (e) {
      if (mounted) {
        AppHelpers.showError(context, 'Error al cargar canales: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Channel> get _filteredChannels {
    if (_searchQuery.isEmpty) return _channels;
    
    return _channels.where((channel) {
      final name = AppHelpers.cleanChannelName(channel.name);
      final query = AppHelpers.cleanChannelName(_searchQuery);
      return name.contains(query);
    }).toList();
  }

  void _onChannelTap(Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          channel: channel,
          metadata: _metadataCache[channel.id],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConnectionTestWidget(),
                ),
              );
            },
            tooltip: 'Test de conexión',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar canales...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Categories dropdown
          if (_categories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              child: DropdownButtonFormField<String?>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                  ),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos los canales'),
                  ),
                  ..._categories.map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      )),
                ],
                onChanged: _loadChannelsForCategory,
              ),
            ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Channels list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredChannels.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron canales',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          itemCount: _filteredChannels.length,
                          itemBuilder: (context, index) {
                            final channel = _filteredChannels[index];
                            return ChannelCard(
                              channel: channel,
                              metadata: _metadataCache[channel.id],
                              onTap: () => _onChannelTap(channel),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}