class ImageUtils {
  static String getValidImageUrl(String url) {
    if (url.trim().isEmpty) return "";
    
    // Check if it's a Drive URL
    if (url.contains('drive.google.com')) {
      final RegExp driveRegex = RegExp(r'/file/d/([a-zA-Z0-9_-]+)');
      final match = driveRegex.firstMatch(url);
      String? fileId;
      
      if (match != null && match.groupCount >= 1) {
        fileId = match.group(1);
      } else {
        final uri = Uri.tryParse(url);
        if (uri != null && uri.queryParameters.containsKey('id')) {
          fileId = uri.queryParameters['id'];
        }
      }
      
      if (fileId != null) {
        // Enlace directo de Drive para imágenes
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }
    
    return url.trim();
  }
}
