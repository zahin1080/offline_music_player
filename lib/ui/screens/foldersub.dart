import 'dart:io';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:minimal_music_player/providers/playlist_provider.dart';

class FoldersSubView extends StatelessWidget {
  const FoldersSubView({super.key});

  void _showAddSongsSheet(BuildContext context, ThemeData theme, MusicProvider provider, String folderName) {
    List<dynamic> selectedIds = [];
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Add Songs to '$folderName'", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedIds.isEmpty) return;
                          
                          // Copy files
                          int count = 0;
                          for (var id in selectedIds) {
                            final song = provider.songs.firstWhere((s) => s.id == id);
                            if (song.data.isNotEmpty) {
                              try {
                                final sourceFile = File(song.data);
                                final fileName = sourceFile.path.split(Platform.pathSeparator).last;
                                final targetFile = File('/storage/emulated/0/Download/$folderName/$fileName');
                                if (!targetFile.existsSync()) {
                                  sourceFile.copySync(targetFile.path);
                                  count++;
                                }
                              } catch (e) {
                                debugPrint("Copy error: $e");
                              }
                            }
                          }
                          
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Copied $count songs into folder!"),
                            backgroundColor: theme.colorScheme.primary,
                          ));
                          provider.requestPermissionAndFetch(); // Refresh MediaStore
                        },
                        child: Text("Save (${selectedIds.length})"),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.songs.length,
                      itemBuilder: (ctx, idx) {
                        final song = provider.songs[idx];
                        final isSelected = selectedIds.contains(song.id);
                        return ListTile(
                          leading: Icon(Icons.music_note, color: theme.colorScheme.primary),
                          title: Text(provider.getSongTitle(song), maxLines: 1),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  selectedIds.add(song.id);
                                } else {
                                  selectedIds.remove(song.id);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedIds.remove(song.id);
                              } else {
                                selectedIds.add(song.id);
                              }
                            });
                          },
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

  void _showCreateFolderDialog(BuildContext context, ThemeData theme, MusicProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.create_new_folder_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text("Create New Folder", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
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
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  try {
                    // Try to create in the standard Music directory
                    final dir = Directory('/storage/emulated/0/Music/$name');
                    if (!dir.existsSync()) {
                      dir.createSync(recursive: true);
                      provider.addCustomFolder(name);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Folder '$name' created!"),
                        backgroundColor: theme.colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Folder already exists.")));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not create folder: $e")));
                  }
                }
                Navigator.pop(context);
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
      itemCount: folders.length + 1, // +1 for the Create Folder button
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
                    style: BorderStyle.solid,
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
            title: Text(folder.key, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${folder.value.length} audio files", style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    backgroundColor: theme.colorScheme.surface,
                    appBar: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(folder.key, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      iconTheme: IconThemeData(color: theme.colorScheme.primary),
                    ),
                    body: folder.value.isEmpty 
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                                const SizedBox(height: 16),
                                Text(
                                  "This folder is empty",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Audio files placed in this directory\nwill appear here.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: folder.value.length,
                            itemBuilder: (ctx, idx) {
                              final song = folder.value[idx];
                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary),
                                ),
                                title: Text(provider.getSongTitle(song), maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  (song.artist == null || song.artist == '<unknown>') ? "Unknown Artist" : song.artist!,
                                  style: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                                ),
                                onTap: () => provider.playSong(song, queue: folder.value),
                              );
                            },
                          ),
                    floatingActionButton: FloatingActionButton.extended(
                      onPressed: () {
                        // Show bottom sheet to pick songs
                        _showAddSongsSheet(context, theme, provider, folder.key);
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text("Add Songs"),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
