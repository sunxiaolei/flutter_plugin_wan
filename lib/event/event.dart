import 'package:event_bus/event_bus.dart';
import 'package:flutter_plugin_wan/model/dto/login_dto.dart';

EventBus bus = EventBus();

class ThemeEvent {
  int theme;
  bool darkTheme;

  ThemeEvent(this.theme, this.darkTheme);
}

class LoginEvent {
  LoginDTO data;

  LoginEvent({this.data});
}

class EditTodoEvent {
  int type;

  EditTodoEvent(this.type);
}

class FavoriteEvent {
  FavoriteEvent();
}
