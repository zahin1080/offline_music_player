import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_browser/media_browser.dart';

class QueryArtworkWidget extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final double? artworkWidth;
  final double? artworkHeight;
  final BorderRadius? artworkBorder;
  final Widget? nullArtworkWidget;

  const QueryArtworkWidget({
    super.key,
    required this.id,
    required this.type,
    this.artworkWidth,
    this.artworkHeight,
    this.artworkBorder,
    this.nullArtworkWidget,
  });

  @override
  State<QueryArtworkWidget> createState() => _QueryArtworkWidgetState();
}

class _QueryArtworkWidgetState extends State<QueryArtworkWidget> {
  String? _imagePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }
  
  @override
  void didUpdateWidget(QueryArtworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.type != widget.type) {
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    setState(() { _isLoading = true; });
    try {
      final artwork = await MediaBrowser().queryArtwork(widget.id, widget.type, size: ArtworkSize.medium);
      if (artwork.isAvailable && artwork.filePath != null) {
        if (mounted) {
          setState(() {
            _imagePath = artwork.filePath;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() { _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isLoading) {
      child = SizedBox(
        width: widget.artworkWidth,
        height: widget.artworkHeight,
      );
    } else if (_imagePath != null && File(_imagePath!).existsSync()) {
      child = Image.file(
        File(_imagePath!),
        width: widget.artworkWidth,
        height: widget.artworkHeight,
        fit: BoxFit.cover,
      );
    } else {
      child = widget.nullArtworkWidget ?? const Icon(Icons.music_note);
    }

    if (widget.artworkBorder != null) {
      return ClipRRect(
        borderRadius: widget.artworkBorder!,
        child: Container(
          width: widget.artworkWidth,
          height: widget.artworkHeight,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: child,
        ),
      );
    }
    return child;
  }
}
