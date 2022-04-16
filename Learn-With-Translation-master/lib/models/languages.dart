class Languages {
  static final languages = <String>[
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Russian',
    'Turkish'
  ];

  static String getLanguageCode(String language) {
    switch (language) {
      case 'English':
        return 'en';
      case 'Turkish':
        return 'tr';
      case 'French':
        return 'fr';
      case 'Italian':
        return 'it';
      case 'Russian':
        return 'ru';
      case 'Spanish':
        return 'es';
      case 'German':
        return 'de';
      default:
        return 'en';
    }
  }
}