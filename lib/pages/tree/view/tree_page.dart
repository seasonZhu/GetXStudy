import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:getx_study/pages/common/status_view.dart';
import 'package:getx_study/pages/tree/controller/tree_controller.dart';
import 'tree_cell.dart';

class TreePage extends GetView<TreeController> {
  const TreePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("体系"),
      ),
      body: StatusView(
        controller: controller,
        contentBuilder: (_) {
          print(controller.data);
          // return Container();
          return ListView.builder(
            shrinkWrap: true,
            itemCount: controller.data?.length ?? 0,
            itemBuilder: ((context, index) {
              final model = controller.data?[index];
              if (model != null) {
                return TreeCell(model);
              } else {
                return Container();
              }
            }),
          );
        },
      ),
    );
  }
}

// class TreePage extends GetView<TreeController> {
//   const TreePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("体系"),
//       ),
//       body: StatusView(
//         controller: controller,
//         contentBuilder: (_) {
//           return ListView.builder(
//             itemBuilder: (context, index) {
//               final model = controller.data?[index];
//               // if (model != null) {
//               //   return TreeCell(model);
//               // } else {
//               //   return Container();
//               // }
//               return Container();
//             },
//             itemCount: controller.data?.length,
//           );
//         },
//       ),
//     );
//   }
// }
