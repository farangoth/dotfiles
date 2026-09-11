# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

Arch Linux dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package containing the full config path (e.g., `nvim/.config/nvim/`). To symlink a package into `$HOME`:

```sh
stow <package>          # e.g. stow nvim
stow --delete <package> # remove symlinks
stow --restow <package> # re-link (useful after adding files)
```

`install.sh` (repo root) wraps this: detects which of the three machines (desktop/pi/macos) it's running on and stows/`brew bundle`s the right set, or takes an explicit `./install.sh desktop|pi|macos`.

**CI** (`.github/workflows/ci.yml`): on every push to `main` and every PR, runs shellcheck on the rofi scripts and `foot-theme`, luacheck on the nvim Lua config (see `.luacheckrc`), a syntax check of `river/init`, a JSONC sanity check of waybar's config, and a `stow -n` dry-run of every package to catch symlink conflicts before they hit `$HOME`. There's no CD — a dotfiles repo isn't deployed anywhere; `stow` is run by hand on whichever machine you're setting up.

## Wayland Desktop Stack

- **WM**: River (config: `river/.config/river/init` — a Python script run by River on startup)
- **Bar**: Waybar (`waybar/.config/waybar/config.jsonc` + `style.css`)
- **Notifications**: Mako (`mako/.config/mako/config`)
- **Launcher**: Rofi (`rofi/.config/rofi/`) with custom shell scripts in `scripts/`
- **Idle/lock**: Swayidle + Swaylock
- **Display management**: Kanshi (auto-switch output profiles: `nomad`, `clamshell`, `dual`)
- **Theme**: Catppuccin Mocha throughout all components

To reload the River config: `Super+Shift+C` (re-executes `~/.config/river/init`).

**Terminal**: foot (`foot/.config/foot/foot.ini`) is the default terminal (`$TERMINAL` in zsh). Floating utility terminals (waybar/rofi quick-launchers) spawn `foot --app-id=term-float`, matched by the `term-float` river rule.

**Mod+Return — the main terminal**: rather than spawning a plain new `foot` on every press, `Mod+Return` runs `river/.local/bin/toggle-main-term`, which reveals the existing `main`-tmux terminal if one is already open, or spawns it if not. It pins that window to `term-main`'s river app-id, checks via `pgrep -f` whether a `foot --app-id=term-main` process already exists (`riverctl` has no window-query command, so this is the best available proxy). Tag 256 (bit 8) is deliberately above the Mod+1..8-reachable range (bits 0-7, see Tags below) and outside Mod+0's "all tags" mask, so it's a hidden slot dedicated to this one window — the same pin-to-a-tag idiom the `firefox` rule uses for tag 4 — and `river/init`'s `rule-add -app-id term-main tags 256` is what puts the spawned window there. On first spawn (no matching process yet) it `set-focused-tags 256` to switch straight to it, same as launching anything else; if it's already running, it `toggle-focused-tags 256` instead — merging tag 256 into whatever's currently viewed rather than replacing the view outright, mirroring the `Mod+Control+<n>` bindings below that use the same command for the same reason. Being a toggle, pressing Mod+Return again while term-main is already part of the view hides it, consistent with how `Mod+Control+<n>` behaves everywhere else in this config. The new foot window needs no extra tmux-invocation logic of its own: any interactive shell it starts already runs the `exec tmux new-session -A -s main` auto-attach from the Zsh section below, which does the actual attach-or-create.

**Screenshots**: `Print` copies a full-screen shot to the clipboard (`grim | wl-copy`); `Super+Shift+S` copies a selected region (`grim -g "$(slurp)" | wl-copy`). Both land in cliphist automatically since `wl-paste --watch cliphist store` is already running.

**Clipboard**: `wl-clipboard` + `cliphist` back a single system clipboard shared by foot (`selection-target=clipboard`), tmux copy-mode, and Neovim (`clipboard=unnamedplus`). Tmux copy-mode relays via OSC 52 (`set-clipboard on`) rather than piping to `wl-copy` directly, so the same binding works locally (foot writes the OSC 52 payload to the real Wayland clipboard, which cliphist still picks up) and over SSH into a headless box with no Wayland session at all.

