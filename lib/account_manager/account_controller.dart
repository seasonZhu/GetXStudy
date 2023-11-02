import 'package:get/get.dart';

/// 因为AccountManager已经是一个可以满地跑了单例了,所以用不用AccountController感觉就不是那么重要了
class AccountController extends GetxController {
  
}

/*
这个类就像一个 "GetxController"，它共享相同的生命周期 （"onInit()"、"onReady()"、"onClose()"） 。 但里面没有 "逻辑"。它只是通知GetX的依赖注入系统，这个子类不能从内存中删除。
所以这对保持你的 "服务 "总是可以被Get.find()获取到并保持运行是超级有用的。比如 ApiService，StorageService，CacheService。
 */
class AccountService extends GetxService {

}