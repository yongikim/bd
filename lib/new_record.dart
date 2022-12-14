import 'package:bd/repository/expense_repository.dart';
import 'package:bd/riverpods/expenses_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuple/tuple.dart';

import 'model/expense.dart';

class NewRecord extends ConsumerStatefulWidget {
  const NewRecord({Key? key, this.expenseName = ''}) : super(key: key);

  final String expenseName;

  @override
  NewRecordState createState() => NewRecordState();
}

class NewRecordState extends ConsumerState<NewRecord> {
  bool get _newRecordSubmittable =>
      _newRecordName != '' && _newRecordAmount > 0;
  final _nameFieldController = TextEditingController();
  final _amountFieldController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  List<int> _candidateAmounts = [];
  String _newRecordName = '';
  int _newRecordAmount = 0;
  bool _expenseNameReadOnly = false;

  @override
  void initState() {
    super.initState();

    // 名前フィールドに初期値を設定し、金額フィールドにフォーカスを当てる。
    // 非同期で金額候補を取得する。
    if (widget.expenseName != '') {
      _newRecordName = widget.expenseName;
      _expenseNameReadOnly = true;
      _nameFieldController.text = widget.expenseName;
      _amountFocusNode.requestFocus();
      _fetchCandidateAmounts(widget.expenseName).then(
        (value) => setState(
          () {
            _candidateAmounts = value;
          },
        ),
      );
    }
  }

  void _handleNewRecordNameChange(String input) {
    setState(() {
      _newRecordName = input;
    });
  }

  // 金額入力ハンドラ
  void _handleNewRecordAmountChange(String input) {
    int? amount = int.tryParse(input);
    amount ??= 0;

    setState(() {
      _newRecordAmount = amount!;
    });
  }

  // 名前候補の取得
  Future<List<String>> _getCandidateNames() async {
    if (_expenseNameReadOnly) return [];
    final now = DateTime.now();
    return await ExpenseRepository.expenseNames(now.year, now.month);
  }

  // 金額候補の取得。直近30日間の記録の中から、名前が `name` に一致するものを
  // 取得し、金額順にソートして金額を返す。
  Future<List<int>> _fetchCandidateAmounts(String name) async {
    final expenses = await ExpenseRepository.findByNameInPastDays(name, 30);

    // 重複を削除し、降順にソート
    final amounts = expenses.map((e) => e.amount).toSet().toList();
    amounts.sort((a, b) => b.compareTo(a));

    return amounts;
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

    // 金額候補の選択
    final amounts = await _fetchCandidateAmounts(name);
    setState(() {
      _candidateAmounts = amounts;
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
  Future<void> _handleNewRecordSubmit() async {
    final now = DateTime.now();

    final Expense expense = Expense(
      _newRecordName,
      _newRecordAmount,
      now.year,
      now.month,
      now.day,
    );

    await ExpenseRepository.insert(expense);
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
                readOnly: _expenseNameReadOnly,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  runSpacing: 0.0,
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: _candidateAmounts
                      .map(
                        (amount) => Card(
                          elevation: 2,
                          child: TextButton(
                            onPressed: () {
                              _handleCandidateAmountClick(amount);
                            },
                            // child: Center(
                            child: Text(
                              amount.toString(),
                              style: const TextStyle(color: Colors.black54),
                            ),
                            // ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            // SizedBox(
            //   height: 48,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Row(
            //       children: _candidateAmounts
            //           .map(
            //             (amount) => Card(
            //               elevation: 2,
            //               child: TextButton(
            //                 onPressed: () {
            //                   _handleCandidateAmountClick(amount);
            //                 },
            //                 child: Center(
            //                   child: Text(
            //                     amount.toString(),
            //                     style: const TextStyle(color: Colors.black54),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           )
            //           .toList(),
            //     ),
            //   ),
            // ),
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

                  // 詳細画面の更新
                  final now = DateTime.now();
                  ref.refresh(
                    expensesProvider(
                      Tuple3(
                        now.year,
                        now.month,
                        _newRecordName,
                      ),
                    ),
                  );
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
