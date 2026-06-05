# dotfiles

dotfiles managed by chezmoi

## Installation

### macOS

```sh
xcode-select --install
cd $HOME && sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply nekrassov01
```

## Features

Set up the following in one shot:

- Home directory settings
- Bash setup
- Git setup, including config-based pre-commit hooks
- Homebrew package management
- mise runtime and task management
- VS Code settings and extension management
- PowerShell setup and configuration
- macOS preferences
- Pluggable task management via mise
- Claude Code configuration

## Todo

- [ ] Add Windows setup
- [ ] Add Linux setup
- [ ] GitHub Actions

## Author

[nekrassov01](https://github.com/nekrassov01)

## License

[MIT](https://github.com/nekrassov01/dotfiles/blob/main/LICENSE)
