import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/channel.dart';
import '../models/metadata.dart';
import '../utils/constants.dart';

/// Screen for playing IPTV streams
class PlayerScreen extends StatefulWidget {

  const PlayerScreen({
    super.key,
    required this.channel,
    this.metadata,
  });
  final Channel channel;
  final Metadata? metadata;

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _initializePlayer();
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.channel.streamUrl),
      );

      await _controller!.initialize();

      _controller!.addListener(_videoListener);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _controller!.play();
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error al cargar el stream: $e';
        });
      }
    }
  }

  void _videoListener() {
    if (_controller?.value.hasError == true) {
      setState(() {
        _hasError = true;
        _errorMessage = _controller?.value.errorDescription ?? 'Error desconocido';
      });
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  void _seekRelative(Duration offset) {
    if (_controller == null) return;

    final currentPosition = _controller!.value.position;
    final newPosition = currentPosition + offset;
    final duration = _controller!.value.duration;

    if (newPosition >= Duration.zero && newPosition <= duration) {
      _controller!.seekTo(newPosition);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(
          widget.channel.name,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Video player section
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _buildVideoPlayer(),
            ),
          ),

          // Information section
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: _buildInfoSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Cargando stream...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? AppConstants.playbackError,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializePlayer,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_controller?.value.isInitialized != true) {
      return const Center(
        child: Text(
          'Error al inicializar el reproductor',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
          
          if (_showControls) _buildVideoControls(),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    if (_controller == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.channel.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center play/pause button
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _seekRelative(-AppConstants.seekDuration),
                  icon: const Icon(Icons.replay_10),
                  color: Colors.white,
                  iconSize: 32,
                ),
                IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  color: Colors.white,
                  iconSize: 48,
                ),
                IconButton(
                  onPressed: () => _seekRelative(AppConstants.seekDuration),
                  icon: const Icon(Icons.forward_10),
                  color: Colors.white,
                  iconSize: 32,
                ),
              ],
            ),
          ),

          // Bottom progress bar
          Container(
            padding: const EdgeInsets.all(16),
            child: VideoProgressIndicator(
              _controller!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                bufferedColor: Colors.grey,
                backgroundColor: Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel info header
          Row(
            children: [
              // Channel/program image
              if (widget.metadata?.fullPosterUrl != null ||
                  widget.channel.logo != null)
                Container(
                  width: 80,
                  height: 120,
                  margin: const EdgeInsets.only(right: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: widget.metadata?.fullPosterUrl ??
                          widget.channel.logo!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.tv, color: Colors.white54),
                      ),
                    ),
                  ),
                ),

              // Channel details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.channel.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    if (widget.metadata?.title != null &&
                        widget.metadata!.title != widget.channel.name) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Programa actual: ${widget.metadata!.title}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],

                    if (widget.metadata?.voteAverage != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.metadata!.voteAverage!.toStringAsFixed(1)}/10',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Program description
          if (widget.metadata?.overview != null) ...[
            const SizedBox(height: 24),
            Text(
              'Sinopsis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.metadata!.overview!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],

          // Additional info
          if (widget.metadata?.genres?.isNotEmpty == true ||
              widget.metadata?.releaseDate != null) ...[
            const SizedBox(height: 24),
            Text(
              'Información adicional',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            if (widget.metadata?.releaseDate != null) ...[
              Text(
                'Fecha de estreno: ${widget.metadata!.releaseDate}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
            ],
            
            if (widget.metadata?.genres?.isNotEmpty == true) ...[
              Text(
                'Géneros: ${widget.metadata!.genres!.join(", ")}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ],
      ),
    );
  }
}