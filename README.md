# map_test

## flutter_config

- 環境変数を設定するためのライブラリ
- `flutter_dotenv`と異なり、iOSやAndroidのネイティブ領域でも環境変数を設定できる
- Androidの場合、Gradleのバージョンを8.xにしてしまうと、ビルドができなくなる事象がある
  - そのため、Gradleのバージョンを`7.6.2`にしてある