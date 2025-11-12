import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DateFormatHelper {
  static String formatRelativeTime(BuildContext context, DateTime? dateTime) {
    if (dateTime == null) {
      return AppLocalizations.of(context)!.neverChecked;
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inHours < 1) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (difference.inDays < 30) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else {
      // Format as date
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    }
  }
}
