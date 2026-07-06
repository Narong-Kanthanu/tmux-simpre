<!-- ABOUT THE PROJECT -->

## About The Project

[![tmux.conf][product-screenshot]](https://example.com)

`tmux-simpre` is a simple tmux config with a nice status bar, minimal style, auto-saved sessions, a package manager, and vim-style key bindings.

### Features

- Catppuccin (Macchiato) theme with a minimal status bar
- Status bar shows CPU, disk, battery, online/Tailscale VPN status
- Auto-save and restore sessions (`tmux-resurrect` + `tmux-continuum`)
- Vim-style pane navigation (`h`/`j`/`k`/`l`)
- Quick splits (`v` horizontal, `s` vertical) and friendlier window/session keys
- Confirm-before-kill for windows and sessions
- Universal clipboard with `allow-passthrough` enabled
- **Lazygit popup** (`prefix + g`): opens [lazygit](https://github.com/jesseduffield/lazygit) in a centered popup for the current pane's directory — but only when lazygit is installed **and** the pane is inside a git repository (otherwise the key does nothing, so it never launches lazygit somewhere useless).
- **Yazi file-manager toggle** (`prefix + f`): opens a [yazi](https://github.com/sxyazi/yazi) split in the current pane's directory, or closes it if the pane is already running yazi.

<!-- GETTING STARTED -->

### Prerequisites

This is tmux config, please install tmux before you used.

- [tmux](https://github.com/tmux/tmux)

| Platform         | Install Command       |
| ---------------- | --------------------- |
| Arch Linux       | `pacman -S tmux`      |
| Debian or Ubuntu | `apt install tmux`    |
| Fedora           | `dnf install tmux`    |
| RHEL or CentOS   | `yum install tmux`    |
| openSUSE         | `zypper install tmux` |
| macOS (Homebrew) | `brew install tmux`   |
| macOS (MacPorts) | `port install tmux`   |

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/Narong-Kanthanu/tmux-simpre.git
   ```
2. Enter to `tmux-simpre` dir with your terminal
   ```js
   cd tmux-simpre
   ```
3. Install config with bash script. `NOTE: backup your existing ~/.tmux.conf first — install.sh will prompt you to replace it.`

   ```sh
   bash install.sh
   ```

4. On success you'll see `Install success, please press Ctrl+b+r in tmux mode to reload config`. It's done!

5. In your terminal create a new tmux session ([Tmux Cheat Sheet](https://tmuxcheatsheet.com/))

```sh
$ tmux
```

6. Reload tmux config (prefix is `Ctrl + b`)

```sh
Ctrl + b  then  r
```

7. Install tmux package

```sh
Control + b + I
```

8. Update tmux package

```sh
Control + b + U
```

## Customization

If you want to change to your workflow. you can edit `tmux-simpre/.tmux.conf` and run `bash install.sh` again. or edit directly in `~/.tmux.conf` and reload config again.

## Contact

Narong Kanthanu - narong.oken@gmail.com

Project Link: [https://github.com/Narong-Kanthanu/tmux-simpre](https://github.com/Narong-Kanthanu/tmux-simpre)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[product-screenshot]: images/screenshot.png
