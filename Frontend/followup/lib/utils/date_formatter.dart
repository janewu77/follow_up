import 'dart:ui';
import 'package:intl/intl.dart';

class DateFormatter {
  /// Get current locale code (e.g., 'zh', 'en', 'de')
  static String get _localeCode {
    final locale = PlatformDispatcher.instance.locale;
    return locale.languageCode;
  }

  /// Check if current locale is Chinese
  static bool get _isChinese => _localeCode == 'zh';

  /// Check if current locale is German
  static bool get _isGerman => _localeCode == 'de';

  // 格式化日期：2026年2月15日 / Feb 15, 2026 / 15. Feb. 2026
  static String formatDate(DateTime date) {
    if (_isChinese) {
      return DateFormat('yyyy年M月d日').format(date);
    } else if (_isGerman) {
      return DateFormat('d. MMM yyyy', 'de').format(date);
    } else {
      return DateFormat('MMM d, yyyy', 'en').format(date);
    }
  }

  // 格式化时间：19:30
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // 格式化日期时间：2026年2月15日 19:30 / Feb 15, 2026 19:30
  static String formatDateTime(DateTime dateTime) {
    if (_isChinese) {
      return DateFormat('yyyy年M月d日 HH:mm').format(dateTime);
    } else if (_isGerman) {
      return DateFormat('d. MMM yyyy HH:mm', 'de').format(dateTime);
    } else {
      return DateFormat('MMM d, yyyy HH:mm', 'en').format(dateTime);
    }
  }

  // 格式化日期（短格式）：2/15
  static String formatDateShort(DateTime date) {
    if (_isChinese) {
      return DateFormat('M月d日').format(date);
    } else if (_isGerman) {
      return DateFormat('d.M.', 'de').format(date);
    } else {
      return DateFormat('M/d', 'en').format(date);
    }
  }

  // 格式化星期：周六 / Sat / Sa
  static String formatWeekday(DateTime date) {
    if (_isChinese) {
      const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return weekdays[date.weekday - 1];
    } else if (_isGerman) {
      return DateFormat('E', 'de').format(date);
    } else {
      return DateFormat('E', 'en').format(date);
    }
  }

  // 计算倒计时 (locale-aware)
  static String getCountdown(DateTime eventDate) {
    final now = DateTime.now();
    final difference = eventDate.difference(now);

    if (difference.isNegative) {
      return _isChinese ? '已结束' : (_isGerman ? 'Beendet' : 'Ended');
    }

    if (difference.inDays > 0) {
      if (_isChinese) {
        return '${difference.inDays}天后';
      } else if (_isGerman) {
        return 'in ${difference.inDays} Tag${difference.inDays > 1 ? 'en' : ''}';
      } else {
        return 'in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
      }
    } else if (difference.inHours > 0) {
      if (_isChinese) {
        return '${difference.inHours}小时后';
      } else if (_isGerman) {
        return 'in ${difference.inHours} Std.';
      } else {
        return 'in ${difference.inHours} hr${difference.inHours > 1 ? 's' : ''}';
      }
    } else if (difference.inMinutes > 0) {
      if (_isChinese) {
        return '${difference.inMinutes}分钟后';
      } else if (_isGerman) {
        return 'in ${difference.inMinutes} Min.';
      } else {
        return 'in ${difference.inMinutes} min';
      }
    } else {
      return _isChinese ? '即将开始' : (_isGerman ? 'Beginnt gleich' : 'Starting soon');
    }
  }

  // 格式化时间范围
  static String formatTimeRange(DateTime start, DateTime? end) {
    final startStr = formatTime(start);
    if (end == null) {
      return startStr;
    }
    return '$startStr - ${formatTime(end)}';
  }
}
