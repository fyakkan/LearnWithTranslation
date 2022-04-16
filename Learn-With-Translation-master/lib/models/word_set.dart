class WordSet{
  late String _setTitle = "";
  late Map _wordList = {};

  WordSet(String title, Map wordList){
    _setTitle = title;
    _wordList = wordList;
  }

  Map getWordList(){
    return _wordList;
  }

  void setSetTitle(String title){
    _setTitle = title;
  }

  String getSetTitle(){
    return _setTitle;
  }

}