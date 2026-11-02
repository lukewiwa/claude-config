# claude-config

My personal Claude Code skills, shared between my Mac and my devcontainers. Each folder in `skills/`
is linked into `~/.claude/skills/`.

- `wiwa-code-taste`: my code standards and how to review against them. Run it with `/wiwa-code-taste`. Claude
  also picks it up on its own for reviews.

## Install

```bash
git clone https://github.com/lukewiwa/claude-config.git ~/repos/claude-config
~/repos/claude-config/install.sh
```

You don't normally run this by hand:

- [dotfiles](https://github.com/lukewiwa/dotfiles) clones this repo to `~/repos/claude-config` on the Mac
  and runs the installer.
- [devcontainer-dotfiles](https://github.com/lukewiwa/devcontainer-dotfiles) clones it to
  `~/.claude-config` in every container and runs the installer.

The installer links the files rather than copying them. Edits here take effect on the next session, and
containers pick up pushed changes when they're rebuilt (or after a `git pull` in `~/.claude-config`).

## Adding a skill

Add `skills/<name>/SKILL.md`, then re-run `install.sh` to link it.
