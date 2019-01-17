import 'package:flutter/material.dart';
import 'package:flutter_plugin_wan/conf/imgs.dart';
import 'package:flutter_plugin_wan/conf/pagestatus.dart';
import 'package:flutter_plugin_wan/event/event.dart';
import 'package:flutter_plugin_wan/model/dto/articledatas_dto.dart';
import 'package:flutter_plugin_wan/net/request.dart';
import 'package:flutter_plugin_wan/page/article_list_item.dart';
import 'package:flutter_plugin_wan/utils/toast_utils.dart';
import 'package:flutter_plugin_wan/widget/empty_view.dart';
import 'package:flutter_plugin_wan/widget/error_view.dart';
import 'package:flutter_plugin_wan/widget/loading.dart';
import 'package:flutter_plugin_wan/widget/pullrefresh/pullrefresh.dart';

///文章列表
class ArticleList extends StatefulWidget {
  final id;
  final String keyword;

  const ArticleList({Key key, this.id, this.keyword: ''}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ArticleListState();
  }
}

class ArticleListState extends State<ArticleList>
    with AutomaticKeepAliveClientMixin {
  int index = 1;
  List<Datas> _listDatas;

  PageStatus status = PageStatus.LOADING;

  @override
  void initState() {
    super.initState();
    _refresh();
    bus.on<FavoriteEvent>().listen((event) {
      _refresh();
    });
  }

  Future<Null> _refresh() async {
    index = 1;
    Request().search(index, widget.keyword).then((data) {
      if (this.mounted) {
        setState(() {
          _listDatas = data.datas;
          index++;
          status = _listDatas.length == 0 ? PageStatus.EMPTY : PageStatus.DATA;
        });
      }
    }).catchError((e) {
      ToastUtils.showShort(e.message);
      setState(() {
        status = PageStatus.ERROR;
      });
    });
  }

  //加载数据
  Future<Null> _loadMore() async {
    Request().search(index, widget.keyword).then((data) {
      setState(() {
        _listDatas.addAll(data.datas);
        index++;
      });
    }).catchError((e) {
      ToastUtils.showShort(e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case PageStatus.LOADING:
        return Loading();
        break;
      case PageStatus.DATA:
        return PullRefresh(
          onRefresh: _refresh,
          onLoadmore: _loadMore,
          scrollView: ListView.builder(
            itemBuilder: (context, index) {
              return _buildItem(index);
            },
            itemCount: _listDatas.length,
          ),
        );
        break;
      case PageStatus.ERROR:
        return ErrorView(
          onClick: () {
            _refresh();
          },
        );
      case PageStatus.EMPTY:
      default:
        return EmptyView(
          iconPath: ImagePath.icEmpty,
          hint: '暂无内容，点击重试',
          onClick: () {
            _refresh();
          },
        );
    }
  }

  //创建item
  Widget _buildItem(int index) {
    Datas data = _listDatas[index];
    return ArticleListItemWidget(data);
  }

  @override
  bool get wantKeepAlive => true;
}
