import 'package:flutter/material.dart';
import 'package:flutter_plugin_wan/model/dto/favoritedatas_dto.dart';
import 'package:flutter_plugin_wan/page/article.dart';
import 'package:flutter_plugin_wan/widget/tags.dart';

class FavoriteListItemWidget extends StatefulWidget {
  final Datas data;

  FavoriteListItemWidget(this.data);

  @override
  State<StatefulWidget> createState() {
    return ArticleListItemState();
  }
}

class ArticleListItemState extends State<FavoriteListItemWidget> {
  @override
  Widget build(BuildContext context) {
    widget.data.title = widget.data.title
        .replaceAll(RegExp("(<em[^>]*>)|(</em>)"), "")
        .replaceAll("&mdash;", "-");

    widget.data.desc = (null == widget.data.desc)
        ? ""
        : widget.data.desc
            .replaceAll(RegExp("(<em[^>]*>)|(</em>)"), "")
            .replaceAll("&mdash;", "-")
            .replaceAll(RegExp("\n{2,}"), "\n")
            .replaceAll(RegExp("\s{2,}"), " ");
    return Card(
      child: ListTile(
        title: Container(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            widget.data.title,
            softWrap: true, //是否自动换行
            overflow: TextOverflow.ellipsis, //截断处理
            maxLines: 2,
            style: TextStyle(fontSize: 17),
          ),
        ),
        subtitle: Row(
          children: <Widget>[
            Text(
              '作者：',
            ),
            Expanded(
                child: new Text(
              widget.data.author,
              style: TextStyle(color: Theme.of(context).textTheme.body1.color),
            )),
            Text(
              "时间:" + widget.data.niceDate,
            ),
          ],
        ),
        onTap: () {
          //点击跳转详情
          Navigator.of(context)
              .push(MaterialPageRoute<Null>(builder: (context) {
            return ArticlePage(
              widget.data.link,
              widget.data.originId,
              fav: true,
            );
          }));
        },
        contentPadding:
            EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 15),
      ),
      elevation: 3,
      margin: EdgeInsets.only(bottom: 15),
    );
  }
}
