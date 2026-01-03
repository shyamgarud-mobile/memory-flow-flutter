import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing Google Drive backup and restore operations
class GoogleDriveService {
  // Singleton instance
  static final GoogleDriveService _instance = GoogleDriveService._internal();

  factory GoogleDriveService() {
    return _instance;
  }

  GoogleDriveService._internal();

  static const String _folderName = 'MemoryFlow';
  static const String _backupFileName = 'backup.json';
  static const String _prefKeyFolderId = 'google_drive_folder_id';
  static const String _prefKeyUserEmail = 'google_drive_user_email';

  // Note: For Android, OAuth credentials are configured via package name + SHA-1 in Google Cloud Console
  // For iOS/Web, you would need to specify clientId here
  // See GOOGLE_DRIVE_SETUP.md for setup instructions

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  bool _isInitialized = false;

  /// Check if user is currently signed in
  Future<bool> isSignedIn() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _currentUser != null;
  }

  /// Get current user email
  String? get userEmail => _currentUser?.email;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
    });

    // Try silent sign in
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        _currentUser = account;
        print('✓ Google Drive: Signed in silently as ${account.email}');
      } else {
        print('ℹ️ Google Drive: No previous sign-in found');
      }
    } catch (e) {
      print('Error during silent sign-in: $e');
    }

    _isInitialized = true;
  }

  /// Refresh connection status - force check current sign-in state
  Future<void> refreshConnectionStatus() async {
    try {
      final account = await _googleSignIn.signInSilently();
      _currentUser = account;
      if (account != null) {
        print('✓ Google Drive: Refreshed connection for ${account.email}');
      } else {
        print('ℹ️ Google Drive: Not signed in');
      }
    } catch (e) {
      print('Error refreshing connection status: $e');
      _currentUser = null;
    }
  }

  /// Sign in with Google
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      _currentUser = account;
      _driveApi = await _getDriveApi();

      // Save user email
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyUserEmail, account.email);

      return true;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;

    // Clear saved data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyFolderId);
    await prefs.remove(_prefKeyUserEmail);
  }

  /// Get Drive API instance
  Future<drive.DriveApi> _getDriveApi() async {
    final headers = await _currentUser?.authHeaders;
    if (headers == null) {
      throw Exception('Not authenticated');
    }

    final client = _GoogleAuthClient(headers);
    return drive.DriveApi(client);
  }

  /// Get or create MemoryFlow folder
  Future<String> _getOrCreateFolder() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFolderId = prefs.getString(_prefKeyFolderId);

    // Try to use saved folder ID
    if (savedFolderId != null) {
      try {
        await _driveApi!.files.get(savedFolderId);
        return savedFolderId;
      } catch (e) {
        // Folder doesn't exist anymore, create new one
      }
    }

    // Search for existing folder
    final query = "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
    final fileList = await _driveApi!.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    String folderId;
    if (fileList.files != null && fileList.files!.isNotEmpty) {
      folderId = fileList.files!.first.id!;
    } else {
      // Create new folder
      final folder = drive.File()
        ..name = _folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await _driveApi!.files.create(folder);
      folderId = createdFolder.id!;
    }

    // Save folder ID
    await prefs.setString(_prefKeyFolderId, folderId);
    return folderId;
  }

  /// Backup data to Google Drive
  Future<bool> backup(Map<String, dynamic> data) async {
    try {
      if (_driveApi == null) {
        _driveApi = await _getDriveApi();
      }

      final folderId = await _getOrCreateFolder();
      final jsonData = jsonEncode(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'backup_$timestamp.json';

      // Create file metadata
      final file = drive.File()
        ..name = fileName
        ..parents = [folderId]
        ..description = 'MemoryFlow backup created on ${DateTime.now()}';

      // Upload file
      final media = drive.Media(
        Stream.value(utf8.encode(jsonData)),
        jsonData.length,
      );

      await _driveApi!.files.create(
        file,
        uploadMedia: media,
      );

      return true;
    } catch (e) {
      print('Error backing up to Google Drive: $e');
      return false;
    }
  }

  /// List all available backups
  Future<List<BackupMetadata>> listBackups() async {
    try {
      if (_driveApi == null) {
        _driveApi = await _getDriveApi();
      }

      final folderId = await _getOrCreateFolder();
      final query = "'$folderId' in parents and trashed=false and name contains 'backup_'";

      final fileList = await _driveApi!.files.list(
        q: query,
        spaces: 'drive',
        orderBy: 'createdTime desc',
        $fields: 'files(id, name, size, createdTime, description)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        return [];
      }

      return fileList.files!.map((file) {
        return BackupMetadata(
          id: file.id!,
          name: file.name!,
          size: int.tryParse(file.size ?? '0') ?? 0,
          createdAt: file.createdTime ?? DateTime.now(),
          description: file.description ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error listing backups: $e');
      return [];
    }
  }

  /// Restore data from a backup
  Future<Map<String, dynamic>?> restore(String fileId) async {
    try {
      if (_driveApi == null) {
        _driveApi = await _getDriveApi();
      }

      final response = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final data = <int>[];
      await for (var chunk in response.stream) {
        data.addAll(chunk);
      }

      final jsonString = utf8.decode(data);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error restoring from Google Drive: $e');
      return null;
    }
  }

  /// Delete a backup
  Future<bool> deleteBackup(String fileId) async {
    try {
      if (_driveApi == null) {
        _driveApi = await _getDriveApi();
      }

      await _driveApi!.files.delete(fileId);
      return true;
    } catch (e) {
      print('Error deleting backup: $e');
      return false;
    }
  }
}

/// HTTP client with Google auth headers
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

/// Metadata for a backup file
class BackupMetadata {
  final String id;
  final String name;
  final int size;
  final DateTime createdAt;
  final String description;

  BackupMetadata({
    required this.id,
    required this.name,
    required this.size,
    required this.createdAt,
    required this.description,
  });

  String get sizeFormatted {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
