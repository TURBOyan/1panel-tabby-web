# Tabby Web

把 [Tabby](https://github.com/Eugeny/tabby) 终端搬到浏览器里，支持 SSH / Telnet / Serial 连接，同时充当 Tabby 客户端的配置同步服务。

## 架构

三个容器：

| 容器 | 镜像 | 作用 |
| --- | --- | --- |
| `${CONTAINER_NAME}` | `ghcr.io/eugeny/tabby-web:latest` | Django 后端 + 前端，监听映射出的网页端口 |
| `${CONTAINER_NAME}-gateway` | `ghcr.io/eugeny/tabby-connection-gateway:v0.3.0` | Websocket → TCP 网关，浏览器发起的连接经它转发 |
| `${CONTAINER_NAME}-db` | `mariadb:10.7.1` | 账号与配置存储 |

数据落盘在应用目录下的 `data/db`（数据库）和 `data/app-dist`（Tabby 发行版缓存）。

## 安装前必读：必须配置 OAuth

**Tabby Web 没有本地账号密码，登录完全依赖第三方 OAuth。** 一个提供方都不配的话，打开页面只会显示 "No authentication providers configured" 并无法进入。

需要先到对应平台申请 OAuth 应用，把 **回调地址** 填成：

```
<PANEL_APP_URL>/api/1/auth/social/complete/<provider>/
```

其中 `<provider>` 按登录方式取值：`github`、`gitlab`、`google-oauth2`、`microsoft-graph`、`azuread-tenant-oauth2`、`oidc`。

因此「对外访问地址」（`PANEL_APP_URL`）**必须**填成浏览器实际访问的完整地址（如 `https://tabby.example.com`），否则登录回调会失败。仅填 `IP:端口` 时 OAuth 通常无法工作。

各平台申请入口：

- GitHub — <https://github.com/settings/developers>
- GitLab — <https://gitlab.com/-/profile/applications>
- Google — <https://console.cloud.google.com/apis/credentials>
- Microsoft — <https://portal.azure.com/#blade/Microsoft_AAD_RegisteredApps>

## 网关令牌

「连接网关令牌」是自建的网页与网关之间的共享密钥，**自行随便生成一串随机字符**即可，不需要去任何平台申请。填入后在 Tabby Web 的 Settings 里填同样的值。

## 登录后配置 SSH

1. 用 OAuth 登录
2. 打开 Settings，填写 Connection Gateway：
   - 网关地址：`ws://<你的IP>:<连接网关端口>`（若前面挂了 HTTPS 反代并转发该端口，用 `wss://`）
   - 令牌：安装时填的「连接网关令牌」
3. 之后新建 SSH 连接即可

## 已知问题

- **网关镜像必须锁 `v0.3.0`**。官方 `latest` / `master` tag 在当前构建下是坏的（Python 3.7 配 websockets 16.1.1，启动即 `ModuleNotFoundError: No module named 'importlib.metadata'`）。`v0.3.0` 实测正常。
- 上游项目作者已说明暂无时间维护 tabby-web，功能可用但更新缓慢。
- 官方 docker-compose 示例里的端口映射实际不生效（gunicorn 默认绑 `127.0.0.1:8000`），本应用通过 `GUNICORN_CMD_ARGS` 显式绑定 `0.0.0.0:80` 修正。
