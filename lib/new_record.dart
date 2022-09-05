import 'package:bd/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'model/expense.dart';

class NewRecord extends StatefulWidget {
  const NewRecord({
    Key? key,
  }) : super(key: key);

  @override
  State<NewRecord> createState() => _NewRecord();
}

class _NewRecord extends State<NewRecord> {
  bool get _newRecordSubmittable =>
      _newRecordName != '' && _newRecordAmount > 0;
  final _nameFieldController = TextEditingController();
  final _amountFieldController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  List<int> _candidateAmounts = [];
  String _newRecordName = '';
  int _newRecordAmount = 0;

  @override
  void initState() {
    super.initState();
  }

  void _handleNewRecordNameChange(String input) {
    setState(() {
      _newRecordName = input;
    });
  }

  // 金額入力ハンドラ
  void _handleNewRecordAmountChange(String input) {
    int? amount = int.tryParse(input);
    if (amount == null) {}

    setState(() {
      _newRecordAmount = amount!;
    });
  }

  // TODO: Get from Real Database
  Future<List<String>> _getCandidateNames() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ['スタバ', 'タリーズ', 'ドトール'];
  }

  // 名前候補の選択
  Future<void> _handleCandidateNameClick(String name) async {
    // FIXME: 名前候補を再選択したとき金額候補の変更を反映するために一度フォーカスを外す
    // Provider系を使う必要がある？
    FocusManager.instance.primaryFocus?.unfocus();

    // 名前の設定
    setState(() {
      _newRecordName = name;
    });
    _nameFieldController.text = name;

    // 金額候補の取得
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      if (name == 'スタバ') {
        _candidateAmounts = [100, 200, 300];
      } else if (name == 'タリーズ') {
        _candidateAmounts = [10, 20, 30];
      } else if (name == 'ドトール') {
        _candidateAmounts = [1000, 2000, 3000];
      }
    });

    // 金額フォームにフォーカスを当てる
    _amountFocusNode.requestFocus();
  }

  // 金額候補の選択
  void _handleCandidateAmountClick(int amount) {
    // 金額の設定
    setState(() {
      _newRecordAmount = amount;
    });
    _amountFieldController.text = amount.toString();
  }

  // 記録作成ハンドラ
  // TODO: Implement
  Future<void> _handleNewRecordSubmit() async {
    DBProvider db = DBProvider();
    await db.init();

    final now = DateTime.now();

    final Expense expense = Expense(
      _newRecordName,
      _newRecordAmount,
      now.year,
      now.month,
      now.day,
    );

    await db.insertExpense(expense);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        margin: const EdgeInsets.only(top: 64),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // キャンセルボタン
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.cancel,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            // 名前フォーム
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _nameFieldController,
                enabled: true,
                autofocus: true,
                onChanged: _handleNewRecordNameChange,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
            ),
            // 名前候補
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FutureBuilder(
                  future: _getCandidateNames(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<String>> snapshot) {
                    if (snapshot.hasData) {
                      return Row(
                        children: snapshot.data!
                            .map(
                              (name) => Card(
                                elevation: 2,
                                child: TextButton(
                                  onPressed: () async {
                                    await _handleCandidateNameClick(name);
                                  },
                                  child: Center(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                          color: Colors.black54),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            // 金額フォーム
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _amountFieldController,
                focusNode: _amountFocusNode,
                enabled: true,
                autofocus: false,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: _handleNewRecordAmountChange,
                decoration: const InputDecoration(hintText: 'Amount'),
              ),
            ),
            // 金額候補
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _candidateAmounts
                      .map(
                        (amount) => Card(
                          elevation: 2,
                          child: TextButton(
                            onPressed: () {
                              _handleCandidateAmountClick(amount);
                            },
                            child: Center(
                              child: Text(
                                amount.toString(),
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const Spacer(),
            // 登録ボタン
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 16,
                right: 16,
                bottom: 32,
              ),
              child: ElevatedButton(
                onPressed: () async {
                  if (!_newRecordSubmittable) return;
                  await _handleNewRecordSubmit();
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Icon(
                  Icons.done,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
