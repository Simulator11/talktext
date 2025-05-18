class LanguageDetector {
  /// Improved language detection based on extended Swahili keywords
  String detectLang(String text) {
    final swahiliKeywords = [
      // Greetings and common responses
      'habari', 'asante', 'karibu', 'shikamoo', 'marahaba', 'pole', 'samahani',

      // School & Education
      'shule', 'mwalimu', 'kitabu', 'darasa', 'mtihani',

      // Family & People
      'rafiki', 'baba', 'mama', 'ndugu', 'mtoto', 'kaka', 'dada',

      // Food & Drink
      'chakula', 'maji', 'chai', 'ugali', 'wali', 'nyama', 'mboga',

      // Days and Time
      'leo', 'kesho', 'jana', 'siku', 'asubuhi', 'jioni', 'usiku',

      // Verbs and actions
      'nenda', 'kuja', 'soma', 'andika', 'lala', 'amka', 'cheza', 'kula', 'kunywa',

      // Directions and locations
      'nyumbani', 'shuleni', 'kanisani', 'sokoni', 'hapa', 'kule', 'nje', 'ndani',

      // Basic answers
      'ndiyo', 'hapana', 'kwaheri', 'karibu', 'tafadhali',

      // Emotions
      'furaha', 'hasira', 'uzuni', 'upendo', 'hofu',

      // Technology/Chatting context
      'simu', 'ujumbe', 'andika', 'tuma', 'sauti',

      // Numbers (spoken)
      'moja', 'mbili', 'tatu', 'nne', 'tano', 'sita', 'saba', 'nane', 'tisa', 'kumi',
    ];

    int swahiliHits = 0;
    final lowerText = text.toLowerCase();

    for (var keyword in swahiliKeywords) {
      if (lowerText.contains(keyword)) {
        swahiliHits++;
      }
    }

    return swahiliHits >= 2 ? 'sw' : 'en';
  }
}
