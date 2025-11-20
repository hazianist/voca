# Voca

Rails 7.1 + Webpacker 애플리케이션으로, 단어 학습/퀴즈 플로우를 제공합니다.

## 로컬 개발

1. **필수 도구**: Ruby 3.2.3, Node 18+, Yarn, PostgreSQL.
2. 의존성 설치
   ```bash
   bundle install
   yarn install
   ```
3. 데이터베이스 준비
   ```bash
   bin/rails db:setup
   ```
4. 개발 서버
   ```bash
   bin/dev # 또는 bin/rails server
   ```

## Vercel 배포

`vercel.json`, `api/index.rb`, `package.json` 의 `vercel-*` 스크립트가 Rails 앱을 Vercel Functions 위에서 동작하도록 구성합니다.

### 사전 준비

- Vercel CLI (`npm i -g vercel`)
- 프로덕션에서 사용할 PostgreSQL 커넥션 문자열
- `config/master.key` (또는 credentials) 확인

### 필요 환경 변수

| 이름 | 설명 |
| --- | --- |
| `RAILS_MASTER_KEY` | `config/master.key` 내용 |
| `DATABASE_URL` | 프로덕션 PostgreSQL 커넥션 문자열 |

Vercel 시크릿으로 등록:

```bash
vercel secrets add rails_master_key "$(cat config/master.key)"
vercel secrets add database_url "postgres://..."
```

### 배포 절차

```bash
yarn vercel-build                       # 로컬 검증 (assets:precompile)
vercel login                            # 최초 1회
vercel deploy                           # 프리뷰 배포
vercel deploy --prod                    # 프로덕션 배포
```

- `vercel.json` 은 `api/index.rb` 를 Rails 진입점으로 사용하고, `/assets` 와 `/packs` 정적 파일을 CDN에서 직접 서빙하도록 라우팅합니다.
- `package.json` 의 `vercel-build` 스크립트가 `bundle install` 과 `RAILS_ENV=production bundle exec rails assets:precompile` 을 실행해 `public/assets`/`public/packs` 를 생성합니다.
- 로컬에서 Vercel 구성을 재현하려면 `yarn vercel:serve` 로 production 모드 서버를 띄울 수 있습니다.

원하는 경우 `vercel env pull` 명령으로 원격 환경 변수를 `.vercel/env` 로 동기화하여 로컬에서 동일한 설정을 사용할 수 있습니다.
