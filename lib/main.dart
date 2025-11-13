import 'package:flutter/material.dart';
import 'gacha_items.dart';
import 'notification_service.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  // schedule today's notifications (best-effort)
  await NotificationService.scheduleDailyRandom();
  runApp(SequenceApp());
}

class SequenceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System: Reason MUST YOU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SequenceHome(),
    );
  }
}

class SequenceHome extends StatefulWidget {
  @override
  _SequenceHomeState createState() => _SequenceHomeState();
}

class _SequenceHomeState extends State<SequenceHome> {
  final AudioPlayer _player = AudioPlayer();
  bool spin1Done = false;
  bool spin2Done = false;
  String _glitchLine = '';
  String _reveal = '';
  Timer? _glitchTimer;
  Timer? _typeTimer;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    spin1Done = _prefs?.getBool('spin1Done') ?? false;
    spin2Done = _prefs?.getBool('spin2Done') ?? false;
    setState(() {});
  }

  void _startGlitch(Map<String,String> item) {
    _glitchTimer?.cancel();
    _typeTimer?.cancel();
    const charset = '01▮▯▒▓█░<>/\\|#%@';
    final duration = Duration(milliseconds: 2600);
    final start = DateTime.now();
    _glitchTimer = Timer.periodic(Duration(milliseconds: 50), (t) {
      if (DateTime.now().difference(start) > duration) {
        t.cancel();
        _glitchLine = '';
        _startType(item['title']! + '\n\n' + item['task']! + '\n\n' + item['effect']!);
        // no vibration/sound per preference for notifications; here sound for reveal is okay but optional
        try { Vibration.vibrate(duration: 40); } catch(_) {}
        _playSound();
        return;
      }
      final len = 36;
      final sb = StringBuffer();
      for (var i = 0; i < len; i++) {
        sb.write(charset[Random().nextInt(charset.length)]);
      }
      setState(() { _glitchLine = sb.toString(); });
    });
  }

  void _startType(String text) {
    _reveal = '';
    int i = 0;
    const speed = Duration(milliseconds: 16);
    _typeTimer = Timer.periodic(speed, (t) {
      if (i >= text.length) {
        t.cancel();
        return;
      }
      setState(() { _reveal += text[i]; });
      i++;
    });
  }

  Future<void> _playSound() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('assets/sound/glitch_pop.mp3'));
    } catch (e) {}
  }

  void _onGenerate() {
    final now = DateTime.now();
    final h = now.hour;
    if (h >= 6 && h < 12 && !spin1Done) {
      final raw = gachaItems[Random().nextInt(gachaItems.length)];
      final item = _parseRaw(raw);
      spin1Done = true;
      _prefs?.setBool('spin1Done', true);
      _startGlitch(item);
    } else if (h >= 16 && h < 20 && spin1Done && !spin2Done) {
      final raw = gachaItems[Random().nextInt(gachaItems.length)];
      final item = _parseRaw(raw);
      spin2Done = true;
      _prefs?.setBool('spin2Done', true);
      _startGlitch(item);
    } else {
      _showDialog('Spin hanya tersedia 06:00–12:00 & 16:00–20:00, dan spin kedua hanya setelah menandai quest pagi.');
    }
  }

  Map<String,String> _parseRaw(String raw) {
    // raw stored as: header\nbody\n(event)
    final parts = raw.split('\n');
    final header = parts.length > 0 ? parts[0] : 'Sequence';
    final body = parts.length > 1 ? parts[1] : '';
    final event = parts.length > 2 ? parts[2] : '';
    return {'title': header, 'task': body, 'effect': event};
  }

  void _markComplete() {
    spin1Done = true;
    _prefs?.setBool('spin1Done', true);
    _showDialog('Quest pagi ditandai selesai.');
    setState(() {});
  }

  void _showDialog(String text) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text('[NULL]'),
      content: Text(text),
      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text('OK'))],
    ));
  }

  @override
  void dispose() {
    _glitchTimer?.cancel();
    _typeTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Column(
        children: [
          Padding(padding: EdgeInsets.all(12), child: Align(alignment: Alignment.centerLeft, child: Text('System: Reason MUST YOU', style: TextStyle(color: Colors.grey, fontSize: 18)))),
          Expanded(child: Container(margin: EdgeInsets.all(12), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFF07070B), borderRadius: BorderRadius.circular(12)), child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('[SYSTEM INTERFACE]', style: TextStyle(color: Colors.greenAccent)),
              SizedBox(height:8),
              Text(_glitchLine, style: TextStyle(fontFamily: 'monospace', color: Colors.purpleAccent)),
              SizedBox(height:6),
              Expanded(child: SingleChildScrollView(child: Text(_reveal, style: TextStyle(fontFamily: 'monospace', color: Colors.white70)))),
            ])
          )),
          Padding(padding: EdgeInsets.symmetric(horizontal:12, vertical:8), child: Row(children: [
            Expanded(child: ElevatedButton(onPressed: _onGenerate, child: Text('GENERATE DIRECTIVE'))),
            SizedBox(width:8),
            ElevatedButton(onPressed: _markComplete, child: Text('MARK QUEST COMPLETE')),
          ])),
          SizedBox(height:8)
        ],
      )),
    );
  }
}
