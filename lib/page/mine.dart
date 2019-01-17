import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_wan/app.dart';
import 'package:flutter_plugin_wan/conf/constant.dart';
import 'package:flutter_plugin_wan/conf/imgs.dart';
import 'package:flutter_plugin_wan/net/request.dart';
import 'package:flutter_plugin_wan/page/about.dart';
import 'package:flutter_plugin_wan/page/favorite.dart';
import 'package:flutter_plugin_wan/page/feedback.dart';
import 'package:flutter_plugin_wan/page/login.dart';
import 'package:flutter_plugin_wan/conf/themes.dart';
import 'package:flutter_plugin_wan/page/todo.dart';
import 'package:flutter_plugin_wan/utils/common_utils.dart';
import 'package:flutter_plugin_wan/utils/sp_utils.dart';
import 'package:flutter_plugin_wan/utils/toast_utils.dart';
import 'package:flutter_plugin_wan/event/event.dart';

///我的
class MinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MineState();
  }
}

class MineState extends State<MinePage> {
  bool _switchValue = false;
  String _name;

  @override
  void initState() {
    super.initState();
    _getTheme();
    bus.on<LoginEvent>().listen((event) {
      setState(() {
        if (event.data == null) {
          _getUser();
        } else {
          _name = event.data.username;
        }
      });
    });
  }

  void _getUser() async {
    SpUtils.getString(Constant.spUserName).then((str) {
      setState(() {
        _name = str;
      });
    });
  }

  void _getTheme() async {
    SpUtils.getBool(Constant.spDarkTheme).then((bool) {
      _switchValue = bool;
      setState(() {});
    });
  }

  void _setTheme(bool dark) async {
    SpUtils.getInt(Constant.spCurTheme).then((int) {
      _switchValue = dark;
      setState(() {
        SpUtils.setBool(Constant.spDarkTheme, dark);
        bus.fire(new ThemeEvent(int, dark));
      });
    });
  }

  //选择主题dialog
  _buildThemesDialogItems() {
    return themes
        .map((t) => SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: t.data.primaryColor,
                    radius: 10,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(t.name)
                ],
              ),
              onPressed: () {
                Navigator.pop(context, themes.indexOf(t));
              },
            ))
        .toList();
  }

  //用户头像、用户名
  _buildHead(context) {
    return Container(
      child: Center(
          child: GestureDetector(
        child: Column(
          children: <Widget>[
            Image.asset(
              'images/avatar.png',
              package: Constant.package,
              width: 80,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              _name == null ? '未登录' : _name,
              style: TextStyle(color: Colors.white, fontSize: 16),
            )
          ],
        ),
        onTap: () {
          if (!WanApp.isLogin) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          } else {
            //退出登录
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      content: Text('确定要退出登录么？'),
                      actions: <Widget>[
                        FlatButton(
                            child: const Text('取消'),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        FlatButton(
                            child: const Text('确定'),
                            onPressed: () {
                              Navigator.pop(context);
                              _logout();
                            })
                      ],
                    ));
          }
        },
      )),
      padding: EdgeInsets.only(top: 20, bottom: 20),
      color: Theme.of(context).primaryColor,
    );
  }

  //退出登录
  _logout() {
    CommonUtils.showLoading(context);
    Request().logout().then((res) {
      Navigator.pop(context);
      setState(() {
        WanApp.isLogin = false;
        _name = '未登录';
      });
    }).catchError((e) {
      Navigator.pop(context);
      ToastUtils.showShort(e.message);
    });
  }

  _buildItems(context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Container(
          child: Row(
            children: <Widget>[
              Container(
                child: Image.asset(
                  ImagePath.icTheme,
                  package: Constant.package,
                  color: Theme.of(context).primaryColorLight,
                  width: 25,
                ),
                margin: EdgeInsets.only(left: 15),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                            title: Text('选择主题'),
                            children: _buildThemesDialogItems(),
                          )).then((value) {
                    if (value != null) {
                      SpUtils.setBool(Constant.spDarkTheme, false).then((v) {
                        SpUtils.setInt(Constant.spCurTheme, value).then((v) {
                          bus.fire(new ThemeEvent(value, false));
                        });
                        _switchValue = false;
                      });
                    }
                  });
                },
                child: Container(
                  child: Text(
                    '选择主题',
                    style: TextStyle(fontSize: 16),
                  ),
                  margin: EdgeInsets.only(left: 5),
                ),
              ),
              Expanded(
                  child: Container(
                child: Row(
//                    alignment: Alignment.bottomRight,
                  //switch控件
                  children: <Widget>[
                    Text(
                      '夜间模式',
                      style: TextStyle(fontSize: 12),
                    ),
                    Switch.adaptive(
                        value: _switchValue,
                        onChanged: (bool) {
                          _setTheme(bool);
                        }),
                  ],
                  mainAxisAlignment: MainAxisAlignment.end,
                ),
              )),
            ],
          ),
          height: 40,
        ),
        Divider(),
        InkWell(
          onTap: () {
            if (WanApp.isLogin) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FavoritePage()));
            } else {
              ToastUtils.showShort('请先登录');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            }
          },
          child: Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    ImagePath.icFavotite,
                    package: Constant.package,
                    color: Theme.of(context).primaryColorLight,
                    width: 25,
                  ),
                  margin: EdgeInsets.only(left: 15),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      '我的收藏',
                      style: TextStyle(fontSize: 16),
                    ),
                    margin: EdgeInsets.only(left: 5),
                  ),
//                  margin: EdgeInsets.only(left: 5),
                ),
              ],
            ),
            height: 40,
          ),
        ),
        Divider(),
        InkWell(
          onTap: () {
            if (WanApp.isLogin) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => TodoPage()));
            } else {
              ToastUtils.showShort('请先登录');
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            }
          },
          child: Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    ImagePath.icTodo,
                    package: Constant.package,
                    color: Theme.of(context).primaryColorLight,
                    width: 25,
                  ),
                  margin: EdgeInsets.only(left: 15),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      'TODO',
                      style: TextStyle(fontSize: 16),
                    ),
                    margin: EdgeInsets.only(left: 5),
                  ),
//                  margin: EdgeInsets.only(left: 5),
                ),
              ],
            ),
            height: 40,
          ),
        ),
        Divider(),
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FeedbackPage()));
          },
          child: Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    ImagePath.icFeedback,
                    package: Constant.package,
                    color: Theme.of(context).primaryColorLight,
                    width: 25,
                  ),
                  margin: EdgeInsets.only(left: 15),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      '建议与反馈',
                      style: TextStyle(fontSize: 16),
                    ),
                    margin: EdgeInsets.only(left: 5),
                  ),
//                  margin: EdgeInsets.only(left: 5),
                ),
              ],
            ),
            height: 40,
          ),
        ),
        Divider(),
        InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AboutPage()));
          },
          child: Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: Image.asset(
                    ImagePath.icAbout,
                    package: Constant.package,
                    color: Theme.of(context).primaryColorLight,
                    width: 25,
                  ),
                  margin: EdgeInsets.only(left: 15),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      '关于',
                      style: TextStyle(fontSize: 16),
                    ),
                    margin: EdgeInsets.only(left: 5),
                  ),
//                  margin: EdgeInsets.only(left: 5),
                ),
              ],
            ),
            height: 40,
          ),
        ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WanFlutter'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              ToastUtils.showShort('设置');
            },
          )
        ],
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          _buildHead(context),
          _buildItems(context),
        ],
      ),
    );
  }
}
