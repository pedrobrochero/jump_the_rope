class DateTimeUtils { 
  static const comma = ',';
  static const weekDaysLetter = <int, String>{
    1: 'L',
    2: 'M',
    3: 'Mi',
    4: 'J',
    5: 'V',
    6: 'S',
    7: 'D',
  };

  static const weekDaysName = <int, String>{
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };
  static const monthsNames = <int, String>{
    1: 'Enero',
    2: 'Febrero',
    3: 'Marzo',
    4: 'Abril',
    5: 'Mayo',
    6: 'Junio',
    7: 'Julio',
    8: 'Agosto',
    9: 'Septiembre',
    10: 'Octubre',
    11: 'Noviembre',
    12: 'Diciembre',
  };

  static dateToString(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }
  static DateTime stringToDate(String date) {
    if (date == null) return null;
    final comp = date.split('-');
    if (comp.length != 3) return null;
    final year  = int.tryParse(comp[0]);
    final month = int.tryParse(comp[1]);
    final day   = int.tryParse(comp[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day );
  }
}