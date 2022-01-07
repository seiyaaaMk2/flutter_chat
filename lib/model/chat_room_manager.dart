
class ChatRoomManager
{
  ChatRoomManager._privateConstructor();

  static final ChatRoomManager _instance = ChatRoomManager._privateConstructor();

  factory ChatRoomManager() {
    return _instance;
  }

  String _roomID = "0000";

  String get roomID => _roomID;

  set roomID(String s){
    _roomID = s;
  }

}