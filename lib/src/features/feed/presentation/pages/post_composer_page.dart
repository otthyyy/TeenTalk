import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import '../../../core/analytics/analytics_provider.dart';

class PostComposerPage extends ConsumerStatefulWidget {
  const PostComposerPage({super.key});

  @override
  ConsumerState<PostComposerPage> createState() => _PostComposerPageState();
}

class _PostComposerPageState extends ConsumerState<PostComposerPage> {
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Logger _logger = Logger();
  bool _isAnonymous = false;
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isUploading = false;
  String _selectedSection = 'spotted';
  
  final List<Map<String, String>> _sections = [
    {'value': 'spotted', 'label': 'Spotted'},
    {'value': 'general', 'label': 'General'},
  ];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        _logger.i('User cancelled image selection');
        return;
      }

      if (!mounted) return;

      if (kIsWeb) {
        // Web platform: use bytes
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = pickedFile.name;
          _selectedImageFile = null;
        });
        _logger.i('Image selected on web: ${pickedFile.name}');
      } else {
        // Mobile/Desktop platform: use File
        final file = File(pickedFile.path);
        
        // Verify file exists
        if (!await file.exists()) {
          throw Exception('Selected image file does not exist');
        }

        // Check file size (max 5MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image size must be less than 5MB');
        }

        setState(() {
          _selectedImageFile = file;
          _selectedImageName = pickedFile.name;
          _selectedImageBytes = null;
        });
        _logger.i('Image selected on mobile: ${pickedFile.path}');
      }
    } on Exception catch (e, stackTrace) {
      _logger.e('Failed to pick image', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('Unexpected error picking image', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to select image. Please check app permissions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImageFile != null || _selectedImageBytes != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedImageFile = null;
                    _selectedImageBytes = null;
                    _selectedImageName = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authStateProvider);
    final userProfile = ref.read(userProfileProvider).value;
    
    if (authState.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to create a post')),
      );
      return;
    }

    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your profile first')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final repository = PostsRepository();
      
      // Only pass imageFile on non-web platforms
      File? imageFileToUpload;
      if (!kIsWeb && _selectedImageFile != null) {
        imageFileToUpload = _selectedImageFile;
      }
      
      await repository.createPost(
        authorId: authState.user!.uid,
        authorNickname: userProfile.nickname,
        isAnonymous: _isAnonymous,
        content: _contentController.text.trim(),
        imageFile: imageFileToUpload,
        imageBytes: kIsWeb ? _selectedImageBytes : null,
        imageName: _selectedImageName,
        section: _selectedSection,
        school: userProfile.school,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to feed and trigger refresh
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to create post', error: e, stackTrace: stackTrace);
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showPostingGuidelines() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Posting Guidelines'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Be respectful and kind to others', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('• No inappropriate language or content', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('• Keep posts relevant and constructive', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('• Respect privacy - no sharing personal info', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('• Images must be appropriate and under 5MB', style: TextStyle(fontSize: 14)),
              SizedBox(height: 8),
              Text('• Posts are subject to moderation', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _showPostingGuidelines,
            child: const Text('Guidelines'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Section selection
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Section',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _sections.map((section) {
                        final isSelected = section['value'] == _selectedSection;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(section['label']!),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSection = section['value']!;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content input
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter some content';
                    }
                    if (value.trim().length > 2000) {
                      return 'Content cannot exceed 2000 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind?',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
              ),
            ),
            
            // Image preview
            if (_selectedImageFile != null || _selectedImageBytes != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _selectedImageBytes != null
                          ? Image.memory(
                              _selectedImageBytes!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _selectedImageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (_selectedImageName != null)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedImageName!,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedImageFile = null;
                            _selectedImageBytes = null;
                            _selectedImageName = null;
                          });
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Anonymous toggle and image button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Switch(
                          value: _isAnonymous,
                          onChanged: (value) {
                            setState(() {
                              _isAnonymous = value;
                            });
                          },
                        ),
                        const Text('Post anonymously'),
                      ],
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: _showImagePicker,
                    icon: const Icon(Icons.photo_library),
                  ),
                ],
              ),
            ),
            
            // Submit button
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: FilledButton(
                onPressed: _isUploading ? null : _submitPost,
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Posting...'),
                        ],
                      )
                    : const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}