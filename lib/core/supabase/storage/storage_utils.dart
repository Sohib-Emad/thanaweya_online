/// MIME type resolution utilities for Supabase Storage uploads.
class StorageUtils {
  StorageUtils._();

  /// Resolves a file extension to its corresponding MIME type.
  static String resolveMimeType(String ext) {
    switch (ext.toLowerCase().replaceAll('.', '')) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4v':
        return 'video/x-m4v';
      default:
        return 'image/jpeg';
    }
  }
}
