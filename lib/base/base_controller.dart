import 'package:get/get.dart';
import 'package:getx_study/base/interface.dart';
import 'package:getx_study/enum/response_status.dart';

abstract class BaseController extends GetxController implements IRetry, IEmptyTap  {

  ResponseStatus status = ResponseStatus.loading;

}

/// 要不要with是个问题
mixin ResponseStatusMixin on GetxController {
  ResponseStatus status = ResponseStatus.loading;
}