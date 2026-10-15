---
name: capati
description: "Capati platform — video translation/dubbing, subtitles, chat AI, podcast, image/video generation, presentations, documents, Excel and music. Uses panel.capati.app API."
metadata: { "openclaw": { "emoji": "🎬", "requires": { "bins": [] }, "install": [] } }
---

# Capati — AI Content Platform

Capati is the Persian AI content platform at **https://panel.capati.app**. This skill lets the assistant act on behalf of the user via Capati's HTTP API.

## Configuration

The gateway needs these env vars (set in `~/.capaticlaw/config.yaml` or gateway env):

```yaml
capati:
  baseUrl: https://panel.capati.app
  apiBaseUrl: https://panel.capati.app # same host; API is on :18101 internally but proxied via nginx
  token: <user JWT or API token> # from panel.capati.app login
```

Or via env:

```
CAPATI_BASE_URL=https://panel.capati.app
CAPATI_API_URL=https://panel.capati.app
CAPATI_TOKEN=<token>
```

If no token is configured, tell the user to log in at https://panel.capati.app and paste their token via `capaticlaw config set capati.token <token>`.

## Capabilities

### 1. Video Translation & Dubbing

Upload a video and get it dubbed/translated. The flow is chunked upload:

```bash
# 1. Init upload session
curl -s -X POST "$CAPATI_API_URL/api/upload/init" \
  -H "Authorization: Bearer $CAPATI_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"filename":"video.mp4","total_chunks":1,"total_size":12345}'

# 2. Upload chunk(s)
curl -s -X POST "$CAPATI_API_URL/api/upload/chunk" \
  -H "Authorization: Bearer $CAPATI_TOKEN" \
  -F "session_id=<id>" -F "chunk_index=0" -F "chunk=@video.mp4"

# 3. Complete (triggers translation job)
curl -s -X POST "$CAPATI_API_URL/api/upload/complete" \
  -H "Authorization: Bearer $CAPATI_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"session_id":"<id>","source_lang":"en","target_lang":"fa","voice":"..."}'

# 4. Poll status
curl -s "$CAPATI_API_URL/api/status/<operation_id>" -H "Authorization: Bearer $CAPATI_TOKEN"

# 5. Download result
curl -s "$CAPATI_API_URL/api/download/<operation_id>/<token>" -H "Authorization: Bearer $CAPATI_TOKEN" -o result.mp4
curl -s "$CAPATI_API_URL/api/download/<operation_id>/<token>/srt" -H "Authorization: Bearer $CAPATI_TOKEN" -o result.srt
```

Also: `POST /api/srt_translate` for SRT-only translation, `GET /api/operations` to list jobs.

### 2. Chat AI (text, image, video, presentation, document, Excel, music)

All via `panel.capati.app` chat API:

```bash
# List conversations
curl -s "$CAPATI_API_URL/api/chat-ai/conversations" -H "Authorization: Bearer $CAPATI_TOKEN"

# Send message (streaming)
curl -s -X POST "$CAPATI_API_URL/api/chat-ai/conversations/<id>/send" \
  -H "Authorization: Bearer $CAPATI_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"content":"سلام، یک پرزنتیشن بساز","model":"best"}'

# Create conversation
curl -s -X POST "$CAPATI_API_URL/api/chat-ai/conversations" \
  -H "Authorization: Bearer $CAPATI_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title":"New chat"}'

# Image batch
curl -s -X POST "$CAPATI_API_URL/api/chat-ai/image-batch" -H "Authorization: Bearer $CAPATI_TOKEN" ...

# Presentation / Document / Excel / Music jobs — poll via:
# GET /api/chat-ai/presentation-jobs/<id>
# GET /api/chat-ai/document-jobs/<id>
# GET /api/chat-ai/excel-jobs/<id>
# GET /api/chat-ai/music-jobs/<id>
```

### 3. Credits & Usage

```bash
curl -s "$CAPATI_API_URL/api/chat-ai/conversations" -H "Authorization: Bearer $CAPATI_TOKEN" # check auth
# Credits are managed in panel.capati.app — show user their balance from the web UI
```

## Agent Instructions

- Always check `CAPATI_TOKEN` is set before calling the API. If missing, ask the user to configure it.
- For video jobs, always poll `/api/status/<id>` until `completed` or `failed`.
- Prefer `target_lang: fa` (Persian) as default for translation unless user says otherwise.
- When user asks in Persian, answer in Persian.
- Never log or expose `CAPATI_TOKEN` in chat output.
- Base URL defaults to `https://panel.capati.app` — do not hardcode `127.0.0.1:18101` (that's internal only).

## Examples

User: "این ویدیو رو به فارسی دوبله کن" → use upload flow with `target_lang: fa`.
User: "برام یک پادکست بساز" → use chat-ai conversation + send.
User: "اعتبارم چقدره؟" → guide to panel.capati.app credits page.
