# Tailor My Resume

A small personal job-hunt tool: track applications and contacts, and use
Claude to tailor your resume for each job posting.

Rails 8, SQLite, and the Anthropic API, run as a single Docker container.

## Running it

```
docker compose up -d --build    # build and start on port 3000 (needs .env, see Secrets)
docker compose logs -f web      # tail logs
docker compose exec web bin/rails c    # Rails console inside the container
```

The Ruby toolchain lives only inside the image, so `bin/rails` and `bundle`
commands go through `docker compose exec`.

The compose file joins an external Docker network called `proxy-net` so a
reverse proxy can reach the container by name. Create it first
(`docker network create proxy-net`) or remove that block if you don't use one.

## Secrets and data

Neither of these is in git:

- `config/master.key` decrypts `config/credentials.yml.enc`, which holds the
  Anthropic API key.
- `.env` passes that same key to the container as `RAILS_MASTER_KEY`.

To set the API key: `docker compose exec web bin/rails credentials:edit` and
add `anthropic_api_key: sk-ant-...`. Keys come from
[console.anthropic.com](https://console.anthropic.com), billed separately from
a Claude.ai or Claude Code subscription. Setting a spend limit there gives a
hard ceiling.

The SQLite databases and uploaded PDFs live under `storage/`, bind-mounted
into the container so they survive rebuilds. It is gitignored and holds all
real application data, so it is what a backup needs to cover.

## How it works

- **Master Resume** (`/master_resume`): your canonical resume. Import a PDF
  to extract its text, then clean it up into Markdown. This is what gets sent
  to Claude for every tailoring run.
- **Applications** (`/applications`): one per job, with company, role, job
  description or URL, status (saved, applied, phone screen, interview, offer,
  rejected, withdrawn), a follow-up date, contacts, and a running activity log.
  Status changes, notes, new contacts, and tailoring runs are logged
  automatically.
- **Tailored Resume**: from an application's page, "Tailor Resume" sends the
  master resume and job description to Claude, which returns a tailored
  Markdown resume plus a rationale (what was emphasized, reordered, or cut, and
  which keywords were matched). Both are editable afterward. The "Print" link
  plus your browser's Print to PDF exports a submittable file.
  - Two **modes**: `ats` (default) mirrors the posting's terminology and uses
    conventional section headers to get through automated keyword screening;
    `human` writes for a recruiter reading it directly and avoids forcing
    keywords in.

## Things worth knowing

- **Single-user tool with no authentication.** Run it somewhere only you can
  reach.
- **Ruby 3.2.3** is pinned by `.ruby-version` and the Dockerfile's
  `RUBY_VERSION` arg. Brakeman flags it as past end of life, an accepted
  trade-off for a personal tool.
- **Solid Queue, Cache, and Cable, and Kamal** were stripped from the default
  Rails 8 scaffold.

Personal deployment notes for this machine live in `DEPLOY.local.md`, which git ignores.
