# ssh-tunnel

`autossh`をDockerコンテナ化した、汎用SSHトンネルクライアントです。1つの設定で **ローカルフォワード(`-L`)・リモートフォワード(`-R`)・ダイナミックフォワード/SOCKSプロキシ(`-D`)** を組み合わせて張ることができます。

`ssh-remote-forward`(このコンテナ自身が踏み台sshdにもなる構成)とは異なり、こちらは**踏み台へ接続するクライアント専用**で、コンテナ内にsshdは動いていません。

## 仕組み

`entrypoint.sh`が環境変数からトンネル指定を組み立て、単一の`autossh`プロセスとして起動します。

```
LOCAL_TUNNELS  -> -L ローカルポート:転送先ホスト:転送先ポート (複数可、カンマ区切り)
REMOTE_TUNNELS -> -R リモートポート:転送先ホスト:転送先ポート (複数可、カンマ区切り)
DYNAMIC_PORT   -> -D 0.0.0.0:ポート (SOCKSプロキシ)
```

いずれも未設定なら該当オプションは付与されません。設定した組み合わせすべてを1本のSSHコネクションで維持します。

## セットアップ

### 1. `.env` を作成

```bash
cp .env.example .env
```

| 変数名 | 説明 |
|---|---|
| `SSH_USER` / `SSH_HOST` / `SSH_PORT` | 接続先の踏み台サーバー情報 |
| `IDENTITY_FILE` | 踏み台サーバーへ接続する秘密鍵のファイル名(`ssh_key/`内に配置) |
| `LOCAL_TUNNELS` | ローカルフォワード。`8080:internal-host:80`形式、複数はカンマ区切り |
| `REMOTE_TUNNELS` | リモートフォワード。`19000:localhost:8050`形式、複数はカンマ区切り |
| `DYNAMIC_PORT` | SOCKSプロキシとして使うローカルポート番号 |

使わない種類のトンネルは`.env`でコメントアウトしたままにしておけばOKです。

### 2. `ssh_key/` フォルダを用意

```
ssh_key/
├── ${IDENTITY_FILE}   # 踏み台サーバーへ接続するための秘密鍵
└── known_hosts        # 踏み台サーバーのホストキー
```

`known_hosts`は`StrictHostKeyChecking=yes`のため必須です。

```bash
ssh-keyscan -p ${SSH_PORT} ${SSH_HOST} > ssh_key/known_hosts
```

### 3. `DYNAMIC_PORT`(SOCKSプロキシ)を使う場合

ホストからアクセスできるように、`docker-compose.yml`の`ports`セクションのコメントを外してください。

```yaml
    ports:
      - "${DYNAMIC_PORT}:${DYNAMIC_PORT}"
```

`LOCAL_TUNNELS`/`REMOTE_TUNNELS`のみを使う場合は不要です。

### 4. 起動

```bash
docker compose up -d --build
```

## 再接続について

`autossh`は`ServerAliveInterval=30` / `ServerAliveCountMax=3`のキープアライブで接続断を検知しつつ、`ExitOnForwardFailure=yes`により**フォワードの確立に失敗した時点でssh側から接続を切って再試行**します。これにより、ネットワーク瞬断後にリモート側で古いセッションのポートが一時的に塞がっていても、`autossh`が繰り返し再接続を試みることで自己修復します。

複数のトンネルを1つの`.env`に混在させている場合、いずれか1本のフォワードが失敗すると**そのタイミングで全トンネルが一旦再接続されます**(1本だけを維持したまま切り離すことはできません)。長時間の片肺運転より確実な自己修復を優先した設定です。
