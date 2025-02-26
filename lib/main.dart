import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/note_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setSize(Size(1200, 800));
    await windowManager.setResizable(false);
    await windowManager.setMaximizable(false);
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => NoteProvider()..fetchFolders(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
        primaryColor: Color(0xFF2C2C2C),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2A2A2A),
          elevation: 3,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardColor: Color(0xFF2C2C2C),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF404040),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF333333),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.white54),
        ),
        dialogTheme: DialogThemeData(backgroundColor: Color(0xFF252525)),
      ),
      home: NotesHomeScreen(),
    );
  }
}

class NotesHomeScreen extends StatefulWidget {
  const NotesHomeScreen({super.key});

  @override
  _NotesHomeScreenState createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  int? selectedFolderId;

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          // Custom Title Bar
          GestureDetector(
            onPanStart: (_) async {
              await windowManager.startDragging();
            },
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.transparent),
              child: Row(
                children: [
                  Text(
                    "SpoNote",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Spacer(),

                  // Minimize Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: IconButton(
                      icon: Icon(Icons.minimize, color: Colors.white),
                      splashRadius: 18,
                      onPressed: () async {
                        await windowManager.minimize();
                      },
                    ),
                  ),

                  // Close Button
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      splashRadius: 18,
                      onPressed: () async {
                        await windowManager.close();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Row(
              children: [
                // Sidebar for Folders
                Container(
                  width: 350,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AppBar(
                        title: Text("Folders"),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        actions: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed:
                                () =>
                                    _createFolderDialog(context, noteProvider),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: noteProvider.folders.length,
                          itemBuilder: (context, index) {
                            var folder = noteProvider.folders[index];
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFF333333),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                title: Text(
                                  folder['name'],
                                  style: TextStyle(color: Colors.white),
                                ),
                                leading: Icon(
                                  Icons.folder,
                                  color: Colors.orangeAccent,
                                ),
                                selected: selectedFolderId == folder['id'],
                                onTap: () {
                                  setState(() {
                                    selectedFolderId = folder['id'];
                                  });
                                  noteProvider.fetchNotesByFolder(
                                    selectedFolderId!,
                                  );
                                },
                                trailing: SizedBox(
                                  width: 80,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blueAccent,
                                        ),
                                        onPressed:
                                            () => _editFolderDialog(
                                              context,
                                              noteProvider,
                                              folder,
                                            ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed:
                                            () => _confirmDeleteFolderDialog(
                                              context,
                                              noteProvider,
                                              folder['id'],
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content for Notes
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      AppBar(
                        title: Text("Notes"),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        actions: [
                          if (selectedFolderId != null)
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed:
                                  () => _createNoteDialog(
                                    context,
                                    noteProvider,
                                    selectedFolderId,
                                  ),
                            ),
                        ],
                      ),
                      Expanded(
                        child: Consumer<NoteProvider>(
                          builder: (context, noteProvider, child) {
                            return selectedFolderId == null
                                ? Center(
                                  child: Text(
                                    "Select a folder to view notes",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                )
                                : noteProvider.notes.isEmpty
                                ? Center(
                                  child: Text(
                                    "No notes in this folder",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: noteProvider.notes.length,
                                  itemBuilder: (context, index) {
                                    var note = noteProvider.notes[index];
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF333333),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black38,
                                            blurRadius: 5,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          note['title'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          note['content'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white60,
                                          ),
                                        ),
                                        onTap:
                                            () =>
                                                _readNoteDialog(context, note),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                color: Colors.blueAccent,
                                              ),
                                              onPressed:
                                                  () => _editNoteDialog(
                                                    context,
                                                    noteProvider,
                                                    note,
                                                  ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.redAccent,
                                              ),
                                              onPressed:
                                                  () =>
                                                      _confirmDeleteNoteDialog(
                                                        context,
                                                        noteProvider,
                                                        note['id'],
                                                      ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Confirmation Dialog for Deleting a Folder
  void _confirmDeleteFolderDialog(
    BuildContext context,
    NoteProvider noteProvider,
    int folderId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete Folder"),
            content: Text("Are you sure you want to delete this folder?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Delete"),
                onPressed: () {
                  noteProvider.deleteFolder(folderId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  // Confirmation Dialog for Deleting a Note
  void _confirmDeleteNoteDialog(
    BuildContext context,
    NoteProvider noteProvider,
    int noteId,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete Note"),
            content: Text("Are you sure you want to delete this note?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Delete"),
                onPressed: () {
                  noteProvider.deleteNote(noteId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }
}

// Dialog for Reading a Note
void _readNoteDialog(BuildContext context, Map<String, dynamic> note) {
  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Color(0xFF252525), // Dark gray dialog
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  note['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                SelectableText(
                  note['content'],
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 20),
                SizedBox(height: 10), // Add some space above the Close button
                TextButton(
                  child: Text("Close", style: TextStyle(color: Colors.white70)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
  );
}

// Create Folder Dialog
void _createFolderDialog(BuildContext context, NoteProvider noteProvider) {
  TextEditingController nameController = TextEditingController();

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("Create Folder"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: "Folder Name"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Create"),
              onPressed: () {
                noteProvider.createFolder(nameController.text);
                Navigator.pop(context);
              },
            ),
          ],
        ),
  );
}

// Create Note Dialog
void _createNoteDialog(
  BuildContext context,
  NoteProvider noteProvider,
  int? selectedFolderId,
) {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text("Create Note"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: "Content"),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text("Create"),
              onPressed: () {
                if (selectedFolderId != null) {
                  noteProvider.createNote(
                    titleController.text,
                    contentController.text,
                    selectedFolderId, // Pass the correct folder ID
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please select a folder first")),
                  );
                }
              },
            ),
          ],
        ),
  );
}

// Dialog for Editing a Note
void _editNoteDialog(
  BuildContext context,
  NoteProvider noteProvider,
  Map<String, dynamic> note,
) {
  TextEditingController titleController = TextEditingController(
    text: note['title'],
  );
  TextEditingController contentController = TextEditingController(
    text: note['content'],
  );

  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Color(0xFF252525), // Dark gray dialog
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Note",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: "Title"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: "Content"),
                  maxLines: 4,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white70),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF404040),
                      ),
                      onPressed: () {
                        noteProvider.updateNote(
                          note['id'],
                          titleController.text,
                          contentController.text,
                        );
                        Navigator.pop(context);
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}

// Dialog for Editing a Folder
void _editFolderDialog(
  BuildContext context,
  NoteProvider noteProvider,
  Map<String, dynamic> folder,
) {
  TextEditingController nameController = TextEditingController(
    text: folder['name'],
  );

  showDialog(
    context: context,
    builder:
        (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Color(0xFF252525), // Dark gray dialog
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit Folder",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Folder Name"),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white70),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF404040),
                      ),
                      onPressed: () {
                        noteProvider.renameFolder(
                          folder['id'],
                          nameController.text,
                        );
                        Navigator.pop(context);
                      },
                      child: Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}
