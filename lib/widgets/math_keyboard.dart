import 'package:flutter/material.dart';

class MathKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSolve;
  final VoidCallback onChanged;

  const MathKeyboard({
    super.key,
    required this.controller,
    required this.onSolve,
    required this.onChanged,
  });

  void _insert(String text) {
    final cur = controller.text;
    final sel = controller.selection;
    if (sel.isValid && sel.start >= 0) {
      final newText = cur.replaceRange(sel.start, sel.end, text);
      controller.text = newText;
      controller.selection = TextSelection.collapsed(offset: sel.start + text.length);
    } else {
      controller.text = cur + text;
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
    onChanged();
  }

  void _delete() {
    final cur = controller.text;
    if (cur.isEmpty) return;
    final sel = controller.selection;
    if (sel.isValid && sel.start > 0) {
      if (sel.start == sel.end) {
        final newText = cur.replaceRange(sel.start - 1, sel.start, '');
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: sel.start - 1);
      } else {
        final newText = cur.replaceRange(sel.start, sel.end, '');
        controller.text = newText;
        controller.selection = TextSelection.collapsed(offset: sel.start);
      }
    } else {
      controller.text = cur.substring(0, cur.length - 1);
      controller.selection = TextSelection.collapsed(offset: controller.text.length);
    }
    onChanged();
  }

  void _clear() {
    controller.clear();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF141720),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Color(0xFF282D3D), width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Quick Advanced Mathematical Operators Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSpecialKey('x²', 'x^2'),
                _buildSpecialKey('√x', r'\sqrt{x}'),
                _buildSpecialKey('a/b', r'\frac{a}{b}'),
                _buildSpecialKey('d/dx', r'\frac{d}{dx}'),
                _buildSpecialKey('∫', r'\int '),
                _buildSpecialKey('x', 'x'),
                _buildSpecialKey('y', 'y'),
                _buildSpecialKey('(', '('),
                _buildSpecialKey(')', ')'),
                _buildSpecialKey('sin', r'\sin('),
                _buildSpecialKey('cos', r'\cos('),
                _buildSpecialKey('=', ' = '),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Main 4x5 Keypad Grid
          Column(
            children: [
              _buildKeyRow([
                _buildKey('7', '7'),
                _buildKey('8', '8'),
                _buildKey('9', '9'),
                _buildKey('÷', ' / ', isOp: true),
                _buildActionKey('DEL', Icons.backspace_outlined, _delete, color: const Color(0xFFDC2626)),
              ]),
              _buildKeyRow([
                _buildKey('4', '4'),
                _buildKey('5', '5'),
                _buildKey('6', '6'),
                _buildKey('×', ' * ', isOp: true),
                _buildKey('^', '^', isOp: true),
              ]),
              _buildKeyRow([
                _buildKey('1', '1'),
                _buildKey('2', '2'),
                _buildKey('3', '3'),
                _buildKey('-', ' - ', isOp: true),
                _buildKey('+', ' + ', isOp: true),
              ]),
              _buildKeyRow([
                _buildActionKey('C', null, _clear, color: const Color(0xFF4B5563)),
                _buildKey('0', '0'),
                _buildKey('.', '.'),
                _buildKey('=', ' = ', isOp: true),
                _buildSolveKey(),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: children.map((w) => Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: w,
        ))).toList(),
      ),
    );
  }

  Widget _buildKey(String label, String insertVal, {bool isOp = false}) {
    return InkWell(
      onTap: () => _insert(insertVal),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOp ? const Color(0xFF232938) : const Color(0xFF1B1F2B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isOp ? const Color(0xFF384259) : const Color(0xFF282E3E),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isOp ? 19 : 18,
            fontWeight: isOp ? FontWeight.bold : FontWeight.w500,
            color: isOp ? const Color(0xFF60A5FA) : Colors.white,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, String insertVal) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: () => _insert(insertVal),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF202636),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF333C52), width: 1),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF93C5FD),
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionKey(String label, IconData? icon, VoidCallback onTap, {required Color color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: icon != null
            ? Icon(icon, color: color, size: 18)
            : Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              ),
      ),
    );
  }

  Widget _buildSolveKey() {
    return InkWell(
      onTap: onSolve,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: const Text(
          'حل',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
