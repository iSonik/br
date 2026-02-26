# br

Browse directories from your terminal. Zero dependencies, pure zsh.


## Install

```sh
curl -sL https://raw.githubusercontent.com/iSonik/br/main/install.sh | sh
```

Then restart your terminal or run `source ~/.zshrc`.

## Usage

```sh
br
```

| Key | Action |
|-----|--------|
| `↑↓` | Navigate |
| `Tab` | Cycle action |
| `Enter` | Execute |
| `Esc` | Quit |

**Folders:** open · copy path · reveal in finder

**Files:** copy path · open in editor · reveal in finder

## Uninstall

```sh
rm -rf ~/.br && sed -i '' '/\.br\/br\.zsh/d' ~/.zshrc
```

## Screenshot
![br](screenshot.png)

## Requirements

- macOS
- zsh
