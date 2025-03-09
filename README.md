<!-- ABOUT THE PROJECT -->

## About The Project

[![tmux.conf][product-screenshot]](https://example.com)

`tmux-simpre` is simple tmux config with nice status bar, minimal style, auto save session, package manager, and key binding for vim movement.

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
3. Install config with bash script. `NOTE: Backup your tmux.conf first. this config will replece your config at $HOME dir `

   ```sh
   bash install.sh
   ```

4. If you installed will show `Install success, please press Ctrl+r in tmux mode to reload config` in your terminal. it's done!!

5. In your terminal create new session on tmux, [(Tmux Cheat Sheet)](https://tmuxcheatsheet.com/)

```sh
$ tmux
```

6. Reload your tmux with binding key

```sh
Control + r
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

Narong Kanthanu - [@twitter_handle](https://twitter.com/twitter_handle) - email@email_client.com

Project Link: [https://github.com/Narong-Kanthanu/tmux-simpre](https://github.com/Narong-Kanthanu/tmux-simpre)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->

[product-screenshot]: images/screenshot.png
