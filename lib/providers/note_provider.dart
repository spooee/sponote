import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NoteProvider extends ChangeNotifier {
  List<dynamic> notes = [];
  List<dynamic> folders = [];
  final ApiService apiService = ApiService();

  // Fetch folders
  Future<void> fetchFolders() async {
    folders = await apiService.getFolders();
    notifyListeners();
  }

  // Fetch notes
  Future<void> fetchNotes() async {
    notes = await apiService.getNotes();
    notifyListeners();
  }

  // Fetch notes in a specific folder
  Future<void> fetchNotesByFolder(int folderId) async {
    notes = await apiService.getNotesByFolder(folderId);
    notifyListeners(); // Ensure UI updates when notes are fetched
  }

  // Create a folder
  Future<void> createFolder(String name) async {
    await apiService.createFolder(name);
    fetchFolders();
  }

  // Rename a folder
  Future<void> renameFolder(int id, String newName) async {
    await apiService.renameFolder(id, newName);
    fetchFolders();
  }

  // Delete a folder
  Future<void> deleteFolder(int id) async {
    await apiService.deleteFolder(id);
    fetchFolders();
  }

  // Create a note
  Future<void> createNote(String title, String content, int folderId) async {
    await apiService.createNote(title, content, folderId);
    fetchNotesByFolder(folderId); // Refresh the list after adding a new note
  }

  // Update a note
  Future<void> updateNote(int id, String title, String content) async {
    await apiService.updateNote(id, title, content);
    fetchNotes(); // Refresh the notes after update
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    await apiService.deleteNote(id);
    fetchNotes();
  }

  // Move a note to a folder
  Future<void> moveNoteToFolder(int id, int newFolderId) async {
    await apiService.moveNoteToFolder(id, newFolderId);
    fetchNotes();
  }
}
