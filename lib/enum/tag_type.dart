import 'package:getx_study/i18n/app_text.dart';
import 'package:getx_study/http_util/api.dart';

enum TagType {
    project,
    publicNumber,
    tree;
}

extension Ext on TagType {
    String get title {
        switch (this) {
        case TagType.project:
            return AppText.t('projects.title');
        case TagType.publicNumber:
            return AppText.t('accounts.title');
        case TagType.tree:
            return AppText.t('tree.title');
        }
    }
    
    int get pageNum {
        switch (this) {
        case TagType.project:
            return 1;
        case TagType.publicNumber:
            return 1;
        case TagType.tree:
            return 0;
        }
    }

    String get tabApi {
      switch (this) {
        case TagType.project:
            return Api.getProjectClassify;
        case TagType.publicNumber:
            return Api.getPublicNumber;
        case TagType.tree:
            return Api.getTree;
        }
    }

    String get detailApi {
      switch (this) {
        case TagType.project:
            return Api.getProjectClassifyList;
        case TagType.publicNumber:
            return Api.getPublicNumberList;
        case TagType.tree:
            return Api.getTreeDetailList;
        }
    }
}
