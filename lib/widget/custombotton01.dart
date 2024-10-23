import 'package:flutter/material.dart';

class PurpleCustomButton extends StatelessWidget {
  final String text;            // ボタンに表示されるテキスト
  final VoidCallback onPressed; // ボタンクリック時のコールバック関数
  final double? width;          // オプション：ボタンの幅
  final double? height;         // オプション：ボタンの高さ
  final bool isEnabled;         // ボタンが有効かどうか

  const PurpleCustomButton({
    Key? key,
    required this.text,         // 必須：表示するテキスト
    required this.onPressed,    // 必須：押した時のアクション
    this.width =340,           // デフォルトの幅を 200 に設定
    this.height = 55,           // デフォルトの高さを 55 に設定
    this.isEnabled = true,      // デフォルトではボタンは有効
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null, // ボタンが有効な場合のみクリックを許可
      child: Container(
        width: width,   // ボタンの幅
        height: height, // ボタンの高さ
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // ボタンの角を丸める
          gradient: LinearGradient(
            colors: isEnabled
                ? [Color(0xFF7B1FA2), Color(0xFF9C27B0)] // 有効時の紫のグラデーション
                : [Colors.grey.shade400, Colors.grey.shade300], // 無効時のグレー
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // 影の色
                    blurRadius: 10,                      // 影のぼかし
                    offset: Offset(0, 5),               // 影の位置
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            text, // ボタンに表示するテキスト
            style: TextStyle(
              fontFamily: 'FjallaOne',         // フォントスタイル
              fontWeight: FontWeight.bold,     // 太字
              fontSize: 20,                    // テキストサイズ
              color: isEnabled ? Colors.white : Colors.grey.shade600, // 有効時は白、無効時はグレー
            ),
          ),
        ),
      ),
    );
  }
}