## Neovim Config

**Package manager**: Native `vim.pack` (Neovim 0.12+ built-in — confirmed absent on 0.11.4, present on nightly/0.12) — not lazy.nvim.

Entry point: `nvim/.config/nvim/init.lua` loads three modules in order:
1. `plugins/` — plugin declarations and setup (each file calls `vim.pack.add` then configures)
2. `config/` — options, keymaps
3. `custom/` — personal overrides

**Key plugins:**
- `snacks.nvim` — picker (files, grep, LSP navigation), explorer, git UI, zen mode, terminal, notifier (`vim.notify` UI)
- `blink.cmp` — completion (super-tab preset, LSP/path/snippets/buffer sources)
- `codecompanion.nvim` — AI integration via Mistral (`MISTRAL_API_KEY` env var required)
- `mason.nvim` + `mason-lspconfig` — manages LSP servers (lua_ls, ruff, basedpyright, bashls, jsonls, yamlls, taplo, cssls, html)
- `conform.nvim` — formatting (stylua for lua, shfmt for sh/bash, falls back to the LSP formatter for everything else)
- `gitsigns.nvim` — inline hunk signs, staging/reset/preview, inline blame toggle
- `nvim-surround` — add/change/delete surrounding pairs
- `todo-comments.nvim` — highlights + quickfix listing of TODO/FIXME/HACK comments
- `which-key.nvim` — keymap groups
- `catppuccin` — colorscheme

**LSP servers** auto-installed by Mason. **Formatters** (stylua, shfmt) are not — install with `:MasonInstall stylua shfmt` or the system package manager, since `mason-lspconfig`'s `ensure_installed` only covers LSP servers.

**Format-on-save** lives in `plugins/conform.lua`, not `plugins/lsp.lua` — conform's own `format_on_save` (gated on `vim.g.autoformat`, toggle with `<leader>tf`) with `lsp_format = "fallback"` replaced the old `LspAttach`/`BufWritePre`/`vim.lsp.buf.format` autocmd in `lsp.lua`, so there's one format-on-save mechanism instead of two that could compete.

**Adding a new plugin**: Call `vim.pack.add("url")` at the top of the relevant file in `lua/plugins/`, then configure below it. Run `:lua vim.pack.update()` (or `<leader>pu`) to fetch.

**Lua LSP**: `.luarc.json` at the repo root declares `vim` as a global for lua_ls diagnostics.

**Minimal profile**: see the `raspi` package, below.

## Key Neovim Keymaps

Leader is `Space`.

| Key | Action |
|-----|--------|
| `<leader><space>` | Smart file picker |
| `<leader>ff` | File picker |
| `<leader>sf` | Grep files |
| `<leader>e` | File explorer |
| `<leader>gg` | Lazygit |
| `<leader>ma` | CodeCompanion actions |
| `<leader>mt` | Toggle AI chat |
| `<leader>pu` | Update packages |
| `<leader>pm` | MasonUpdate |
| `<leader>tf` | Toggle format-on-save |
| `<leader>gp` / `ga` / `gr` | Preview / stage / reset git hunk |
| `<leader>tb` | Toggle inline git blame |
| `]h` / `[h` | Next/prev git hunk |
| `<leader>st` | Search TODO comments (quickfix) |
| `<leader>rt` | Add a TODO comment (commented per filetype, drops into insert) |
| `H` / `L` | Prev/next buffer |

## Zsh

Uses oh-my-zsh with `macovsky` theme. Python venvs auto-activated via the `uv` and `python` plugins (`PYTHON_AUTO_VRUN=true`, venv name `.venv`). Secrets sourced from `~/.env_secrets` (not in this repo).

**Minimal profile**: see the `raspi` package, below.

