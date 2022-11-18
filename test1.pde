PlaceHolder target; //<>//
PlaceHolder[] candidates;

PFont font; //文字のフォント

int state = 0; // 状態を表す変数
int startTime=0; // 現在の状態になったときの時刻を保存している変数
float showingDuration = 0.3; // カードの情報を提示している時間（単位は秒）

int count=0;//何回行ったかの回数
int Yes=0;//当たった回数
int No=0;//外れた回数

String clear="Nice!";//当てた時のテキスト
String miss="Dont Mind!";//外れた時のテキスト


void setup() {//始めの設定
  size(500, 400);//画面サイズ
  font = loadFont("MeiryoUI-48.vlw");//フォントの呼び出し
  textFont(font, 32);//フォントのサイズ
  transiteState(0);//次の状態が０
  textSize(30);
}

void draw() {//動きはじめ
  background(255);//背景
  processInState();//結果までの仮定
}

void drawPlace() {//動く場所
  target.draw();//targetの動作
  textAlign(LEFT,LEFT);//テキストは左上に置く
  fill(0);//色は黒
  text(count+"回目",0,0,width,height);//回数の表示
  for (PlaceHolder p : candidates) {//次の候補の位置までpが繰り返し動く
    p.draw();
  }
}

Card selectUnusedCard(boolean[] usedCards) {//使われていないカードから次に使うカードを選択する場合
  int c = int(random(usedCards.length));//ｃにランダムなカード番号の整数を挿入
  while (usedCards[c]) {//ランダムに決めた使われているcに挿入したカードを見つけるため繰り返す
    c = int(random(usedCards.length));
    
  }
  usedCards[c] = true;//ランダムに決めたカードがcの数と一致したらtrue
  return new Card(c/13, c % 13 + 1);//新しくカードを13枚の内から1枚決めるのと、プラス1したカードを戻す
}


void initializePlaceForCards() {//カードの場所を初期値に設定
  boolean[] usedCards = new boolean[52];// 初期値はfalseになるのが規格のはず

  candidates = new PlaceHolder[4];//新しく4枚のカードを設置して、candidatesに挿入
  for (int i=0; i<candidates.length; i++) {//iが0からcandidatesの数になるまで繰り返し
    Card card = selectUnusedCard(usedCards);//カードは使ってないものから選択
    card.open();//カードを表にする
    candidates[i] = new PlaceHolder(card, 60+100*i, height/2+30);//新しくカードを横と縦の大きさが均等になるように置いていく
  }

  Card card = candidates[int(random(4))].card;//ランダムでカードを4枚決める
  target = new PlaceHolder(new Card(card), (width-card.width)/2, 50);//新しくカードを置いていく
  target.card.close();//カードを裏向きにする
}

void keyTyped() {//ボタンを押したとき
  if (state == 0) {//状態が0の時
    transiteState(1);//次の状態が１になる
  }
}

void mouseClicked() {//マウスを押したとき
  if (state == 2) {//もし状態が２のとき
    transiteState(4);//次の状態が４になる
    processInState();//結果から仮定まで
  } else if (state == 3) {//状態が３のとき
    transiteState(1);//次の状態が１になる
  }
}

void processInState() {//結果から仮定まで
  switch(state) {
    
  case 0://ケースが0の時
    if (frameCount % 120 < 60) {//フレーム数を120で割ったあまりが60より小さい時
      textAlign(CENTER, CENTER);//テキストは中心におく
      fill(0);//色は黒
      text("スペースキーを押してスタート！ 10回行ったら終了！ ゆっくりおしてね", 0, 0, width, height);//中心に表示
    }
    break;
    
  case 1:
    drawPlace();//描画場所
    // state1からstate2への遷移は時間で起こる
    if ((millis() - startTime) > showingDuration*1000) {
      transiteState(2);
      count=count+1;//回数を１増やす
    }
    break;
    
  case 2:
    drawPlace();//描画場所
    break;
    
  case 3:
    drawPlace();//描画場所
    break;
    
  case 4:
    for (PlaceHolder p : candidates) {//次の候補の位置までpが繰り返し動く
      if (p.isOver(mouseX, mouseY)) {//もしマウスで、伏せているカードを押したら
        p.card.open();//カードをオープン
        if (target.card.isSame(p.card)) {//もし押したカードと選んだカードの柄が一致していたら
          println(clear);//あなたの勝ち
          transiteState(1);//状態が1になる
          Yes=Yes+1;//当てたら１増やす
        } else {//もし違ったら
          println(miss);//あなたの負け
          transiteState(3);//状態が3になる
          No=No+1;//外れたら1増やす
        }
        break;
      }
    }
    if(count==10){//回数が10回に達したら
      transiteState(5);//状態を5にする
    }
    break;
    
  case 5:
      if(state == 5){
        textAlign(CENTER, CENTER);//テキストは中心におく
         fill(255,0,0);//色は黒
         text("当たった回数 "+ (count-No),250,160);//中心に表示
         fill(0,0,255);
         text("外れた回数 "+ (count-Yes),0,0,width,height);
         
      }
      break;
  }
}


