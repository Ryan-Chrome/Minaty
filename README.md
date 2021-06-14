## Minaty

### 概要

企業内でのコミュニケーションツール

#### 一般ユーザー機能
- ダッシュボード機能
  - ユーザーの詳細を表示
  - カレンダーに勤怠情報を色付けにより反映
  - 登録したスケジュールの合計、月間、週間データをグラフ表示
  - 直近のミーティングルーム情報表示
- チャット機能
  - 送信先設定からリアルタイムチャット
  - 送信先は複数人選択可能
  - ユーザー詳細モーダルから1対1のチャット可能
- ミーティングルーム機能
  - SkywayAPIを使用したビデオ通信
  - 通話中の音声、映像ミュート可能
  - 通話中の音声、映像変更可能
  - ミーティングルーム内でのリアルタイムチャット
  - ルーム作成時、エントリーさせたユーザーにメッセージ送信
    - 送信メッセージからスケジュール作成可能
    - ルームへのリンク添付
  - ルーム内から任意のユーザーへメッセージ送信可能
  - ルーム内からエントリー追加可能
  - ルーム外からのメッセージ受信可能
- スケジュール機能
  - スケジュール登録、編集、削除
  - 登録スケジュール、グラフ表示
  - ユーザー詳細モーダルから他人のスケジュール確認可能
- コンタクトグループ機能
  - 任意のユーザーをグループにまとめることが可能
  - 作成したグループは、メッセージ送信先追加フォームなどの選択欄で使用可能
- 勤怠機能
  - 出勤退勤打刻
  - 有給休暇登録
  - ユーザー詳細モーダルから他人の勤怠状況確認可能

#### 管理者機能
- ユーザー管理機能
  - ユーザー一覧からへのアクセス可能
  - 全てのユーザーのダッシュボード閲覧可能
  - ユーザー新規作成
  - 全ユーザーの編集、削除
- 勤怠管理
  - 全ユーザーの勤怠データをCSVファイル出力可能
  - 出勤時間、退勤時間、有給休暇情報閲覧可能
- 部署管理
  - 部署登録、編集、削除可能

#### 環境等
```
Ruby : 2.6.0
Rails: 6.0.3
テスト: Rspec

Docker
CircleCI
``` 
