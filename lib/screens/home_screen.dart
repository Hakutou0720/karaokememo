import 'package:flutter/material.dart';
import '../db/memo_database.dart';
import '../models/memo.dart';
import '../widgets/memo_table.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Memo> memos = [];
  List<Memo> filteredMemos = [];
  bool loading = true;
  String genreFilter = '';

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  Future _loadMemos() async {
    final list = await MemoDatabase.instance.readAllMemos();
    setState(() {
      if (list.isEmpty) {
        memos = List.generate(1, (i) => Memo(number: i + 1));
      } else {
        memos = list;
      }
      _applyFilter();
      loading = false;
    });
  }

  void _applyFilter() {
    if (genreFilter.trim().isEmpty) {
      filteredMemos = memos;
    } else {
      filteredMemos = memos.where((memo) {
        final genre = memo.genre ?? '';
        return genre.toLowerCase().contains(genreFilter.toLowerCase());
      }).toList();
    }
  }

  Future _saveAll(List<Memo> updated) async {
    for (var m in updated) {
      if (m.id == null) {
        await MemoDatabase.instance.createMemo(m);
      } else {
        await MemoDatabase.instance.updateMemo(m);
      }
    }
    await _loadMemos();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('保存しました')));
  }

  void _onChanged(int index, Memo updated) {
    // filteredMemosのindexを元のmemosのindexに変換
    final originalIndex =
        memos.indexWhere((m) => m.number == filteredMemos[index].number);
    if (originalIndex != -1) {
      setState(() {
        memos[originalIndex] = updated;
        _applyFilter();
      });
    }
  }

  void _onDeleteRow(int index) async {
    final memoToDelete = filteredMemos[index];
    if (memoToDelete.id != null) {
      await MemoDatabase.instance.deleteMemo(memoToDelete.id!);
    }
    setState(() {
      memos.removeWhere((m) => m.number == memoToDelete.number);
      _applyFilter();
      // 番号の連番再割り当て
      for (int i = 0; i < memos.length; i++) {
        memos[i] = memos[i].copyWith(number: i + 1);
      }
      _applyFilter();
    });
  }

  void _addNewRow() {
    final nextNumber =
        memos.isEmpty ? 1 : memos.map((e) => e.number).reduce((a, b) => a > b ? a : b) + 1;
    setState(() {
      memos.add(Memo(number: nextNumber));
      _applyFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emerald = const Color(0xFF009F6B);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: emerald,
        title: Row(children: [
          Container(
            width: 85,
            height: 85 / 1.41,
            color: Colors.white,
            child: Image.asset(
              'assets/images/music_note.JPG',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          const Text('カラオケ メモ', style: TextStyle(fontSize: 20)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '行追加',
            onPressed: _addNewRow,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '保存',
            onPressed: () async {
              await _saveAll(memos);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear') {
                final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('全削除'),
                          content:
                              const Text('データベース内の全メモを削除します。よろしいですか？'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('キャンセル')),
                            TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('削除')),
                          ],
                        ));
                if (confirm == true) {
                  final db = await MemoDatabase.instance.database;
                  await db.delete('memos');
                  setState(() {
                    memos = List.generate(1, (i) => Memo(number: i + 1));
                    _applyFilter();
                  });
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clear', child: Text('全削除')),
            ],
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Row(
                      children: [
                        Icon(Icons.mic, size: 48, color: emerald),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'T-Camelliaカラオケメモ　ジャンルで絞り込めます。',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ここにジャンル検索バーを追加
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'ジャンルで検索',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        setState(() {
                          genreFilter = val;
                          _applyFilter();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: MemoTable(
                          memos: filteredMemos,
                          isLandscape: isLandscape,
                          onChanged: _onChanged,
                          onDeleteRow: _onDeleteRow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
