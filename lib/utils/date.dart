import 'package:intl/intl.dart';

String formatDate(DateTime? dateTime) {
  if (dateTime == null) {
    return 'N/A';
  }
  final adjustedDateTime = dateTime.add(const Duration(hours: 7));
  return DateFormat('HH:mm dd/MM/yyyy').format(adjustedDateTime);
}
