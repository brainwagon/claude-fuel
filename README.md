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
git clone https://github.com/yourname/fuel.git
cd fuel

# Make the script executable
chmod +x fuel

# Run it
./fuel

# Optional: put it on your PATH
cp fuel ~/.local/bin/fuel
```

Or install without cloning:

```bash
curl -fsSL https://raw.githubusercontent.com/yourname/fuel/main/fuel \
  -o ~/.local/bin/fuel && chmod +x ~/.local/bin/fuel
```

## Usage

```
fuel
```

No flags, no config. It hits the Anthropic API with a single minimal request solely to read the rate-limit response headers — it does not consume any meaningful quota.

## License

This is free and unencumbered software released into the public domain. See [LICENSE](LICENSE).
