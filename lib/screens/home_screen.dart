import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../core/api_service.dart';
import '../models/solution_step.dart';
import '../widgets/step_card.dart';
import '../widgets/math_keyboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _eqController = TextEditingController(
    text: '3x - 9 = 15',
  );
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool _isBackendOnline = false;
  bool _showCustomKeyboard = true;
  String? _errorMessage;
  SolveResult? _result;

  @override
  void initState() {
    super.initState();
    _checkBackendStatus();
    _handleSolve();
  }

  Future<void> _checkBackendStatus() async {
    final online = await _api.checkHealth();
    if (mounted) {
      setState(() => _isBackendOnline = online);
    }
  }

  Future<void> _handleSolve() async {
    final eq = _eqController.text.trim();
    if (eq.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final res = await _api.solveEquation(eq);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _result = res;
          _isBackendOnline = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isBackendOnline = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161922),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF10B981), width: 1),
              ),
              child: const Text(
                'خوارزمي',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'المعلم الرياضي والحل الرمزي الموثق',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _showCustomKeyboard
                ? 'إخفاء الكيبورد الرياضي'
                : 'إظهار الكيبورد الرياضي',
            icon: Icon(
              _showCustomKeyboard
                  ? Icons.keyboard_hide_outlined
                  : Icons.keyboard_outlined,
              color: Colors.white70,
            ),
            onPressed: () =>
                setState(() => _showCustomKeyboard = !_showCustomKeyboard),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isBackendOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isBackendOnline ? 'المحرك نشط' : 'غير متصل',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isBackendOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dynamic Live LaTeX Preview Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D27),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF282D3D),
                          width: 1.2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'المعادلة المدخلة (معاينة حية KaTeX):',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              if (_isLoading)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF12141C),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF32394D),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Math.tex(
                                _eqController.text.isNotEmpty
                                    ? _eqController.text
                                    : r'\dots',
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFF60A5FA),
                                  fontWeight: FontWeight.bold,
                                ),
                                onErrorFallback: (err) => Text(
                                  _eqController.text,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Error Message Banner (if any)
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Color(0xFFEF4444),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFFCA5A5),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Results Section
                    if (_result != null) ...[
                      // Final Answer Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF064E3B,
                          ).withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFF059669),
                            width: 1.4,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF059669),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الناتج النهائي الموثق:',
                                    style: TextStyle(
                                      color: Color(0xFF6EE7B7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Math.tex(
                                      _result!.finalAnswer,
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_result!.computationTimeMs} ms',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Step-by-Step Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'خطوات الحل المنهجي (${_result!.steps.length} خطوات):',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'المحرك الرمزي + شرح تربوي',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Steps List
                      ..._result!.steps.map((s) => StepCard(step: s)),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Dedicated Math Keyboard
            if (_showCustomKeyboard)
              MathKeyboard(
                controller: _eqController,
                onSolve: _handleSolve,
                onChanged: () => setState(() {}),
              ),
          ],
        ),
      ),
    );
  }
}