void transiteState(int to) {//引数がtoの状態
  int from = state;//stateをfromと置く

  switch(to) {//toを条件分岐
  case 0://ケースが0の時
    state = 0;//状態を0にする
    startTime = millis();//スタート時間を秒に変換する
    break;
  case 1://ケースが1の時
    initializePlaceForCards();//カードの場所を初期値に設定
    state = 1;//状態を1にする
    startTime = millis();//スタート時間を秒に変換する
    break;
    
  case 2://ケースが2の時
    state = 2;//状態を2にする
    target.card.open();//カードを裏返してオープンさせる
    for (PlaceHolder p : candidates) {//次の候補の位置までpが繰り返し動く
      p.card.close();//カードを閉じる
    }
    startTime = millis();//スタート時間を秒に変換する
    break;
    
  case 3://ケースが3の時
    state = 3;//状態を3にする
    for (PlaceHolder q : candidates) {//次の候補の位置までqが繰り返し動く
      q.card.open();//カードをオープンする
    }
    target.card.open();//選んだカードも含めてオープンする
    startTime = millis();//スタート時間を秒に変換する
    break;
    
  case 4://ケースが4の時
    state = 4;//状態を4にする
    startTime = millis();//スタート時間を秒に変換する
    break;
    
  case 5://ケースが5の時
    state = 5;//状態を5にする
    startTime = millis();//スタート時間を秒に変換する
    break;
    
  default://初期値
    println("I do not know what I should do");//その時私は何をするべきかわからなかった
    break;
  }
}
// カード画像を保存してる変数
PImage frontCardsImage;
PImage backCardImage;

void initializeCards() {
  frontCardsImage = loadImage("cards.jfitz.png");
  backCardImage = loadImage("card_back.png");
}

class Card {
  PImage frontCard; // カードの表面画像
  PImage backCard;  // カードの裏面画像
  int suit; //0：クラブ、1:スペード、2:ハート、3：ダイア
  int rank; // 1〜13
  boolean open; // falseならカードは裏、trueなら表

  int width = 73; // カードの幅
  int height = 98; // カードの高さ

// カードのコピーを作るためのコンストラクタ
  Card(Card original) {
    suit = original.suit;
    rank = original.rank;
    open = original.open;
    backCard = original.backCard;
    frontCard = original.frontCard;
  }

  // s:スーツ、r:ランク
  Card(int s, int r) {
    suit = s;
    rank = r;
    open = false; // カードは最初は裏返し
    if (backCardImage == null) {
      backCardImage = loadImage("card_back.png");
    }
    if (frontCardsImage == null) {
      frontCardsImage = loadImage("cards.jfitz.png");
    }
    backCard = backCardImage;
    frontCard = createImage(width, height, RGB);
    frontCard.copy(frontCardsImage, width*(rank-1), height*suit,
      width, height, 0, 0, width, height);
  }
  int getRank() {
    return rank;
  }
  int getSuit() {
    return suit;
  }
  // カードの状態をひっくり返す
  void flip() {
    open = !open;
  }
  // カードをオープン状態にする
  void open() {
    open = true;
  }
  // カードを裏向きにする
  void close() {
    open = false;
  }
  // カードを表示
  void draw(int x, int y) {
    if (open) {
      image(frontCard, x, y);
    } else {
      image(backCard, x, y);
    }
  }

  // 同じカードかを調べる
  boolean isSame(Card c){
    return suit == c.suit && rank == c.rank;
  }
}
// カードを置く場所を決めるためのクラス

class PlaceHolder{
  Card card; // 保持しているカード
  int x; // 位置のx座標
  int y; // 位置のy座標
  
  PlaceHolder(Card c,int x,int y){
    card = c;
    this.x = x;
    this.y = y;
  }
  
  void draw(){
    noFill();//色を塗らない
    stroke(0);//太さ0 
    rect(x-4,y-4,2*4+card.width,2*4+card.height);//長方形
    card.draw(x,y);
  }
  
  int width(){
    return card.width;
  }
  
  int height(){
    return card.height;
  }
  
  int x(){
    return x;
  }
  
  int y(){
    return y;
  }
  
  // 位置(x,y)に移動させる
  void moveTo(int x1,int y1){
    x = x1;
    y = y1;
  }
  
  // (dx,dy)だけ、位置を移動させる
  void move(int dx,int dy){
    x += dx;
    y += dy;
  }
  
  // 点(x0,y0)がカード上の点かどうかを調べる
  boolean isOver(int x0,int y0){
    return (x <= x0 && x0 <= (x+card.width)) && (y <= y0 && y0 <= (y+card.height));
  }
}

