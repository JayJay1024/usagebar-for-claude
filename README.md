# UsageBar

English | [简体中文](README.zh-CN.md)

Shows your Claude plan usage in the macOS menu bar: the **current session** (5-hour window) and **this week**, each with its percentage used and reset time. These are the numbers from Claude's usage settings page.

```
◔ 11% · 71%
├─ Current session  11% used
│  █░░░░░░░░░
│  Resets 04:40 (in 1h 59m)
├─ This week  71% used
│  ███████░░░
│  Resets Sat 15:00 (in 3d 12h)
└─ Updated 02:40 · Refresh · Open claude.ai usage page
```

The menu bar text turns orange at 75% and red at 90%.

> [!IMPORTANT]
> UsageBar is an **unofficial** community project. It is not affiliated with, endorsed by, or supported by Anthropic. It relies on an undocumented API that may change or stop working at any time.

## Requirements

- macOS
- [SwiftBar](https://github.com/swiftbar/SwiftBar) (recommended) or [xbar](https://xbarapp.com)
- [Claude Code](https://docs.claude.com/en/docs/claude-code), signed in with your Claude account (run `claude` once)
- `jq` (included with macOS 15 and later; on older versions run `brew install jq`)

## Installation

```sh
brew install --cask swiftbar
git clone https://github.com/JayJay1024/usagebar-for-claude.git
```

Open SwiftBar and choose a plugin folder. Then symlink the plugin into it:

```sh
ln -s "$PWD/usagebar-for-claude/plugin/usagebar.5m.sh" "<your SwiftBar plugin folder>/"
```

With a symlink, `git pull` updates the plugin.

### Refresh interval

The interval is part of the file name: `usagebar.5m.sh` refreshes every 5 minutes. To change it, rename the symlink, for example to `usagebar.1m.sh` or `usagebar.15m.sh`. Please don't go below 1 minute, so the API isn't hit too often.

## How it works

1. Reads the Claude Code OAuth credentials from the macOS Keychain item `Claude Code-credentials`.
2. Calls `GET https://api.anthropic.com/api/oauth/usage`, the same data shown on Claude's usage page.
3. Prints the result in SwiftBar's menu format.

## Security

UsageBar handles a token that grants access to your Claude account. It follows these rules:

- **Read-only.** It never writes to the Keychain.
- **Never refreshes the token.** Refresh tokens rotate, so refreshing from here could sign Claude Code out. If the token has expired, UsageBar asks you to run `claude`, which refreshes it.
- **Only talks to `api.anthropic.com`.** No analytics, telemetry, or third-party services.
- **Never stored or logged.** The token stays in memory and is passed to `curl` through stdin, so it doesn't show up in the process list.

The whole plugin is a single shell script. Please read it before installing: [`plugin/usagebar.5m.sh`](plugin/usagebar.5m.sh).

## Troubleshooting

| Message | What to do |
| --- | --- |
| Claude Code credentials not found | Install Claude Code and sign in by running `claude`. |
| Claude token expired / rejected | Run `claude` once. It refreshes the token, and UsageBar picks it up on the next refresh. |
| jq not found | `brew install jq`, or set `USAGEBAR_JQ` to the path of your jq. |
| Unexpected response / HTTP error | The undocumented API may have changed. Check for an update or open an issue. |

## Configuration

Optional environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `USAGEBAR_KEYCHAIN_SERVICE` | `Claude Code-credentials` | Keychain item to read |
| `USAGEBAR_JQ` | auto-detected | Path to `jq` |

## Development

```sh
./tests/run.sh
```

The tests render the JSON fixtures in `tests/fixtures/` offline, without touching the Keychain or the network. Set `USAGEBAR_FIXTURE` and `USAGEBAR_NOW` to do the same by hand.

### Contributing

- Make changes on a branch and open a pull request. Don't push directly to `main`.
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/), for example `feat: …`, `fix: …`, `docs: …`.
- The docs are kept in English and Chinese. Update both `README.md` and `README.zh-CN.md` together.

## License

[MIT](LICENSE)
