import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:getx_study/entity/article_info_entity.dart';
import 'package:getx_study/extension/string_extension.dart';

class InfoCell extends StatelessWidget {
  final ArticleInfoDatas _model;

  final ValueChanged<ArticleInfoDatas> _cellTapCallback;

  const InfoCell(
      {Key? key,
      required ArticleInfoDatas model,
      required ValueChanged<ArticleInfoDatas> callback})
      : _model = model,
        _cellTapCallback = callback,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          _cellTapCallback(_model);
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          child: _getRow(),
        ),
      ),
    );
  }

  Widget _imageView() {
    return (_model.envelopePic?.isNotEmpty ?? false)
        ? SizedBox(
            width: 60,
            height: 60,
            child: CachedNetworkImage(
              fit: BoxFit.fitHeight,
              imageUrl: _model.envelopePic.toString(),
              placeholder: (context, url) => Image.asset(
                "assets/images/placeholder.png",
              ),
            ),
          )
        : Container();
  }

  Widget _contentView() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(
          left: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _model.title.toString().replaceHtmlElement,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    (_model.fresh ?? false)
                        ? const Text(
                            "最新 ",
                            style: TextStyle(color: Colors.grey),
                          )
                        : Container(),
                    _model.type != null && _model.type != 0
                        ? const Text(
                            "置顶 ",
                            style: TextStyle(color: Colors.grey),
                          )
                        : Container(),
                    (_model.author.toString().isNotEmpty) ||
                            (_model.shareUser.toString().isNotEmpty)
                        ? Text(
                            _model.author.toString(),
                            style: const TextStyle(color: Colors.grey),
                          )
                        : Container(),
                  ],
                ),
                Text(
                  _model.niceShareDate ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _getRow() {
    return Row(
      children: <Widget>[
        _imageView(),
        _contentView(),
      ],
    );
  }
}
