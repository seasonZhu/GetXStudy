import 'dart:async';

import 'package:getx_study/entity/base_entity.dart';
import 'package:getx_study/repository/collection_repository.dart';

class PendingCollection {
  PendingCollection(this.id, this.collected);
  final int id;
  final bool collected;
  final result = Completer<BaseEntity<Object?>>();

  void succeed() => result.complete(BaseEntity(0, '', null));
}

class FakeCollectionRepository extends CollectionRepository {
  final calls = <PendingCollection>[];

  @override
  Future<BaseEntity<Object?>> setCollected(int articleId, bool collected) {
    final call = PendingCollection(articleId, collected);
    calls.add(call);
    return call.result.future;
  }
}
