import 'package:equatable/equatable.dart';

class OfficeFemaleStats extends Equatable {
  final int total;        // إجمالي العاملات
  final int underProcess; // تحت الإجراء (مثلاً: غير معتمدة)

  const OfficeFemaleStats({
    required this.total,
    required this.underProcess,
  });

  @override
  List<Object?> get props => [total, underProcess];
}
