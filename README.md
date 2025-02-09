# Pawesome Dotfiles

```
╔════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                            ║
║   .S_sSSs     .S_SSSs     .S     S.     sSSs    sSSs    sSSs_sSSs     .S_SsS_S.     sSSs   ║
║  .SS~YS%%b   .SS~SSSSS   .SS     SS.   d%%SP   d%%SP   d%%SP~YS%%b   .SS~S*S~SS.   d%%SP   ║
║  S%S   `S%b  S%S   SSSS  S%S     S%S  d%S'    d%S'    d%S'     `S%b  S%S `Y' S%S  d%S'     ║
║  S%S    S%S  S%S    S%S  S%S     S%S  S%S     S%|     S%S       S%S  S%S     S%S  S%S      ║
║  S%S    d*S  S%S SSSS%S  S%S     S%S  S&S     S&S     S&S       S&S  S%S     S%S  S&S      ║
║  S&S   .S*S  S&S  SSS%S  S&S     S&S  S&S_Ss  Y&Ss    S&S       S&S  S&S     S&S  S&S_Ss   ║
║  S&S_sdSSS   S&S    S&S  S&S     S&S  S&S~SP  `S&&S   S&S       S&S  S&S     S&S  S&S~SP   ║
║  S&S~YSSY    S&S    S&S  S&S     S&S  S&S       `S*S  S&S       S&S  S&S     S&S  S&S      ║
║  S*S         S*S    S&S  S*S     S*S  S*b        l*S  S*b       d*S  S*S     S*S  S*b      ║
║  S*S         S*S    S*S  S*S  .  S*S  S*S.      .S*P  S*S.     .S*S  S*S     S*S  S*S.     ║
║  S*S         S*S    S*S  S*S_sSs_S*S   SSSbs  sSS*S    SSSbs_sdSSS   S*S     S*S   SSSbs   ║
║  S*S         SSS    S*S  SSS~SSS~S*S    YSSP  YSS'      YSSP~YSSY    SSS     S*S    YSSP   ║
║  SP                 SP                                                       SP            ║
║  Y    ARCH THEME    Y     MADE BY CHOOI    admin@redline-software.moscow     Y             ║
║                                                                                            ║
╚════════════════════════════════════════════════════════════════════════════════════════════╝
```

## Introduction

This repository contains my personal configuration files and scripts designed to simplify a BSPWM Arch Linux installation. It is especially useful if you want to fully customize your BSPWM setup without building everything from scratch.

## Installation

Before proceeding, **backup any existing configuration files** to prevent accidental loss of custom settings.

### Prerequisites

- A Unix-based operating system (Linux, Arch Linux, macOS, etc.)
- Git installed on your system
- Basic familiarity with the command line

### Step-by-Step Installation

1. **Clone the Repository**

   Open your terminal and run:
   ```bash
   git clone https://github.com/Alexander-Chudnikov-Git/pawesome-dotfiles.git ~/.dotfiles
   ```

2. **Navigate to the Dotfiles Directory**
   ```bash
   cd ~/.dotfiles
   ```

3. **Run the Installation Script**

   Make sure the installation script is executable. If it is not, set the executable permission:
   ```bash
   chmod +x install.sh
   ```
   Then, execute the script:
   ```bash
   ./install.sh
   ```
   The script will:
   - **Check and clone the configuration:** If the repository is not located in `$HOME/.config`, it backs up your existing configuration (if any) and copies the repository there.
   - **Install essential packages:** It uses `pacman` for system packages and `yay` for AUR packages.
   - **Configure system settings:** This includes setting up monitor hotplug rules, adding kernel parameters, and installing NVIDIA GPU drivers if an NVIDIA GPU is detected.

4. **Follow On-Screen Instructions**

   During the installation, you might be prompted with options:
   - **Restore Backup:** Use the `--restore [path]` option to restore a previous backup of your configuration.
   - **Override GPU Detection:** Use the `--gpu <number>` option to override the automatic GPU version check if needed.

### Advanced Installation Options

- **Restore a Previous Backup:**
  ```bash
  ./install.sh --restore /path/to/backup
  ```
  If no backup path is provided, the script will automatically use the most recent backup from `$HOME/.config_backup_*`.

- **Override GPU Detection:**
  ```bash
  ./install.sh --gpu <number>
  ```
  This option lets you manually set the GPU version used by the script to install appropriate NVIDIA drivers.

## Customization

After installation, you can customize the configurations to suit your needs:
- **Shell Configurations:** Modify your shell initialization files such as `.bashrc` or `.zshrc`.
- **Editor Settings:** Adjust configurations for your preferred code editor.
- **Application Preferences:** Tweak settings for your terminal emulator, window manager (BSPWM), and other applications.

Detailed comments within the dotfiles and scripts will help guide further customization.

## Usage

These dotfiles are designed to streamline your BSPWM workflow on Arch Linux. If you encounter any issues or have suggestions for improvements, please open an issue on GitHub or submit a pull request.

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Commit your changes and push the branch.
4. Open a pull request detailing your changes.

Your improvements and suggestions help make this project better for everyone.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contact

For any questions, issues, or suggestions, feel free to contact me at:
**Email:** admin@redline-software.moscow
