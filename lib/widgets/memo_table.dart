import 'package:flutter/material.dart';
import '../models/memo.dart';

class MemoTable extends StatelessWidget {
  final List<Memo> memos;
  final bool isLandscape;
  final void Function(int, Memo) onChanged;
  final void Function(int) onDeleteRow;

  const MemoTable({
    Key? key,
    required this.memos,
    required this.isLandscape,
    required this.onChanged,
    required this.onDeleteRow,
  }) : super(key: key);

  static const double cellWidthPortrait = 140;
  static const double cellWidthLandscape = 200;
  static const double machineCellWidth = 160;

  @override
  Widget build(BuildContext context) {
    final emerald = const Color(0xFF009F6B);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // ← 縦スクロール追加
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Header row
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: emerald),
                color: emerald.withOpacity(0.8),
              ),
              child: Row(
                children: [
                  _HeaderCell('番号', width: isLandscape ? cellWidthLandscape : cellWidthPortrait),
                  _HeaderCell('ジャンル', width: isLandscape ? cellWidthLandscape : cellWidthPortrait),
                  _HeaderCell('曲名', width: isLandscape ? cellWidthLandscape : cellWidthPortrait),
                  _HeaderCell('歌手名', width: isLandscape ? cellWidthLandscape : cellWidthPortrait),
                  if (isLandscape) _HeaderCell('キー', width: cellWidthLandscape),
                  if (isLandscape) _HeaderCell('機種', width: machineCellWidth),
                  _HeaderCell('備考', width: isLandscape ? cellWidthLandscape : cellWidthPortrait),
                  Container(
                    width: 56,
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: const Text(
                      '削除',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Data rows
            ...memos.asMap().entries.map((entry) {
              final index = entry.key;
              final memo = entry.value;
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: emerald),
                ),
                child: Row(
                  children: [
                    _EditableCell(
                      initialValue: memo.number.toString(),
                      width: isLandscape ? cellWidthLandscape : cellWidthPortrait,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final number = int.tryParse(val) ?? memo.number;
                        onChanged(index, memo.copyWith(number: number));
                      },
                    ),
                    _EditableCell(
                      initialValue: memo.genre ?? '',
                      width: isLandscape ? cellWidthLandscape : cellWidthPortrait,
                      onChanged: (val) => onChanged(index, memo.copyWith(genre: val)),
                    ),
                    _EditableCell(
                      initialValue: memo.title ?? '',
                      width: isLandscape ? cellWidthLandscape : cellWidthPortrait,
                      onChanged: (val) => onChanged(index, memo.copyWith(title: val)),
                    ),
                    _EditableCell(
                      initialValue: memo.artist ?? '',
                      width: isLandscape ? cellWidthLandscape : cellWidthPortrait,
                      onChanged: (val) => onChanged(index, memo.copyWith(artist: val)),
                    ),
                    if (isLandscape)
                      _EditableCell(
                        initialValue: memo.key ?? '',
                        width: cellWidthLandscape,
                        onChanged: (val) => onChanged(index, memo.copyWith(key: val)),
                      ),
                    if (isLandscape)
                      _MachineSelector(
                        selected: memo.machine ?? '',
                        width: machineCellWidth,
                        onSelected: (val) => onChanged(index, memo.copyWith(machine: val)),
                      ),
                    _EditableCell(
                      initialValue: memo.notes ?? '',
                      width: isLandscape ? cellWidthLandscape : cellWidthPortrait,
                      onChanged: (val) => onChanged(index, memo.copyWith(notes: val)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      tooltip: '行を削除',
                      onPressed: () => onDeleteRow(index),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final double width;
  const _HeaderCell(this.label, {required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _EditableCell extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final double width;
  final TextInputType keyboardType;

  const _EditableCell({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.width,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<_EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<_EditableCell> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _EditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        maxLines: null,
        style: const TextStyle(fontSize: 18),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _MachineSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final double width;

  const _MachineSelector({
    Key? key,
    required this.selected,
    required this.onSelected,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emerald = const Color(0xFF009F6B);

    return Container(
      width: width,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(border: Border(right: BorderSide(color: emerald))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: selected == 'DAM',
                onChanged: (val) => onSelected(val == true ? 'DAM' : ''),
                activeColor: emerald,
              ),
              const Text('DAM', style: TextStyle(fontSize: 16)),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: selected == 'JOYSOUND',
                onChanged: (val) => onSelected(val == true ? 'JOYSOUND' : ''),
                activeColor: emerald,
              ),
              const Text('JOYSOUND', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
