import 'dart:convert'; // For handling JSON
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  // Folder endpoints

  // Fetch all folders
  Future<List<dynamic>> getFolders() async {
    final response = await http.get(Uri.parse('$baseUrl/folders'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load folders');
    }
  }

  // Fetch a single folder by ID
  Future<Map<String, dynamic>> getFolderById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/folders/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Folder not found');
    }
  }

  // Create a new folder
  Future<int> createFolder(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/folders'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Returns new folder ID
    } else {
      throw Exception('Failed to create folder');
    }
  }

  // Rename a folder
  Future<void> renameFolder(int id, String newName) async {
    final response = await http.put(
      Uri.parse('$baseUrl/folders/$id/rename'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": newName}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to rename folder');
    }
  }

  // Delete a folder
  Future<void> deleteFolder(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/folders/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete folder');
    }
  }

  // Notes Endpoints

  // Fetch all notes
  Future<List<dynamic>> getNotes() async {
    final response = await http.get(Uri.parse('$baseUrl/notes'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notes');
    }
  }

  // Fetch notes in a folder
  Future<List<dynamic>> getNotesByFolder(int folderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notes/folder/$folderId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load notes in folder');
    }
  }

  // Fetch a single note
  Future<Map<String, dynamic>> getNoteById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/notes/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Note not found');
    }
  }

  // Create a new note
  Future<void> createNote(String title, String content, int folderId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notes'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "title": title,
        "content": content,
        "folderId": folderId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create note');
    }
  }

  // Update a note
  Future<void> updateNote(int id, String title, String content) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notes/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"title": title, "content": content}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update note');
    }
  }

  // Delete a note
  Future<void> deleteNote(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/notes/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete note');
    }
  }

  // Move a note to another folder
  Future<void> moveNoteToFolder(int id, int newFolderId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notes/$id/move'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"newFolderId": newFolderId}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to move note');
    }
  }
}
