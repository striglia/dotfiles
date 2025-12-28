# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

Dotfiles are organized into **stow packages** (directories):

```
dotfiles/
├── claude/          # Claude Code configuration
│   └── .claude/     # Symlinked to ~/.claude/
├── git/             # Git configuration
│   └── .gitconfig   # Symlinked to ~/.gitconfig
└── zsh/             # Zsh shell configuration
    ├── .zprofile    # Symlinked to ~/.zprofile
    ├── .zshenv      # Symlinked to ~/.zshenv
    └── .zshrc       # Symlinked to ~/.zshrc
```

Each package contains files/directories that mirror their location in your home directory.

## Installation

### Prerequisites

Install GNU Stow:

```bash
# macOS
brew install stow

# Linux (Debian/Ubuntu)
sudo apt install stow

# Linux (Fedora)
sudo dnf install stow
```

### Install All Packages

From the dotfiles directory:

```bash
cd ~/dotfiles
stow */
```

This creates symlinks in your home directory for all packages.

### Install Specific Package

Install just one package (e.g., only zsh):

```bash
cd ~/dotfiles
stow zsh
```

### Uninstall Package

Remove symlinks for a package:

```bash
cd ~/dotfiles
stow -D zsh
```

### Reinstall Package

Useful after making changes:

```bash
cd ~/dotfiles
stow -R zsh
```

## How Stow Works

Stow creates **symlinks** from your home directory to files in the dotfiles repo.

**Example**: Running `stow zsh` from `~/dotfiles` creates:
- `~/.zshrc` → `~/dotfiles/zsh/.zshrc`
- `~/.zprofile` → `~/dotfiles/zsh/.zprofile`
- `~/.zshenv` → `~/dotfiles/zsh/.zshenv`

**Benefits**:
- Edit files in the repo, changes take effect immediately
- Version control for all dotfiles
- Easy to sync across machines
- Selective installation (pick which packages to install)

## Adding New Dotfiles

### 1. Create a Package Directory

```bash
cd ~/dotfiles
mkdir nvim
```

### 2. Move Existing Config Into Package

```bash
# Move existing file/directory into the package
mv ~/.config/nvim nvim/.config/
```

### 3. Stow the Package

```bash
stow nvim
```

This creates `~/.config/nvim` → `~/dotfiles/nvim/.config/nvim`

### 4. Commit and Push

```bash
git add nvim/
git commit -m "Add nvim configuration"
git push
```

## Package Descriptions

### `claude/`
Claude Code configuration including:
- Skills (custom workflows)
- Commands (slash commands)
- Settings and preferences

### `git/`
Git global configuration:
- User info
- Aliases
- Default behaviors

### `zsh/`
Zsh shell configuration:
- `.zshrc` - Interactive shell config
- `.zprofile` - Login shell config
- `.zshenv` - Environment variables (loaded for all shells)

## Tips

### Preview Changes

See what stow will do without making changes:

```bash
stow -n zsh  # Dry run
stow -v zsh  # Verbose output
```

### Conflicts

If stow finds existing files, it will error. Options:

1. **Backup and remove** the existing file, then stow
2. **Adopt** the existing file into the repo:
   ```bash
   stow --adopt zsh  # Moves existing files into dotfiles/zsh/
   ```

### Check What's Stowed

```bash
# List all symlinks in home directory
ls -la ~ | grep '\->'

# Find all symlinks pointing to dotfiles
find ~ -maxdepth 3 -type l -ls | grep dotfiles
```

## Syncing Across Machines

### Initial Setup on New Machine

```bash
# Clone the repo
git clone https://github.com/striglia/dotfiles.git ~/dotfiles

# Install all packages
cd ~/dotfiles
stow */
```

### Update Existing Machine

```bash
cd ~/dotfiles
git pull
stow -R */  # Restow all packages to pick up changes
```

## Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Stow Dotfiles Tutorial](https://www.jakewiesler.com/blog/managing-dotfiles)
- [Using GNU Stow to Manage Your Dotfiles](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)
