class QuestionNodeVariable {
  QuestionNodeVariable({this.titleSlug});

  String titleSlug;
}

class QuestionNodeQuery {
  QuestionNodeQuestion question;
}

class QuestionNodeQuestion {
  String questionId;

  String questionTitle;

  String translatedTitle;

  String translatedContent;

  String content;

  String difficulty;

  String stats;

  String status;
}