**Always inside tmux**: every zshrc (`zsh`, `macos`, `raspi`) attaches to (or creates) a tmux session named `main` at the end of an interactive shell login, guarded on `[[ -z "$TMUX" && -o interactive && -t 1 ]]` — so it never fires inside an already-running tmux pane, a non-interactive shell, or a script/cron context. The point is coherence: with this in place there's no "outside tmux" state on any machine, so tmux's own bindings are the only bindings that matter, identical whether the outer terminal is foot or iTerm2.

The attach itself is `exec tmux new-session -A -s main`, not a plain call: `new-session -A` attaches if `main` already exists or creates it otherwise, atomically (no window between a failed `tmux attach` and a following `tmux new` where a second shell doing the same thing could race in and create a duplicate session), and `exec` replaces the shell process outright rather than spawning tmux as a child. That second part is what makes exiting the last pane/window of `main` (which already destroys the session — tmux's own default) also close the wrapping terminal window (foot, iTerm2) or end the SSH connection (raspi), instead of dropping back to a bare shell prompt inside the same window: once the exec'd tmux exits there's no parent shell process left for control to fall back to, so the terminal's child just ends. Confirmed live via real pty capture (`script`) that a plain (non-`exec`) call leaves a resumed shell behind after tmux exits, while `exec` leaves nothing running.

**`dev` profile**: `dev` (in `zsh`/`macos`, not `raspi`) calls `tmux-dev` (`tmux/.local/bin/tmux-dev`, shared — pure bash + tmux, no OS-specific bits), which opens a three-pane tmux window rooted in the given directory (`$PWD` if omitted): `nvim`, `claude`, and a plain shell. Idempotent — reattaches instead of duplicating if a session already exists for that directory (session name is `dev-<basename>`).

On desktop, `dev`'s zsh function spawns a new, untagged `foot` window to run `tmux-dev` in (`( foot tmux-dev "${1:-$PWD}" & ) 2>/dev/null`) rather than running it inline in the calling shell. `tmux-dev` ends by attaching or `switch-client`-ing the *calling* client onto the `dev-<dir>` session, so running it inline would hijack whichever window `dev` was typed into — including the `term-main` window `Mod+Return` manages, silently switching it away from `main` and breaking that binding's "always shows `main`" contract. A fresh window sidesteps this: it gets its own tmux client, leaving the window `dev` was launched from untouched. The subshell-backgrounding is the same job-control-message-suppression trick as the git-fetch hook above.

**SSH theme switch**: the `ssh` function wraps the real `ssh`, flipping foot to Catppuccin Frappe for the duration of the session and back to whatever `foot.ini` loaded (Mocha) on exit — so the terminal itself signals "you're on a remote box" independently of anything the remote sends. Implemented via `~/.local/bin/foot-theme` (`foot/.local/bin/foot-theme`), which reads the actual `/usr/share/foot/themes/catppuccin-<name>` file and emits the corresponding OSC 4/10/11 dynamic-color sequences (reset via OSC 104/110/111/112) — nothing hardcoded, so it can't drift from the installed theme (Frappe's own background needs no dimming the way Latte's did, so unlike the very first version of this feature there's no override to keep in sync anywhere). Guarded on `[[ -t 1 ]]` so it never fires when `ssh`'s output is being piped or captured. Needs `allow-passthrough on` in tmux (already set) to reach foot when `ssh` runs inside a pane, since tmux otherwise swallows OSC sequences from programs running in it.

Frappe and Mocha are both dark flavours, though, so the flip is subtler than Latte's was — mostly a base-color shift (`#303446` vs `#1e1e2e`), not light-vs-dark. Two more explicit, textual signals back it up, both needing their own opt-in tmux option since tmux doesn't forward either by default:

