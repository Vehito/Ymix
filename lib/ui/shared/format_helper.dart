import 'package:intl/intl.dart';

class FormatHelper {
  static final numberFormat = NumberFormat('#,##0', 'vi_VN');
  static final dateFormat = DateFormat("dd/MM/yyyy");
  static final onlyDateFormat = DateFormat("dd");
  static final dayMonthFormat = DateFormat("dd/MM");
  static final monthFormat = DateFormat("MM/yyyy");
  static final yearFormat = DateFormat("yyyy");
}
