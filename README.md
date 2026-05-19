# fuel

A tiny shell script that shows your Claude Code rate-limit usage at a glance — 5-hour session and 7-day rolling windows, with a color-coded progress bar.

## Example output

```
  Claude Usage

  5h   50%  ███████████████░░░░░░░░░░░░░░░  resets in 2h11m
  7d   41%  ████████████░░░░░░░░░░░░░░░░░░  resets in 10h1m
```

Bar colors: green < 60 %, yellow < 85 %, red ≥ 85 %.

## Requirements

- `bash`
- `curl`
- `jq`
- `bc`
- A Claude Code credentials file at `~/.claude/.credentials.json` (created automatically when you log in to Claude Code)

## Installation

```bash
# Clone the repo
git clone https://github.com/brainwagon/claude-fuel.git
cd claude-fuel

# Install to your PATH
chmod +x claude-fuel.sh
cp claude-fuel.sh ~/.local/bin/fuel

# Run it
fuel
```

Or install without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/brainwagon/claude-fuel/main/claude-fuel.sh \
  -o ~/.local/bin/fuel && chmod +x ~/.local/bin/fuel
```

## Usage

```
fuel
```

No flags, no config. It hits the Anthropic API with a single minimal request solely to read the rate-limit response headers — it does not consume any meaningful quota.

## Installing as a Claude Code slash command

Once `fuel` is on your PATH, you can run it as `/fuel` inside any Claude Code session.

**1. Create the commands directory (if it doesn't exist):**

```bash
mkdir -p ~/.claude/commands
```

**2. Create the command file:**

```bash
echo '!fuel' > ~/.claude/commands/claude-fuel.md
```

**3. Use it:**

In any Claude Code session, type `/claude-fuel` and press Enter. Claude Code will run the script and display your current usage.

> Slash commands live in `~/.claude/commands/` (available in all projects) or `.claude/commands/` inside a project directory (project-local only). The filename without `.md` becomes the command name.

## License

This is free and unencumbered software released into the public domain. See [LICENSE](LICENSE).
