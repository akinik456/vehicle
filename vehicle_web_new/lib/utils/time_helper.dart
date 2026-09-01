import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';

class TimeHelper {
  TimeHelper._();

		static String formatDateTime(
			int? timestamp,
		) {
			if (timestamp == null) return '';

			final dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();

			return DateFormat('dd.MM.yyyy HH:mm').format(dt);
		}
 
	
		static String formatOfflineSince(int? offlineSince) {
			if (offlineSince == null) return 'Offline';

			final diff = DateTime.now().difference(
				DateTime.fromMillisecondsSinceEpoch(offlineSince),
			);

			if (diff.inMinutes < 1) return 'Offline • now';
			if (diff.inHours < 1) return 'Offline • ${diff.inMinutes} min';
			if (diff.inDays < 1) return 'Offline • ${diff.inHours} h';

			return 'Offline • ${diff.inDays} d';
		}
		
		static String formatLastSeen(int? timestamp) {
			if (timestamp == null) return '';

			final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

			String two(int value) => value.toString().padLeft(2, '0');

			return '${two(date.day)}.${two(date.month)}.${date.year} '
					'${two(date.hour)}:${two(date.minute)}';
		}
		
		static String formatOfflineDate(int? offlineSince) {
			if (offlineSince == null) return 'Offline';

			final date = DateTime.fromMillisecondsSinceEpoch(offlineSince);

			String two(int value) => value.toString().padLeft(2, '0');

			return 'Offline • '
					'${two(date.day)}.${two(date.month)}.${date.year} '
					'${two(date.hour)}:${two(date.minute)}';
		}
		
		static String locationDurationText(
			BuildContext context,
			int? stationarySince,
		) {
			if (stationarySince == null) return '';

			final l10n = context.l10n;

			final diff = DateTime.now().difference(
				DateTime.fromMillisecondsSinceEpoch(stationarySince),
			);

			if (diff.inMinutes < 1) {
				return l10n.atThisLocationNow;
			}

			if (diff.inHours < 1) {
				return l10n.atThisLocationMinutes(
					diff.inMinutes,
				);
			}

			final hours = diff.inHours;
			final minutes = diff.inMinutes % 60;

			if (minutes == 0) {
				return l10n.atThisLocationHours(
					hours,
				);
			}

			return l10n.atThisLocationHoursMinutes(
				hours,
				minutes,
			);
		}

}