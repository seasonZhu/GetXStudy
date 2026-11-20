import 'package:getx_study/i18n/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/extension/string_extension.dart';
import 'package:getx_study/generated/assets.dart';
import 'package:getx_study/widgets/animated_button.dart';

class InfoCell extends StatelessWidget {
  final ArticleInfoDatas _model;

  final ValueChanged<ArticleInfoDatas> _cellTapCallback;

  final bool _isNeedBottomLine;

  const InfoCell(
      {super.key,
      required ArticleInfoDatas model,
      required ValueChanged<ArticleInfoDatas> callback,
      bool isNeedBottomLine = true})
      : _model = model,
        _cellTapCallback = callback,
        _isNeedBottomLine = isNeedBottomLine;

  @override
  Widget build(BuildContext context) {
    final author = _model.author?.trim();
    final timestamp = _model.shareDate ?? _model.publishTime;
    final imageUrl = _model.envelopePic?.trim() ?? '';
    final metadata = [
      if (_model.fresh == true) AppText.t('article.fresh'),
      if ((_model.type ?? 0) != 0) AppText.t('article.pinned'),
      if (author != null && author.isNotEmpty)
        author
      else
        _model.shareUser?.trim() ?? '',
      timestamp == null
          ? (_model.niceShareDate?.trim() ?? '')
          : AppText.date(timestamp),
    ].where((value) => value.isNotEmpty).toList();
    final brightness =
        CupertinoTheme.of(context).brightness ?? Theme.of(context).brightness;
    final foreground =
        brightness == Brightness.dark ? Colors.white : Colors.black87;
    final secondary =
        brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return AnimatedInkWell(
      onTap: () => _cellTapCallback(_model),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  if (imageUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        width: 56,
                        height: 56,
                        fit: BoxFit.contain,
                        imageUrl: imageUrl,
                        placeholder: (context, url) =>
                            Image.asset(Assets.assetsImagesPlaceholder),
                        errorWidget: (context, url, error) =>
                            Image.asset(Assets.assetsImagesPlaceholder),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (_model.title ?? '').replaceHtmlElement,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: foreground,
                          ),
                        ),
                        if (metadata.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              for (final value in metadata)
                                Text(
                                  value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TextStyle(fontSize: 12, color: secondary),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isNeedBottomLine)
              Divider(
                  height: 1, thickness: 0.5, color: secondary.withAlpha(55)),
          ],
        ),
      ),
    );
  }
}
