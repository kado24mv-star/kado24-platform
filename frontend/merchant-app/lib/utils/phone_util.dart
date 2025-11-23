/// Utility class for Cambodia phone number operations
/// Supports both "0" prefix (local format) and "+855" prefix (international format)
class PhoneUtil {
  static const String cambodiaCountryCode = '+855';
  static const String cambodiaLocalPrefix = '0';

  /// Normalize phone number to international format (+855XXXXXXXX)
  /// Accepts:
  /// - "0XXXXXXXX" -> "+855XXXXXXXX"
  /// - "+855XXXXXXXX" -> "+855XXXXXXXX" (no change)
  /// - "855XXXXXXXX" -> "+855XXXXXXXX"
  static String? normalize(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null;
    }

    // Remove all spaces, dashes, and parentheses
    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Handle "0" prefix (local format) - convert to +855
    if (cleaned.startsWith(cambodiaLocalPrefix)) {
      // Remove leading "0" and add +855
      String digits = cleaned.substring(1);
      if (_isValidDigits(digits)) {
        return '$cambodiaCountryCode$digits';
      }
    }

    // Handle "+855" prefix (already in international format)
    if (cleaned.startsWith(cambodiaCountryCode)) {
      String digits = cleaned.substring(4); // Remove "+855"
      if (_isValidDigits(digits)) {
        return '$cambodiaCountryCode$digits';
      }
    }

    // Handle "855" prefix (without +)
    if (cleaned.startsWith('855') && cleaned.length >= 11) {
      String digits = cleaned.substring(3); // Remove "855"
      if (_isValidDigits(digits)) {
        return '$cambodiaCountryCode$digits';
      }
    }

    // If already in correct format, return as is
    if (cleaned.startsWith('+') && cleaned.length >= 12) {
      return cleaned;
    }

    return null;
  }

  /// Check if phone number is valid (accepts both 0 and +855 formats)
  static bool isValid(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return false;
    }

    String cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check for "0" prefix format (0XXXXXXXX where X is 8-9 digits)
    if (cleaned.startsWith(cambodiaLocalPrefix)) {
      String digits = cleaned.substring(1);
      return _isValidDigits(digits);
    }

    // Check for "+855" format
    if (cleaned.startsWith(cambodiaCountryCode)) {
      String digits = cleaned.substring(4);
      return _isValidDigits(digits);
    }

    // Check for "855" format (without +)
    if (cleaned.startsWith('855') && cleaned.length >= 11) {
      String digits = cleaned.substring(3);
      return _isValidDigits(digits);
    }

    return false;
  }

  /// Validate that digits are 8-9 digits (Cambodia phone number length)
  static bool _isValidDigits(String digits) {
    if (digits.isEmpty) {
      return false;
    }
    // Cambodia phone numbers are 8-9 digits after country code
    return RegExp(r'^\d{8,9}$').hasMatch(digits);
  }

  /// Format phone number for display (e.g., "+855 12 345 678")
  static String formatForDisplay(String? phoneNumber) {
    String? normalized = normalize(phoneNumber);
    if (normalized == null) {
      return phoneNumber ?? '';
    }

    // Format: +855 XX XXX XXX
    if (normalized.length == 12) {
      // +855 + 8 digits
      return '${normalized.substring(0, 4)} ${normalized.substring(4, 6)} ${normalized.substring(6, 9)} ${normalized.substring(9)}';
    } else if (normalized.length == 13) {
      // +855 + 9 digits
      return '${normalized.substring(0, 4)} ${normalized.substring(4, 6)} ${normalized.substring(6, 9)} ${normalized.substring(9)}';
    }

    return normalized;
  }

  /// Convert international format to local format (for display)
  /// +85512345678 -> 012345678
  static String toLocalFormat(String? phoneNumber) {
    String? normalized = normalize(phoneNumber);
    if (normalized == null || !normalized.startsWith(cambodiaCountryCode)) {
      return phoneNumber ?? '';
    }

    return '$cambodiaLocalPrefix${normalized.substring(4)}';
  }
}

