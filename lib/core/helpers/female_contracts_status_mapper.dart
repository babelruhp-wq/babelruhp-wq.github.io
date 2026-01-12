int? femaleStatusFilterFromKey(String? key) {
  final k = (key ?? '').trim();

  switch (k) {
    case '':
    case 'all_workers':
      return null;

    case 'new':
      return 1;

    case 'under_process':
      return 2;

    case 'rejected': // عندك بتعبر عن canceled
      return 3;

    case 'arrival':
      return 4;

    case 'finished':
      return 5;

    default:
      return null;
  }
}
