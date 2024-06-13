import 'package:cherrilog/cherrilog.dart';

final cherrilog = CherriLog.init(
  options: CherriOptions()
    ..logLevelRange = CherriLogLevelRanges.all
    ..useBuffer = false,
).logTo(CherriConsole());