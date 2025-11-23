import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestroSingleVender/cubit/auth/authCubit.dart';
import 'package:erestroSingleVender/data/model/chatModel.dart';
import 'package:erestroSingleVender/ui/styles/design.dart';
import 'package:erestroSingleVender/utils/api.dart';
import 'package:erestroSingleVender/utils/constants.dart';
import 'package:erestroSingleVender/utils/labelKeys.dart';
import 'package:erestroSingleVender/utils/string.dart';
import 'package:erestroSingleVender/ui/screen/settings/no_internet_screen.dart';
import 'package:erestroSingleVender/utils/apiBodyParameterLabels.dart';
import 'package:erestroSingleVender/utils/internetConnectivity.dart';
import 'package:erestroSingleVender/utils/uiUtils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ChatScreen extends StatefulWidget {
  final String? id, status;

  const ChatScreen({Key? key, this.id, this.status}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

StreamController<String>? chatScreenstreamdata;

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgController = TextEditingController();
  List<File> files = [];
  List<ChatModel> chatList = [];
  late Map<String?, String> downloadlist;
  String _filePath = "";
  double? width, height;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  final ScrollController _scrollController = ScrollController();
  Future<List<Directory>?>? _externalStorageDirectories;

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    _externalStorageDirectories =
        getExternalStorageDirectories(type: StorageDirectory.downloads);
    downloadlist = <String?, String>{};

    FlutterDownloader.registerCallback(downloadCallback);
    setupChannel();

    getMsg();
  }

  @override
  void dispose() {
    msgController.dispose();
    _connectivitySubscription.cancel();

    if (chatScreenstreamdata != null) chatScreenstreamdata!.sink.close();

    super.dispose();
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : Scaffold(
              appBar: DesignConfig.appBar(
                  context,
                  width!,
                  UiUtils.getTranslatedLabel(context, chatLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                decoration: DesignConfig.boxDecorationContainerHalf(
                    Theme.of(context).colorScheme.onSurface),
                width: width,
                child: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                  child: Column(
                    children: <Widget>[buildListMessage(), msgRow()],
                  ),
                ),
              ),
            ),
    );
  }

  void setupChannel() {
    chatScreenstreamdata = StreamController<String>();
    chatScreenstreamdata!.stream.listen((response) {
      setState(() {
        final res = json.decode(response);
        ChatModel message;

        message = ChatModel.fromJson(res["data"]);

        chatList.insert(0, message);
        files.clear();
      });
    });
  }

  void insertItem(String response) {
    if (chatScreenstreamdata != null) chatScreenstreamdata!.sink.add(response);
    _scrollController.animateTo(0.0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  Widget buildListMessage() {
    return Flexible(
      child: ListView.builder(
        padding: EdgeInsetsDirectional.all(10.0),
        itemBuilder: (context, index) => msgItem(index, chatList[index]),
        itemCount: chatList.length,
        reverse: true,
        controller: _scrollController,
      ),
    );
  }

  Widget msgItem(int index, ChatModel message) {
    if (message.userId == context.read<AuthCubit>().getId()) {
      //Own message
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Container(),
          ),
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
        ],
      );
    } else {
      //Other's message
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: MsgContent(index, message),
          ),
          Flexible(
            flex: 1,
            child: Container(),
          ),
        ],
      );
    }
  }

  Widget MsgContent(int index, ChatModel message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: message.userId == context.read<AuthCubit>().getId()
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        message.userId == context.read<AuthCubit>().getId()
            ? Container()
            : Padding(
                padding: const EdgeInsetsDirectional.only(top: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5.0),
                      child: Text(message.name!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontSize: 12)),
                    )
                  ],
                ),
              ),
        ListView.builder(
            itemBuilder: (context, index) {
              return attachItem(message.attachments!, index, message);
            },
            itemCount: message.attachments!.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true),
        message.message != null && message.message!.isNotEmpty
            ? Card(
                elevation: 0.0,
                color: message.userId == context.read<AuthCubit>().getId()
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onPrimary,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  child: Column(
                    crossAxisAlignment:
                        message.userId == context.read<AuthCubit>().getId()
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("${message.message}",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12)),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 5),
                        child: Text(message.dateCreated!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 9)),
                      ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  void _requestDownload(
      String? url, String? mid, AsyncSnapshot snapshot) async {
    bool checkpermission = await checkPermission(snapshot);
    if (checkpermission) {
      if (Platform.isIOS) {
        Directory target = await getApplicationDocumentsDirectory();
        _filePath = target.path.toString();
      } else {
        if (snapshot.hasData) {
          _filePath = snapshot.data!.map((Directory d) => d.path).join(', ');

          print("dir path****$_filePath");
        }
      }

      String fileName = url!.substring(url.lastIndexOf("/") + 1);
      File file = File("$_filePath/$fileName");
      bool hasExisted = await file.exists();

      if (downloadlist.containsKey(mid)) {
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
            query:
                "SELECT status FROM task WHERE task_id=${downloadlist[mid]}");

        if (tasks == 4 || tasks == 5) downloadlist.remove(mid);
      }

      if (hasExisted) {
        await OpenFile.open("$_filePath/$fileName");
      } else if (downloadlist.containsKey(mid)) {
        UiUtils.setSnackBar(StringsRes.downloading, context, false, type: "1");
      } else {
        UiUtils.setSnackBar(StringsRes.downloading, context, false, type: "1");
        final taskid = await FlutterDownloader.enqueue(
            url: url,
            savedDir: _filePath,
            headers: {"auth": "test_for_sql_encoding"},
            showNotification: true,
            openFileFromNotification: true);

        setState(() {
          downloadlist[mid] = taskid.toString();
        });
      }
    }
  }

  Future<bool> checkPermission(AsyncSnapshot snapshot) async {
    var status = await Permission.storage.status;

    if (status != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();

      if (statuses[Permission.storage] == PermissionStatus.granted) {
        fileDirectoryPrepare(snapshot);
        return true;
      }
    } else {
      fileDirectoryPrepare(snapshot);
      return true;
    }
    return false;
  }

  Future<void> fileDirectoryPrepare(AsyncSnapshot snapshot) async {
    if (Platform.isIOS) {
      Directory target = await getApplicationDocumentsDirectory();
      _filePath = target.path.toString();
    } else {
      if (snapshot.hasData) {
        _filePath = snapshot.data!.map((Directory d) => d.path).join(', ');
      }
    }
  }

  _imgFromGallery() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      files = result.paths.map((path) => File(path!)).toList();
      if (mounted) setState(() {});
    } else {
      // User canceled the picker
    }
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      msgController.text = "";
    });
    var request = http.MultipartRequest("POST", Uri.parse(Api.sendMessageUrl));
    request.headers.addAll(Api.getHeaders());

    request.fields[ticketIdKey] = widget.id!;
    request.fields[userTypeKey] = userKey;
    request.fields[messageKey] = message;

    for (int i = 0; i < files.length; i++) {
      final mimeType = lookupMimeType(files[i].path);

      var extension = mimeType!.split("/");
      var pic = await http.MultipartFile.fromPath(
        attachmentsKey,
        files[i].path,
        contentType: MediaType('image', extension[1]),
      );
      request.files.add(pic);
    }

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    var getdata = json.decode(responseString);
    bool error = getdata[errorKey];
    if (!error) {
      insertItem(responseString);
    }
  }

  Future<void> getMsg() async {
    try {
      var data = {
        ticketIdKey: widget.id,
      };

      Response response = await post(Uri.parse(Api.getMessagesUrl),
              body: data, headers: Api.getHeaders())
          .timeout(const Duration(seconds: 50));

      if (response.statusCode == 200) {
        var getdata = json.decode(response.body);

        bool error = getdata[errorKey];
        String? msg = getdata[messageKey];

        if (!error) {
          var data = getdata["data"];
          chatList =
              (data as List).map((data) => ChatModel.fromJson(data)).toList();
        } else {
          if (msg != "Ticket Message(s) does not exist")
            UiUtils.setSnackBar(msg!, context, false, type: "2");
        }
        if (mounted) setState(() {});
      }
    } on TimeoutException catch (_) {
      UiUtils.setSnackBar(StringsRes.somethingMsg, context, false, type: "2");
    }
  }

  msgRow() {
    return widget.status != "4"
        ? Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsetsDirectional.all(5.0),
              width: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      _imgFromGallery();
                    },
                    child: Container(
                      padding: EdgeInsetsDirectional.all(5.0),
                      decoration: DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.secondary, 100),
                      child: Icon(
                        Icons.attach_file,
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 30,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.surface, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: msgController,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.76)),
                              maxLines: null,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsetsDirectional.only(
                                      start: width! / 20.0),
                                  labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.76)),
                                  hintText: UiUtils.getTranslatedLabel(
                                      context, writeMessageLabel),
                                  hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary
                                          .withValues(alpha: 0.76)),
                                  border: InputBorder.none),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (msgController.text.trim().isNotEmpty ||
                                  files.isNotEmpty) {
                                sendMessage(msgController.text.trim());
                              }
                            },
                            child: Container(
                              padding: EdgeInsetsDirectional.all(10.0),
                              decoration: DesignConfig.boxDecorationContainer(
                                  Theme.of(context).colorScheme.secondary, 4),
                              child: Icon(
                                Icons.send,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget attachItem(List<Attachments> attach, int index, ChatModel message) {
    String? file = attach[index].media;
    String? type = attach[index].type;
    String icon;
    if (type == "video") {
      icon = "assets/images/video.png";
    } else if (type == "document") {
      icon = "assets/images/doc.png";
    } else if (type == "spreadsheet") {
      icon = "assets/images/sheet.png";
    } else {
      icon = "assets/images/zip.png";
    }
    return FutureBuilder<List<Directory>?>(
        future: _externalStorageDirectories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return file == null
              ? Container()
              : Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    Card(
                      elevation: 0.0,
                      color: message.userId == context.read<AuthCubit>().getId()
                          ? Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.1)
                          : Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.20),
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: message.userId ==
                                  context.read<AuthCubit>().getId()
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                _requestDownload(
                                    attach[index].media, message.id, snapshot);
                              },
                              child: type == "image"
                                  ? Image.network(file,
                                      width: 250,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                  DesignConfig.setPngPath(
                                                      'placeholder_square'),
                                                  height: 150,
                                                  width: 150))
                                  : Image.asset(
                                      icon,
                                      width: 100,
                                      height: 100,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(message.dateCreated!,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontSize: 9)),
                      ),
                    ),
                  ],
                );
        });
  }
}
