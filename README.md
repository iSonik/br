# br

Browse directories from your terminal. Zero dependencies, pure zsh.

```
  ~/dev/my-project

  + ../
  + src/
  + public/
    README.md
    package.json

   open  copy path  reveal in finder

  ↑↓ navigate · tab action · enter execute · esc quit
```

## Install

```sh
curl -sL https://raw.githubusercontent.com/iSonik/br/main/install.sh | sh
```

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

## Requirements

- macOS
- zsh