- **Window title**: `set-titles-string "#S: #{pane_current_command}"` in tmux — always `<session>: <running command>` (e.g. `dev-dotfiles: nvim`, or `dev-dotfiles: ssh` while a pane's ssh'd), independent of any per-program OSC 2 title. Waybar's `river/window` module shows the title live, so this surfaces there too. Needs `set-titles on` in tmux (already set) — off by default, same reason as `allow-passthrough`. The `ssh` function's own OSC 2 `SSH: <target>` sequence (a heuristic — the last argument, so `ssh host cmd args` would show the last arg instead) still fires on connect/exit and still matters outside tmux, but no longer reaches the window title while inside tmux, since `set-titles-string` doesn't reference `#T` (the pane title that sequence sets) anymore — the SSH target now lives on the status bar's red chip instead (see Tmux below).
- **Tmux window name**: the same `ssh` function also does `tmux rename-window "ssh:$target"` on connect when `$TMUX` is set, restoring `automatic-rename` on exit rather than trying to restore a captured name (simpler, and avoids restoring a stale auto-generated name) — the outer-terminal title is one shared string for the whole terminal, so it can't distinguish which tmux window you're looking at; the window name can. Trade-off: if you'd manually renamed that window yourself before connecting, `automatic-rename on` on exit clobbers it back to tracking the running command.
- **Tmux pane border**: `pane-border-format` shows each pane's running command on its own border, styled with `@thm_peach` specifically when that command is `ssh`. This is the one thing the whole-window color/title switch can't do on its own — OSC changes and the title are both window-scoped, so if only one pane in a multi-pane window is SSH'd, the other two signals still apply to the entire window; the pane border is genuinely per-pane.
- **Tmux status bar**: `status-style` shifts to Catppuccin Frappe (`@thm_frappe_*`) when the *focused* pane's `pane_current_command` is `ssh`, same ternary technique and same per-pane-focus caveat as the border above. Set with plain `set -g`, not `-gF` — confirmed live in a real tmux session that `-gF` bakes a ternary into a static value at the moment it's set (fine for the plain `@thm_*` lookups elsewhere in this file, which never change after load) rather than re-evaluating it on every render the way a condition depending on `pane_current_command` needs; `pane-border-format` below was already doing this correctly (plain `set -g`), which is what exposed the mismatch.

## Tmux

`tmux/.config/tmux/tmux.conf` (XDG path, tmux 3.1+). Default prefix (`Ctrl-b`), vi copy-mode, mouse on. `Ctrl-h/j/k/l` move between tmux panes and Neovim splits seamlessly (mirrors the Neovim `<C-hjkl>` window-nav keymaps via a `pane_tty`/process check — no plugin needed). Copy-mode `y` uses tmux's OSC 52 clipboard relay (see Clipboard above) rather than a `wl-copy` pipe, so it works the same locally and over SSH. `Ctrl-Tab` / `Ctrl-Shift-Tab` switch to the next/previous window, browser-tab-style — needs `extended-keys on` (set) plus the terminal actually reporting Ctrl/Shift+Tab as a distinct key (xterm modifyOtherKeys / Kitty keyboard protocol / CSI u) rather than plain Tab; confirmed as a real, live-settable tmux option, but whether foot/iTerm2 emit the right sequence isn't verifiable from a sandbox with no real terminal attached — a real-machine check.

