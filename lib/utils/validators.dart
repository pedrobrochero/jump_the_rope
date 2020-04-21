bool isNotEmpty (String s) {
  if (s == null) return false;
  if (s.isEmpty) return false;
  return true;
}

bool isInt(String s) {
  if (s == null) return false;
  if (s.isEmpty) return false;
  if (int.tryParse(s) == null) return false;
  return true;

}