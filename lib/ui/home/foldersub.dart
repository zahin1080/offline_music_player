import 'package:minimal_music_player/utils/top_toast.dart';
import 'package:minimal_music_player/services/library_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_browser/media_browser.dart';
import 'package:provider/provider.dart';

import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:minimal_music_player/widgets/query_artwork_widget.dart';

class FoldersSubView extends StatelessWidget {
  const FoldersSubView({super.key});

  void _showCreateFolderDialog(BuildContext context, ThemeData theme, MusicProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.create_new_folder_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                "Create New Folder",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Folder Name",
              hintStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final name = controller.text.trim();
                Navigator.pop(dialogContext);
                final error = await provider.createCustomFolder(name);
                if (context.mounted) {
                  TopToast.show(context, error ?? "Folder '$name' created!");
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final folders = provider.folders.entries.toList();
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90, top: 16),
      itemCount: folders.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () => _showCreateFolderDialog(context, theme, provider),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.create_new_folder_rounded, color: theme.colorScheme.primary, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      "Create New Folder",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final folder = folders[index - 1];
        final count = folder.value.length;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.folder_rounded, color: theme.colorScheme.primary),
            ),
            title: Text(
              folder.key,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "$count ${count == 1 ? 'audio file' : 'audio files'}",
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FolderDetailScreen(folderName: folder.key)),
            ),
          ),
        );
      },
    );
  }
}

/// Folder contents. Watches the provider so newly added songs appear live.
class FolderDetailScreen extends StatefulWidget {
  final String folderName;
  const FolderDetailScreen({super.key, required this.folderName});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  bool _isCopying = false;

  Future<void> _copyIntoFolder(MusicProvider provider, List<String> paths) async {
    if (paths.isEmpty) return;
    setState(() => _isCopying = true);
    final count = await provider.addFilesToFolder(widget.folderName, paths);
    if (!mounted) return;
    setState(() => _isCopying = false);
    TopToast.show(context, count > 0
              ? "Added $count ${count == 1 ? 'song' : 'songs'} to '${widget.folderName}'"
              : "No songs were added. Allow \"All files access\" if prompted.");
}

  Future<void> _pickFromDeviceStorage(MusicProvider provider) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.audio,
        dialogTitle: "Select songs",
      );
      final paths = files.map((f) => f.path).whereType<String>().toList();
      await _copyIntoFolder(provider, paths);
    } catch (e) {
      if (!mounted) return;
      TopToast.show(context, "Could not open storage: $e");
}
  }

  void _showAddSongsSheet(MusicProvider provider) {
    final theme = Theme.of(context);
    final List<int> selectedIds = [];
    final librarySongs = provider.songs
        .where((s) => !(provider.folders[widget.folderName] ?? []).any((f) => f.id == s.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Add Songs to '${widget.folderName}'",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Browse the whole device storage ---
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _pickFromDeviceStorage(provider);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sd_storage_rounded, color: theme.colorScheme.primary, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Browse Device Storage",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Pick audio files from any folder on your phone",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Or choose from your library",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: selectedIds.isEmpty
                            ? null
                            : () {
                                final paths = provider.songs
                                    .where((s) => selectedIds.contains(s.id))
                                    .map((s) => s.data)
                                    .toList();
                                Navigator.pop(sheetContext);
                                _copyIntoFolder(provider, paths);
                              },
                        child: Text("Add (${selectedIds.length})"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: librarySongs.isEmpty
                        ? Center(
                            child: Text(
                              "No other songs in your library",
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: librarySongs.length,
                            itemBuilder: (ctx, idx) {
                              final song = librarySongs[idx];
                              final isSelected = selectedIds.contains(song.id);
                              void toggle() => setSheetState(() {
                                    isSelected ? selectedIds.remove(song.id) : selectedIds.add(song.id);
                                  });
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary),
                                title: Text(provider.getSongTitle(song), maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(LibraryService.artistNameOf(song), maxLines: 1),
                                trailing: Checkbox(
                                  value: isSelected,
                                  activeColor: theme.colorScheme.primary,
                                  onChanged: (_) => toggle(),
                                ),
                                onTap: toggle,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final songs = provider.folders[widget.folderName] ?? [];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.folderName,
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.rescanLibrary(),
          ),
        ],
      ),
      body: Stack(
        children: [
          songs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "This folder is empty",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap \"Add Songs\" to copy music\nfrom your device storage.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: songs.length,
                  itemBuilder: (ctx, idx) {
                    final song = songs[idx];
                    final isPlaying = provider.currentSong?.id == song.id;
                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.audio,
                        artworkWidth: 48,
                        artworkHeight: 48,
                        artworkBorder: BorderRadius.circular(10),
                        nullArtworkWidget: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary),
                        ),
                      ),
                      title: Text(
                        provider.getSongTitle(song),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                          color: isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        LibraryService.artistNameOf(song),
                        style: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                      ),
                      onTap: () => provider.playSong(song, queue: songs),
                    );
                  },
                ),
          if (_isCopying)
            Container(
              color: Colors.black.withValues(alpha: 0.4),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    const Text("Copying songs...", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isCopying ? null : () => _showAddSongsSheet(provider),
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Songs"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }
}