**Nested-tmux passthrough (`F12`)**: every machine auto-attaches to a local `main` session on login (see Zsh above), so SSH'ing from one tmux'd machine into another (desktop → raspi, say) nests one tmux session inside the other — both listen for the same prefix and the same root-table binds (`Ctrl-h/j/k/l`, `Ctrl-Tab` above), and since the inner session is the foreground process it swallows everything, leaving no way to reach the outer session at all. A different prefix per machine would only fix prefix-table collisions, not the root-table ones this file has several of, so this follows the more complete fix from [freeCodeCamp's nested-tmux writeup](https://www.freecodecamp.org/news/tmux-in-practice-local-and-nested-remote-tmux-sessions-4f7ba5db8795/): `F12` flips the *outer* session into a passthrough "OFF" mode — unsets its prefix and switches its root key table to an empty one (`off`, holding only the restore binding), so every keystroke reaches the inner session untouched, with a glaring red status bar making the mode obvious. A second `F12` restores it via `source-file` (reusing the `bind r` reload rather than a second copy of prefix/status-style/status-left to keep in sync) — `prefix`/`key-table` aren't things tmux.conf itself sets (this file relies on tmux's own `C-b`/`root` defaults), so those two are restored explicitly first, before the reload. Confirmed live via real injected keystrokes into an attached client (not `show-options`, which only proves what a command *would* set, not what a live client actually does with it): with `key-table=off`, `Ctrl-b d` (the detach binding) passes straight through as literal `d` text in the shell instead of detaching, and a second `F12` mid-session correctly restores `key-table=root`/`prefix=C-b`.

**Status bar**: three status lines (`status 3`), each built explicitly via `status-format[0..2]` rather than tmux's default single-line template (which interleaves `status-left`/`status-right` with the window list) — top line is identity/context, middle is a blank spacer, bottom is the window list alone. Top and bottom used to share one line with no spacer, which is what the session-pill-colliding-with-the-window-list bug actually was: `status-left-length` defaulted to 10, truncating the pill mid-cap so the window list rendered flush against it with no gap. Referencing `status-left`/`status-right`/`window-status-format`/`window-status-current-format` inside a hand-written `status-format[N]` needs the `#{T:...}` prefix (tmux's "treat as format" — runs a second expansion pass), not the bare `#{status-left}` form — confirmed live that the bare form returns the option's *unexpanded* string, its own `#{...}` references printed as literal text.

Top line, left to right: a lavender session-name pill (terminal icon); while the focused pane is ssh'd, a red `SSH:` target pill (server icon, `#{window_name}`, which the zsh `ssh()` wrapper already renames to `ssh:<target>` on connect, so no separate detection mechanism was needed — see Window title above for why that name no longer also drives the outer window title); a green cwd pill (folder icon, `#{pane_current_path}`). Right-aligned: blue date+time text (clock icon) — no pill/caps around it, see below for why. Bottom line: the window list, using the same session-pill styling for the active window. Each of the three left pills is two color zones with a straight (uncharactered) split between them — `#[fg=accent]#[bg=bar-bg]<capL>#[fg=crust]#[bg=accent] icon  #[fg=accent]#[bg=surface] label #[fg=surface]#[bg=bar-bg]<capR>` — a saturated accent fill behind the icon (`crust`, near-black, for contrast) stepping straight into the neutral `surface1`/`frappe_surface1` fill behind the label, no divider character between them. Two spaces trail the icon, not one — both still on the icon's own `bg=accent` zone, so the extra space reads as breathing room around the glyph rather than a shift toward the label. Icons are Font Awesome codepoints from the Nerd Fonts symbol set (terminal U+F120, server U+F233, folder U+F07B, clock U+F017) verified against the canonical `nerd-fonts` `glyphnames.json`, not typed from memory — same Nerd-Font-required caveat as the pill caps (can't visually verify actual glyph rendering from a sandbox with no patched font). Pills use the U+E0B4/U+E0B6 rounded-cap glyphs from the original Powerline Extra Symbols block — the oldest, most stable part of the Nerd Font symbol set, present in every variant, chosen over a newer icon set specifically to avoid a tofu-box risk this can't visually verify from a sandbox. Each cap's `fg` is the pill's own fill color and its `bg` matches whatever's behind it, which is what reads as a curve instead of a hard edge. Both lines are Mocha/Frappe-aware via the same SSH-detection ternary as `status-style` (see comment there for the `-F`-freezes-the-value pitfall) — built as two complete literal strings picked by one outer ternary rather than interleaving small ternaries, so the SSH condition is written once per option instead of repeated per cap. Each `#[...]` block sets exactly one attribute (`#[fg=X]#[bg=Y]`, never a comma-joined `#[fg=X,bg=Y]`): a comma there would need escaping as `\,` to survive being embedded inside the outer `#{?cond,yes,no}` ternary, and that shipped once already — real-pty capture (`script`, not `show-options`, which only proves the stored value, not the render) showed tmux failing to unescape it before the style parser ran, leaking `fg=...`/`bg=...` as literal on-screen text. Single-attribute blocks never put a comma inside a ternary branch, so there's nothing to escape.

**Why the clock isn't a pill**: it originally was one (same two-zone construction as the left pills), and broke — with 3 two-zone pills on the left (the ssh branch) plus a *pill-structured* right side, everything from the clock's day-of-week onward silently vanished from the render. First suspected the `│` (U+2502) divider glyph specifically (it renders via legacy VT100 ACS charset translation, not a literal UTF-8 byte, and removing it alone did fix an earlier, smaller repro) — but that theory didn't survive further testing: a two-zone pill with a straight, uncharactered split (icon on accent bg, label on surface bg, no divider character at all) *still* breaks the same way with 3 such pills on the left. Real-capture A/B tests (same methodology as the `\,`-escaping bug) narrowed it further: 2 two-zone left pills + a pill-structured right side works; 3 two-zone left pills + *any* pill-structured right side (single-zone or two-zone, with or without a divider) breaks; 3 two-zone left pills + plain unstyled/uncapped text on the right works fine regardless of complexity. So the actual constraint is about the **right side having its own cap/color-zone structure at all**, combined with 3+ two-zone pills already on the left — not the divider character, which was a red herring from an under-scoped first repro. Not confirmed as a documented tmux bug, just empirically triggered and worked around by keeping the clock as plain colored icon+text with no caps. If a future edit gives the clock pill structure back, or adds a 4th left pill, retest exactly this way (real `script` capture of the ssh-branch worst case, 3+ repeated runs, not just `show-options`) before trusting it.

There is no rounded pane-divider option in tmux — `pane-border-lines` only accepts `single`/`double`/`heavy`/`simple`/`number`; `rounded` is a real tmux value, but only for the unrelated `popup-border-lines`. An earlier revision of this file set `pane-border-lines rounded` anyway, which tmux silently accepts at `new-session -f` time (only `source-file` or an interactive attach actually surfaces the "unknown value" error) — the CI `tmux-config` job's `new-session -f` check didn't catch it, which is why it shipped; that job now sources the config into a running session instead, which does propagate the failure.

**Plugins**: [TPM](https://github.com/tmux-plugins/tpm) manages one plugin, [tmux-which-key](https://github.com/alexwforsythe/tmux-which-key) (`prefix + Space` opens a menu of windows/panes/buffers/sessions/copy-mode/client actions — confirmed live this is its actual default binding; the root-table `Ctrl+Space` trigger some docs mention isn't registered unless separately configured, so it doesn't collide with the `Ctrl-h/j/k/l`/`Ctrl-Tab` root-table binds above). `install.sh` clones TPM to `~/.config/tmux/plugins/tpm` and runs its headless installer (`tpm/bin/install_plugins`) on every profile, so a fresh machine has plugins ready without a manual `prefix + I` — confirmed live end-to-end (`install.sh pi` against a scratch fake home: TPM cloned, `tmux-which-key` installed, `prefix + Space` binding present after reload). tmux.conf's own plugin lines are guarded — `if "test -f #{HOME}/.config/tmux/plugins/tpm/tpm" "run '#{HOME}/.config/tmux/plugins/tpm/tpm'"` rather than a bare `run` — because an unguarded `run` against a path that doesn't exist yet (a fresh checkout before `install.sh` has run, or the CI `tmux-config` job's clean environment) exits non-zero and would fail `source-file`; confirmed live both ways (guarded: exits 0 with TPM absent; unguarded: exits 127).

Adding another plugin: add a `set -g @plugin '...'` line above the guarded `run` line (same pattern TPM itself expects — TPM's install script parses these directly out of `~/.config/tmux/tmux.conf`'s text, not from tmux's live option state, so the line has to be in the real file, not just sourced from a `-f` override), then either `prefix + I` inside tmux or re-run `install.sh`.

**`tmux-dev`** (`tmux/.local/bin/tmux-dev`): the `dev` profile launcher — see Zsh above.

## Raspberry Pi (`raspi` package)

The Pi-specific pieces live in one stow package — `stow raspi tmux` sets the Pi up (`tmux` is the same OS-agnostic package the desktop and macOS use, worth having here too for the auto-start-on-login/SSH-resilience benefit — see Zsh above):

- **`raspi/.config/nvim/init.lua`**: a single-file, dependency-free Neovim config — no plugin manager, no LSP/treesitter, built-ins only, so it starts instantly and works offline. Targets the same `~/.config/nvim` path as the main `nvim` package, so the two are **alternatives — never stow both on the same machine** (`stow` correctly refuses if you try; the repo's CI `stow -n` dry-run can't catch this specific case since each package is checked independently against a clean scratch `$HOME`). Colorscheme is Catppuccin Frappe, hand-rolled with plain `vim.api.nvim_set_hl` calls (no plugin manager to fetch catppuccin.nvim with) — matches the theme foot itself switches to for the SSH session this nvim normally runs inside (see SSH theme switch above). A `[PI]` window-title tag adds a second signal.
- **`raspi/.zshrc`**: trimmed oh-my-zsh setup — no `archlinux` plugin (wrong OS on Raspberry Pi OS/Debian), no Python venv auto-activation, stock `robbyrussell` theme instead of `macovsky` (guaranteed present without extra setup), and no hardcoded `SSH_AUTH_SOCK` (would clobber the one `sshd` sets via agent forwarding, breaking `ssh -A`). Same `~/.zshrc` target as the main `zsh` package — alternatives, never stow both.

The Wayland desktop stack above (river, waybar, mako, rofi, kanshi, swayidle, swaylock, foot, kitty) doesn't apply here — the Pi has no display and no Wayland session.

## macOS (`macos` package, work laptop)

Unlike `raspi`, this isn't a from-scratch alternative to the main packages — `nvim` and `tmux` are already OS-agnostic (Mason fetches per-OS binaries, clipboard integration doesn't depend on Wayland) and get stowed as-is: `stow nvim tmux macos` on this machine. Only zsh needed a macOS-specific variant, plus two pieces with no Linux equivalent at all:

- **`macos/.zshrc`**: adapted from `zsh/.zshrc` — adds `eval "$(/opt/homebrew/bin/brew shellenv)"` (Apple Silicon Homebrew PATH, no Linux equivalent), drops the `archlinux` oh-my-zsh plugin (wrong OS, same fix as `raspi`), drops the hardcoded `SSH_AUTH_SOCK` (macOS SSH agents — Secretive, 1Password, launchd's own — set their own socket; hardcoding one would clobber it, the same class of bug `raspi` avoids for `ssh -A`), and drops `$TERMINAL` (nothing shells out to it here). Same `~/.zshrc` target as `zsh`/`raspi` — alternatives, never stow more than one at once.
- **SSH theme switch, iTerm2 version**: the `ssh` function switches iTerm2 profiles via its proprietary OSC 50 `SetProfile` sequence (`SSH-Frappe` on connect, `Default` on exit) instead of the desktop's `foot-theme` script, since foot's theme files don't exist on macOS. The two profiles (Catppuccin Mocha `Default`, Catppuccin Frappe `SSH-Frappe`) are declared in `macos/Library/Application Support/iTerm2/DynamicProfiles/dotfiles.json` — iTerm2 loads dynamic profiles from that directory automatically, no import step needed. **Not verified against a real iTerm2 session** — built from iTerm2's documented OSC 50 syntax, not live-tested; confirm the profile actually flips (and that tmux's `allow-passthrough on` is sufficient to forward OSC 50 through a pane) on the actual laptop. The window-title OSC 2 signal is unchanged from the desktop version.
- **`Brewfile`** (repo root, like `.luarc.json` — a repo utility file, not stowed into `$HOME`): `brew bundle --file=Brewfile` installs everything the stowed configs expect on PATH (stow itself, neovim, tmux, fzf, zoxide, eza, bat, ripgrep, lazygit, iTerm2, a Nerd Font for `eza --icons`/Snacks icons). oh-my-zsh isn't brew-installable — run its installer separately.

The Wayland desktop stack, `raspi`'s minimal nvim, and the tmux pane-border SSH indicator's `@thm_peach` styling all still apply unchanged; only the parts that are genuinely Linux/Wayland/foot-specific needed a macOS counterpart.
