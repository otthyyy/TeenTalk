import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import '../utils/error_handler.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  // Upload file from path
  Future<String> uploadFile(String filePath, String storagePath) async {
    try {
      File file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      Reference ref = _storage.ref().child(storagePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      _logger.d('File uploaded successfully: $storagePath');
      return downloadUrl;
    } catch (e) {
      _logger.e('Failed to upload file $filePath to $storagePath: $e');
      throw ErrorHandler.handleStorageError(e);
    }
  }

  // Upload file from bytes
  Future<String> uploadBytes(
    List<int> bytes,
    String storagePath, {
    String? contentType,
  }) async {
    try {
      Reference ref = _storage.ref().child(storagePath);
      UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: contentType),
      );
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      _logger.d('Bytes uploaded successfully: $storagePath');
      return downloadUrl;
    } catch (e) {
      _logger.e('Failed to upload bytes to $storagePath: $e');
      throw ErrorHandler.handleStorageError(e);
    }
  }

  // Download file to local path
  Future<File> downloadFile(String storagePath, String localPath) async {
    try {
      Reference ref = _storage.ref().child(storagePath);
      File file = File(localPath);
      
      await ref.writeToFile(file);
      
      _logger.d('File downloaded successfully: $storagePath -> $localPath');
      return file;
    } catch (e) {
      _logger.e('Failed to download file $storagePath: $e');
      throw ErrorHandler.handleStorageError(e);
    }
  }

  // Get download URL
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      Reference ref = _storage.ref().child(storagePath);
      String downloadUrl = await ref.getDownloadURL();
      
      _logger.d('Got download URL for: $storagePath');
      return downloadUrl;
    } catch (e) {
      _logger.e('Failed to get download URL for $storagePath: $e');
      throw ErrorHandler.handleStorageError(e);
    }
  }

  // Delete file
  Future<void> deleteFile(String storagePath) async {
    try {
      Reference ref = _storage.ref().child(storagePath);
      await ref.delete();
      
      _logger.d('File deleted successfully: $storagePath');
    } catch (e) {
      _logger.e('Failed to delete file $storagePath: $e');
      throw ErrorHandler.handleStorageError(e);
    }
  }

  // List files in directory
  Future<List<String>> listFiles(String directoryPath) async {
    try {
      Reference ref = _storage.ref().child(directoryPath);
      ListResult result = await ref.listAll();
      
      List<String> filePaths = result.items.map((item) => item.fullPath).toList();
      _logger.d('Listed ${filePaths.length} files in: $directoryPath');
      return filePaths;
    } catch (e) {
      _logger.e('Failed to list files in $directoryPath: $e');
      throw ErrorHandler.handleStorageError(e);
    }
  }

  // Upload progress stream
  Stream<TaskSnapshot> uploadFileWithProgress(String filePath, String storagePath) {
    try {
      File file = File(filePath);
      Reference ref = _storage.ref().child(storagePath);
      return ref.putFile(file).snapshotEvents;
    } catch (e) {
      _logger.e('Failed to start upload with progress for $filePath: $e');
      throw ErrorHandler.handleStorageError(e);
    }
  }

  // Delete directory
  Future<void> deleteDirectory(String directoryPath) async {
    try {
      Reference ref = _storage.ref().child(directoryPath);
      ListResult result = await ref.listAll();
      
      for (final item in result.items) {
        await item.delete();
      }
      
      for (final prefix in result.prefixes) {
        await deleteDirectory(prefix.fullPath);
      }
      
      _logger.d('Directory deleted successfully: $directoryPath');
    } catch (e) {
      _logger.e('Failed to delete directory $directoryPath: $e');
      throw ErrorHandler.handleStorageError(e);
    }
  }
}