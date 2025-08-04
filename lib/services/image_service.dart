import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // 画像を選択し、3:4比率でトリミング（レシピ本表紙用）
  Future<String?> pickAndCropImage({
    required BuildContext context,
    bool isDarkMode = false,
  }) async {
    try {
      // 画像ソース選択ダイアログ
      final source = await _showImageSourceDialog(context, isDarkMode);
      if (source == null) return null;

      // 画像を選択
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      // 3:4比率でトリミング
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '画像をトリミング',
            toolbarColor: isDarkMode ? Colors.grey[800] : Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.deepPurple,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            cropGridColor: Colors.white70,
            cropFrameColor: Colors.deepPurple,
            dimmedLayerColor: Colors.black54,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '画像をトリミング',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
          ),
        ],
      );

      if (croppedFile == null) return null;

      // アプリの永続化ディレクトリに保存
      final savedPath = await _saveImageToAppDirectory(croppedFile.path);
      return savedPath;
    } catch (e) {
      debugPrint('画像選択エラー: $e');
      return null;
    }
  }

  // 画像ソース選択ダイアログ
  Future<ImageSource?> _showImageSourceDialog(
    BuildContext context,
    bool isDarkMode,
  ) async {
    return await showDialog<ImageSource>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            title: Text(
              '画像を選択',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: 'ArmedLemon',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedCamera01,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  title: Text(
                    'カメラで撮影',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: HugeIcon(
                    icon: HugeIcons.strokeRoundedAlbum02,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                  title: Text(
                    'ギャラリーから選択',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'キャンセル',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // 画像をアプリディレクトリに保存
  Future<String> _saveImageToAppDirectory(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'images'));

    print('DEBUG: App documents directory: ${appDir.path}');
    print('DEBUG: Images directory: ${imagesDir.path}');

    // imagesディレクトリが存在しない場合は作成
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
      print('DEBUG: Created images directory');
    }

    // ユニークなファイル名を生成
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = p.extension(sourcePath);
    final fileName = 'img_$timestamp$extension';
    final targetPath = p.join(imagesDir.path, fileName);

    print('DEBUG: Source path: $sourcePath');
    print('DEBUG: Target path: $targetPath');

    // ファイルをコピー
    final sourceFile = File(sourcePath);
    await sourceFile.copy(targetPath);

    // コピー後にファイルが存在するか確認
    final targetFile = File(targetPath);
    final exists = await targetFile.exists();
    print('DEBUG: File copied successfully: $exists');
    
    if (exists) {
      final fileSize = await targetFile.length();
      print('DEBUG: File size: $fileSize bytes');
    }

    return targetPath;
  }

  // 画像ファイルを削除
  Future<bool> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('画像削除エラー: $e');
      return false;
    }
  }

  // 画像を選択し、4:3比率でトリミング（レシピ用）
  Future<String?> pickAndCropRecipeImage({
    required BuildContext context,
    bool isDarkMode = false,
  }) async {
    try {
      // 画像ソース選択ダイアログ
      final source = await _showImageSourceDialog(context, isDarkMode);
      if (source == null) return null;

      // 画像を選択
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );

      if (pickedFile == null) return null;

      // 4:3比率でトリミング
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '画像をトリミング',
            toolbarColor: isDarkMode ? Colors.grey[800] : Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: Colors.deepPurple,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            cropGridColor: Colors.white70,
            cropFrameColor: Colors.deepPurple,
            dimmedLayerColor: Colors.black54,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '画像をトリミング',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
          ),
        ],
      );

      if (croppedFile == null) return null;

      // アプリの永続化ディレクトリに保存
      final savedPath = await _saveImageToAppDirectory(croppedFile.path);
      return savedPath;
    } catch (e) {
      debugPrint('画像選択エラー: $e');
      return null;
    }
  }

  // 画像ファイルが存在するかチェック
  Future<bool> imageExists(String imagePath) async {
    final file = File(imagePath);
    return await file.exists();
  }
}
