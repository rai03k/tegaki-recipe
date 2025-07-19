/// アプリ内で使用する文字列定数を管理するクラス
class AppStrings {
  // アプリ情報
  static const String appTitle = 'Tegaki Recipe';
  static const String appName = '手書きレシピ';
  
  // 画面タイトル
  static const String homeTitle = 'ホーム';
  static const String createRecipeBook = 'レシピ本作成';
  static const String recipeBookList = 'レシピ本一覧';
  static const String tableOfContents = '目次';
  static const String createRecipe = 'レシピ作成';
  static const String selectIngredients = '材料選択';
  static const String recipeDetails = 'レシピ詳細';
  
  // フォーム関連
  static const String recipeBookTitle = 'レシピ本タイトル';
  static const String recipeTitle = '料理名';
  static const String cookingTime = '所要時間';
  static const String memo = 'メモ';
  static const String ingredients = '材料';
  static const String instructions = '作り方';
  static const String referenceUrl = '参考URL';
  
  // プレースホルダー
  static const String enterRecipeBookTitle = 'レシピ本のタイトルを入力';
  static const String enterRecipeTitle = '料理名を入力してください';
  static const String enterCookingTime = '調理時間を入力';
  static const String enterMemo = 'メモを入力してください';
  static const String enterInstructions = '作り方を入力してください';
  static const String enterReferenceUrl = '参考URLを入力してください';
  
  // ボタンテキスト
  static const String create = '作成';
  static const String save = '保存';
  static const String cancel = 'キャンセル';
  static const String edit = '編集';
  static const String delete = '削除';
  static const String back = '戻る';
  static const String next = '次へ';
  static const String done = '完了';
  static const String addIngredient = '＋材料を選択';
  
  // 画像関連
  static const String selectCoverImage = '表紙画像を選択';
  static const String selectRecipeImage = '料理画像を選択';
  static const String selectImage = '画像を選択';
  static const String takePhoto = 'カメラで撮影';
  static const String selectFromGallery = 'ギャラリーから選択';
  static const String cropImage = '画像をトリミング';
  
  // 空状態メッセージ
  static const String noRecipeBooksYet = 'レシピ本がまだないよ';
  static const String createRecipeBookGuide = '右下のボタンから\nレシピ本を作ってみよう！';
  static const String noRecipesYet = 'レシピがまだありません';
  static const String createRecipeGuide = '右下のボタンから\nレシピを作ってみよう！';
  static const String noIngredientsYet = '材料が追加されていません';
  
  // 成功メッセージ
  static const String recipeBookCreated = 'レシピ本を作成しました';
  static const String recipeCreated = 'レシピを作成しました';
  static const String recipeSaved = 'レシピを保存しました';
  static const String recipeBookSaved = 'レシピ本を保存しました';
  
  // エラーメッセージ
  static const String errorOccurred = 'エラーが発生しました';
  static const String titleRequired = 'タイトルを入力してください';
  static const String recipeNameRequired = '料理名を入力してください';
  static const String imageLoadError = '画像の読み込みに失敗しました';
  static const String databaseError = 'データベースエラーが発生しました';
  static const String networkError = 'ネットワークエラーが発生しました';
  static const String unknownError = '不明なエラーが発生しました';
  
  // 確認メッセージ
  static const String confirmDelete = '削除しますか？';
  static const String confirmDeleteRecipeBook = 'このレシピ本を削除しますか？';
  static const String confirmDeleteRecipe = 'このレシピを削除しますか？';
  static const String confirmDiscardChanges = '変更を破棄しますか？';
  
  // 目次ページ関連
  static const String tableOfContentsSubtitle = '料理名をタップでそのレシピに移動できるよ';
  static const String pageFormat = 'ページ';
  
  // 材料関連
  static const String ingredientName = '材料名';
  static const String amount = '分量';
  static const String searchIngredients = '材料を検索';
  
  // その他
  static const String loading = '読み込み中...';
  static const String retry = '再試行';
  static const String close = '閉じる';
  static const String ok = 'OK';
  static const String yes = 'はい';
  static const String no = 'いいえ';
}