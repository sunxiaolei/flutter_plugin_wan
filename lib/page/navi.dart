import 'package:flutter/material.dart';
import 'package:flutter_plugin_wan/model/dto/navi_dto.dart';
import 'package:flutter_plugin_wan/model/vo/flowitem_vo.dart';
import 'package:flutter_plugin_wan/net/request.dart';
import 'package:flutter_plugin_wan/page/article.dart';
import 'package:flutter_plugin_wan/utils/toast_utils.dart';
import 'package:flutter_plugin_wan/widget/error_view.dart';
import 'package:flutter_plugin_wan/widget/flowitems.dart';
import 'package:flutter_plugin_wan/widget/loading.dart';

///导航
class NaviPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _NaviWidget();
  }
}

class _NaviWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NaviState();
  }
}

class _NaviState extends State<_NaviWidget>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  List<Tab> _tabs = List();
  List<FlowItemsWidget> _tabpages = List();

  Widget _appbar;
  Widget _body;

  @override
  void initState() {
    super.initState();
    _appbar = AppBar(
      title: Text('WanFlutter'),
    );
    _body = Loading();
    _getData();
  }

  _getData() async {
    Request().getNavi().then((datas) {
      _controller = TabController(length: datas.length, vsync: this);
      _tabs = datas
          .map<Tab>((NaviDTO d) => Tab(
                text: d.name,
              ))
          .toList();
      _tabpages = datas
          .map<FlowItemsWidget>((NaviDTO d) => FlowItemsWidget(
              items: d.articles
                  .map((a) => FlowItemVO(a.id, a.title, a.link))
                  .toList(),
              onPress: (item) {
                Navigator.of(context)
                    .push(MaterialPageRoute<Null>(builder: (context) {
                  return ArticlePage(item.link, item.id);
                }));
              }))
          .toList();
      _appbar = AppBar(
        title: Text('WanFlutter'),
        bottom: TabBar(
          tabs: _tabs,
          controller: _controller,
          isScrollable: true,
        ),
      );
      _body = TabBarView(
        children: _tabpages,
        controller: _controller,
      );
      setState(() {});
    }).catchError((e) {
      ToastUtils.showShort(e.message);
      setState(() {
        _body = ErrorView(
          onClick: () {
            _getData();
          },
        );
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar,
      body: _body,
    );
  }
}
