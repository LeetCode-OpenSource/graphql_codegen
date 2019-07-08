class AddQuestionToNewFavoriteVariable {
  AddQuestionToNewFavoriteVariable(
      {this.name, this.isPublicFavorite, this.questionId});

  String name;
  bool isPublicFavorite;
  String questionId;
}

class AddQuestionToNewFavoriteMutation {
  AddQuestionToNewFavoriteAddQuestionToNewFavorite addQuestionToNewFavorite;
}

class AddQuestionToNewFavoriteAddQuestionToNewFavorite {
  bool ok;

  String error;

  String name;

  bool isPublicFavorite;

  String favoriteIdHash;

  String questionId;
}
