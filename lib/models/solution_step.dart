class SolutionStep {
  final int stepNum;
  final String ruleCode;
  final String ruleNameAr;
  final String latex;
  final String explanationAr;
  final String status;

  SolutionStep({
    required this.stepNum,
    required this.ruleCode,
    required this.ruleNameAr,
    required this.latex,
    required this.explanationAr,
    required this.status,
  });

  factory SolutionStep.fromJson(Map<String, dynamic> json) {
    return SolutionStep(
      stepNum: json['step_num'] ?? 1,
      ruleCode: json['rule_code'] ?? 'ALGEBRAIC_STEP',
      ruleNameAr: json['rule_name_ar'] ?? 'خطوة جبرية',
      latex: json['latex'] ?? '',
      explanationAr: json['explanation_ar'] ?? '',
      status: json['status'] ?? 'VERIFIED',
    );
  }
}

class SolveResult {
  final bool success;
  final String equationLatex;
  final List<SolutionStep> steps;
  final String finalAnswer;
  final double computationTimeMs;
  final bool verified;

  SolveResult({
    required this.success,
    required this.equationLatex,
    required this.steps,
    required this.finalAnswer,
    required this.computationTimeMs,
    required this.verified,
  });

  factory SolveResult.fromJson(Map<String, dynamic> json) {
    var stepsList = (json['steps'] as List<dynamic>?)
            ?.map((e) => SolutionStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return SolveResult(
      success: json['success'] ?? false,
      equationLatex: json['equation_latex'] ?? '',
      steps: stepsList,
      finalAnswer: json['final_answer'] ?? '',
      computationTimeMs: (json['computation_time_ms'] as num?)?.toDouble() ?? 0.0,
      verified: json['verified'] ?? true,
    );
  }
}
