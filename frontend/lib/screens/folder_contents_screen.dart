import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;

class FolderContentsScreen extends StatefulWidget {
  final String userId;
  final String folderId;
  final String folderName;

  const FolderContentsScreen({
    super.key,
    required this.userId,
    required this.folderId,
    required this.folderName,
  });

  @override
  State<FolderContentsScreen> createState() => _FolderContentsScreenState();
}

class _FolderContentsScreenState extends State<FolderContentsScreen> {
  List<dynamic> files = [];
  List<dynamic> folders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContents();
  }

  // Load files and folders
  Future<void> loadContents() async {
    setState(() => isLoading = true);

    // Load folders
    final folderRes = await ApiService.getFolders(
      widget.userId,
      parentFolderId: widget.folderId,
    );
    if (folderRes['success'] == true) {
      setState(() => folders = folderRes['folders'] ?? []);
    }

    // Load files
    final fileRes = await ApiService.getFiles(widget.folderId);
    if (fileRes['success'] == true) {
      setState(() {
        files = fileRes['files'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // Show file preview dialog
  void showFilePreviewDialog(Map<String, dynamic> file) {
    final fileUrl = file['fileUrl'] ?? '';
    final fileName = file['name'] ?? '';
    final fileId = file['_id'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fileName),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Column(
            children: [
              // File preview
              Expanded(
                child: Container(
                  color: Colors.grey[200],
                  child: Image.network(
                    'http://localhost:5000$fileUrl',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Cannot preview this file type',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // File info
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'File: $fileName',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (fileUrl.isNotEmpty) {
                await downloadFile(fileUrl, fileName);
              }
            },
            child: const Text("Download"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showRenameDialog(fileId, fileName);
            },
            child: const Text("Rename"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteFileConfirm(fileId, fileName);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // Show rename dialog
  void showRenameDialog(String fileId, String currentName) {
    TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename File"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new filename"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;

              final res = await ApiService.renameFile(fileId, controller.text);

              if (res['success'] == true) {
                await loadContents();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("File renamed successfully")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${res['message'] ?? 'Unknown'}'),
                  ),
                );
              }
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  // Download file
  Future<void> downloadFile(String fileUrl, String fileName) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Downloading file...")));

      final res = await ApiService.downloadFile(fileUrl, fileName);

      if (res['success'] == true) {
        if (kIsWeb) {
          // Web: trigger browser download
          final bytes = res['bytes'] as List<int>;
          final blob = html.Blob([bytes]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = fileName;
          html.document.body!.children.add(anchor);
          anchor.click();
          html.document.body!.children.remove(anchor);
          html.Url.revokeObjectUrl(url);

          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("File downloaded!")));
        } else {
          // Mobile: file saved to downloads
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'File downloaded')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${res['message'] ?? 'Unknown error'}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Confirm delete file
  void deleteFileConfirm(String fileId, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete File"),
        content: Text("Are you sure you want to delete '$fileName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final res = await ApiService.deleteFile(fileId);

              if (res['success'] == true) {
                await loadContents();
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("File deleted")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${res['message'] ?? 'Unknown'}'),
                  ),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showCreateFolderDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Subfolder"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter folder name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;

              final res = await ApiService.createFolder(
                controller.text,
                widget.userId,
                parentFolderId: widget.folderId,
              );

              if (res['success'] == true) {
                await loadContents();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${res['message'] ?? 'Unknown error'}',
                    ),
                  ),
                );
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  // Upload file from device or browser
  Future<void> uploadFileFromDevice() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final fileName = result.files.single.name;
        final fileBytes = result.files.single.bytes;

        // Only access path on non-web platforms
        final filePath = kIsWeb ? null : result.files.single.path;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Uploading file...")));

        // Use bytes for web, path for mobile/desktop
        final uploadData = fileBytes ?? filePath;

        final res = await ApiService.uploadFile(
          uploadData,
          widget.folderId,
          fileName,
        );

        if (res['success'] == true) {
          await loadContents();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File uploaded successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${res['message'] ?? 'Unknown error'}'),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.folderName),
        backgroundColor: const Color.fromARGB(255, 8, 36, 63),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (folders.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Subfolders",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: folders.length,
                          itemBuilder: (context, index) {
                            final folder = folders[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.folder),
                                title: Text(folder['name']),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FolderContentsScreen(
                                        userId: widget.userId,
                                        folderId: folder['_id'],
                                        folderName: folder['name'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  if (files.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Files",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final file = files[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.description),
                                title: Text(file['name']),
                                onTap: () {
                                  showFilePreviewDialog(file);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  if (files.isEmpty && folders.isEmpty)
                    Expanded(
                      child: Center(
                        child: Text(
                          "No files or folders yet 📁",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 8, 36, 63),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: const Text("Create Subfolder"),
                    onTap: () {
                      Navigator.pop(context);
                      showCreateFolderDialog();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text("Upload File"),
                    onTap: () {
                      Navigator.pop(context);
                      uploadFileFromDevice();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
