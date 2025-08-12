import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memo_app/main.dart';

void main() {
  testWidgets('メモ追加のテスト', (WidgetTester tester) async {
    // アプリを起動
    await tester.pumpWidget(KaraokeMemoApp());

    // 最初はメモが表示されていないことを確認
    expect(find.byType(ListTile), findsNothing);

    // テキスト入力
    await tester.enterText(find.byType(TextField), 'テストメモ');

    // ボタンをタップ
    await tester.tap(find.text('追加'));
    await tester.pump();

    // メモが追加されているか確認
    expect(find.text('テストメモ'), findsOneWidget);
  });
}

class memoApp {
  const memoApp();
}
