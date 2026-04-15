import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'folder_contents_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String email;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.email,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List folders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFolders();
  }

  // Load folders from database
  Future<void> loadFolders() async {
    setState(() => isLoading = true);
    final res = await ApiService.getFolders(widget.userId);

    if (res['success'] == true) {
      setState(() {
        folders = res['folders'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // Logout function
  void logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.clearAll();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 🟢 Create Folder Dialog
  void showCreateFolderDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Folder"),
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
              );

              if (res['success'] == true) {
                await loadFolders(); // Refresh folders list
                Navigator.pop(context);
              } else {
                // Show error message
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color.fromARGB(255, 8, 36, 63),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: "Logout",
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 8, 36, 63),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome 👋",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.email,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Your Folders",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : folders.isEmpty
                  ? Center(
                      child: Text(
                        "No folders yet 📁",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
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
            ),
          ],
        ),
      ),

      // ➕ Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 8, 36, 63),
        onPressed: showCreateFolderDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
