#! /bin/sh

# ╔════════════════════════════════════════════════════════════════════════════════════════════╗
# ║                                                                                            ║
# ║   .S_sSSs     .S_SSSs     .S     S.     sSSs    sSSs    sSSs_sSSs     .S_SsS_S.     sSSs   ║
# ║  .SS~YS%%b   .SS~SSSSS   .SS     SS.   d%%SP   d%%SP   d%%SP~YS%%b   .SS~S*S~SS.   d%%SP   ║
# ║  S%S   `S%b  S%S   SSSS  S%S     S%S  d%S'    d%S'    d%S'     `S%b  S%S `Y' S%S  d%S'     ║
# ║  S%S    S%S  S%S    S%S  S%S     S%S  S%S     S%|     S%S       S%S  S%S     S%S  S%S      ║
# ║  S%S    d*S  S%S SSSS%S  S%S     S%S  S&S     S&S     S&S       S&S  S%S     S%S  S&S      ║
# ║  S&S   .S*S  S&S  SSS%S  S&S     S&S  S&S_Ss  Y&Ss    S&S       S&S  S&S     S&S  S&S_Ss   ║
# ║  S&S_sdSSS   S&S    S&S  S&S     S&S  S&S~SP  `S&&S   S&S       S&S  S&S     S&S  S&S~SP   ║
# ║  S&S~YSSY    S&S    S&S  S&S     S&S  S&S       `S*S  S&S       S&S  S&S     S&S  S&S      ║
# ║  S*S         S*S    S&S  S*S     S*S  S*b        l*S  S*b       d*S  S*S     S*S  S*b      ║
# ║  S*S         S*S    S*S  S*S  .  S*S  S*S.      .S*P  S*S.     .S*S  S*S     S*S  S*S.     ║
# ║  S*S         S*S    S*S  S*S_sSs_S*S   SSSbs  sSS*S    SSSbs_sdSSS   S*S     S*S   SSSbs   ║
# ║  S*S         SSS    S*S  SSS~SSS~S*S    YSSP  YSS'      YSSP~YSSY    SSS     S*S    YSSP   ║
# ║  SP                 SP                                                       SP            ║
# ║  Y    ARCH THEME    Y     MADE BY CHOOI    admin@redline-software.moscow     Y             ║
# ║                                                                                            ║
# ╚════════════════════════════════════════════════════════════════════════════════════════════╝

###############################################################################
# Script Name: setup-config.sh
# Description:
#   This script automates the configuration of a system by:
#     - Ensuring that the repository is located in $HOME/.config. If not, it
#       backs up any existing configuration and copies the repository there.
#     - Restoring a backup of ~/.config if requested.
#     - Installing essential packages using pacman and yay.
#     - Configuring kernel parameters, blacklisting modules, and setting up
#       monitor hotplug handling via udev and systemd.
#     - Detecting an NVIDIA GPU and installing appropriate drivers.
#
# Usage:
#   ./setup-config.sh [OPTIONS]
#
# Options:
#   --gpu <number>         Override the automatic GPU version detection with a
#                          specific GPU number.
#   --restore [path]       Restore backup of ~/.config. If [path] is not provided,
#                          the most recent backup matching ~/.config_backup_* is
#                          used.
#   --help, -h             Display this help message and exit.
#
# Author: [Your Name]
# Date: [Date]
###############################################################################

#######################################
# Function: check_and_clone_config_directory
# Description:
#   Checks if the current script is located in $HOME/.config. If it is not,
#   then it backs up any existing ~/.config directory and copies the current
#   repository into $HOME/.config. The user is then prompted to re-run the
#   script from the new location.
# Globals:
#   BASH_SOURCE, HOME
# Arguments:
#   None
# Returns:
#   None
#######################################
check_and_clone_config_directory() {
    # Determine the absolute directory path of the current script.
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Check if the script is already in $HOME/.config.
    if [[ "$SCRIPT_DIR" != "$HOME/.config" ]]; then
        echo "Repository is not located in $HOME/.config."
        # Backup existing ~/.config if it exists.
        if [ -d "$HOME/.config" ]; then
            BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
            echo "Backing up existing $HOME/.config to $BACKUP_DIR..."
            mv "$HOME/.config" "$BACKUP_DIR"
        fi
        echo "Cloning repository from $SCRIPT_DIR to $HOME/.config..."
        mkdir -p "$HOME/.config"
        # Copy all files and directories from the repository to ~/.config.
        cp -r "$SCRIPT_DIR"/* "$HOME/.config/"
        echo "Repository successfully cloned to $HOME/.config."
    else
        echo "Repository is already in $HOME/.config."
    fi
}

#######################################
# Function: restore_backup
# Description:
#   Restores a backup of the ~/.config directory. If a backup path is provided
#   as an argument, that backup is restored. Otherwise, the function finds and
#   restores the most recent backup directory matching $HOME/.config_backup_*.
# Globals:
#   HOME
# Arguments:
#   $1 - (optional) The path to the backup directory.
# Returns:
#   Exits with status 0 on success, or 1 if no valid backup is found.
#######################################
restore_backup() {
    local backup_dir_arg="$1"
    local backup_to_restore=""

    if [ -n "$backup_dir_arg" ]; then
         if [ -d "$backup_dir_arg" ]; then
             backup_to_restore="$backup_dir_arg"
         else
             echo "Specified backup directory '$backup_dir_arg' does not exist."
             exit 1
         fi
    else
         # Automatically select the most recent backup matching ~/.config_backup_*.
         backups=( "$HOME"/.config_backup_* )
         if [ ! -e "${backups[0]}" ]; then
             echo "No backup directories found in $HOME."
             exit 1
         fi
         backup_to_restore=$(ls -td "$HOME"/.config_backup_* | head -n 1)
         echo "Restoring from most recent backup: $backup_to_restore"
    fi

    # If current ~/.config exists, back it up first.
    if [ -d "$HOME/.config" ]; then
        local manual_backup="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
        echo "Current ~/.config exists. Moving it to $manual_backup..."
        mv "$HOME/.config" "$manual_backup"
    fi

    echo "Restoring backup from $backup_to_restore to $HOME/.config..."
    mv "$backup_to_restore" "$HOME/.config"
    echo "Restore complete. Your configuration is now in $HOME/.config."
    exit 0
}

# Define arrays of packages for installation.
PACMAN_PACKAGES=("base-devel" "cmake" "libconfig" "sdl2" "udev" "xorg-xprop" "xdotool" "xdo" "acpi" "acpi_call" "brightnessctl" "pamixer" "nerd-fonts" "font-manager" "kitty" "firefox" "git" "wget" "curl" "mesa" "less" "qt5" "qt6" "python-pyqt5" "python-pyqt6" "xorg-xrandr" "picom" "polybar" "rofi" "dunst" "polkit-gnome" "network-manager-applet" "blueman" "udisks2" "thunar" "gvfs" "xarchiver" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-shares-plugin" "thunar-volman" "tumbler" "libgsf" "webp-pixbuf-loader" "gvfs-mtp" "sshfs" "gvfs-smb" "udiskie" "flameshot" "dex" "xsel" "gnome-themes-extra" "default-cursors" "neofetch" "firewalld" "clipcat")
YAY_PACKAGES=("xkb-switch" "raw-thumbnailer" "tumbler-extra-thumbnailers" "libinput-gestures" "adwaita-qt6" "lite-xl" "lpm" "librewolf-bin" "simplescreenrecorder" "64gram-desktop")
GPU_OVERRIDE=""

#######################################
# Function: command_exists
# Description:
#   Checks whether a given command is available in the system's PATH.
# Arguments:
#   $1 - Command name to check.
# Returns:
#   0 if the command exists, 1 otherwise.
#######################################
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

#######################################
# Function: add_kernel_parameter
# Description:
#   Adds a kernel boot parameter to the bootloader configuration (GRUB or
#   systemd-boot). The function detects the bootloader and edits the respective
#   configuration file to include the parameter.
# Globals:
#   None
# Arguments:
#   $1 - The kernel parameter to add (e.g., "nvidia-drm.modeset=1").
# Returns:
#   Exits with status 1 if the bootloader cannot be determined.
#######################################
add_kernel_parameter() {
  local parameter="$1"
  local bootloader

  # Determine the bootloader based on available commands.
  if command_exists grub-mkconfig; then
    bootloader="grub"
  elif command_exists systemctl && systemctl | grep -q "\.mount.*\/boot"; then
    bootloader="systemd-boot"
  else
    echo "Error: Could not determine bootloader (GRUB or systemd-boot)."
    exit 1
  fi

  echo "Detected bootloader: $bootloader"

  if [[ "$bootloader" == "grub" ]]; then
    # Check if the parameter is already present.
    if ! grep -q "$parameter" /etc/default/grub; then
      sudo sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=.*\)\"/\1 $parameter\"/" /etc/default/grub
      echo "Updating GRUB configuration..."
      sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
      echo "Kernel parameter '$parameter' already exists in GRUB configuration."
    fi
  elif [[ "$bootloader" == "systemd-boot" ]]; then
    local entry_file
    entry_file=$(find /boot/loader/entries/ -name "*.conf" -print0 | xargs -0 grep -l "linux" | head -n 1)
    if [[ -z "$entry_file" ]]; then
      echo "Error: Could not find systemd-boot entry file."
      exit 1
    fi

    if ! grep -q "$parameter" "$entry_file"; then
      sudo sed -i "s/\(options.*\)/\1 $parameter/" "$entry_file"
      echo "Kernel parameter '$parameter' added to $entry_file"
    else
      echo "Kernel parameter '$parameter' already exists in $entry_file"
    fi
  fi
}

#######################################
# Function: blacklist_module
# Description:
#   Creates a modprobe blacklist configuration file for a given kernel module,
#   and sets an option to disable modeset.
# Globals:
#   None
# Arguments:
#   $1 - The name of the module to blacklist.
# Returns:
#   None
#######################################
blacklist_module() {
  local module="$1"
  local blacklist_file="/etc/modprobe.d/blacklist-${module}.conf"

  if [[ ! -f "$blacklist_file" ]]; then
    echo "Creating blacklist file: $blacklist_file"
    sudo bash -c "cat > $blacklist_file" <<EOF
blacklist $module
options $module modeset=0
EOF
  else
    echo "Blacklist file for $module already exists."
  fi
}

#######################################
# Function: setup_monitor_hotplug
# Description:
#   Sets up udev rules and a systemd service to handle monitor hotplug events.
#   It creates a udev rule to trigger the systemd service upon monitor changes and
#   ensures the monitor setup script exists.
# Globals:
#   HOME
# Arguments:
#   None
# Returns:
#   None
#######################################
setup_monitor_hotplug() {
    local username
    username=$(whoami)
    local udev_rule_file="/etc/udev/rules.d/99-monitor-hotplug.rules"
    local systemd_service_file="/etc/systemd/system/hotplug-monitor.service"
    local monitor_setup_script="/home/$username/.config/bspwm/scripts/monitor_setup.sh"

    # Create udev rule if it does not exist.
    if [[ ! -f "$udev_rule_file" ]]; then
        echo "Creating udev rule at $udev_rule_file..."
        sudo bash -c "cat > $udev_rule_file" <<EOF
ACTION=="change", SUBSYSTEM=="drm", RUN+="/usr/bin/systemctl restart hotplug-monitor.service"
EOF
        echo "Udev rule created."
    else
        echo "Udev rule already exists at $udev_rule_file."
    fi

    # Create systemd service file if it does not exist.
    if [[ ! -f "$systemd_service_file" ]]; then
        echo "Creating systemd service at $systemd_service_file..."
        sudo bash -c "cat > $systemd_service_file" <<EOF
[Unit]
Description=Monitor Hotplug Service

[Service]
Type=forking
User=$username
ExecStart=$monitor_setup_script
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
        echo "Systemd service file created."
    else
        echo "Systemd service file already exists at $systemd_service_file."
    fi

    echo "Reloading systemd daemon and enabling the service..."
    sudo systemctl daemon-reload
    sudo systemctl enable hotplug-monitor.service

    if [[ ! -f "$monitor_setup_script" ]]; then
        echo "Note: The monitor setup script does not exist at $monitor_setup_script."
        echo "Please create the script to handle monitor setup."
    else
        echo "Monitor setup script found at $monitor_setup_script."
    fi
    echo "Monitor hotplug setup completed. Reboot or replug monitors to test."
}

#######################################
# Function: install_pacman_packages
# Description:
#   Updates the system, installs a list of packages using pacman, and configures
#   various system services and environment variables.
# Globals:
#   PACMAN_PACKAGES
# Arguments:
#   None
# Returns:
#   None
#######################################
install_pacman_packages() {
  echo "Installing pacman packages: ${PACMAN_PACKAGES[*]}"
  sudo pacman -Syu --noconfirm
  for pkg in "${PACMAN_PACKAGES[@]}"; do
    sudo pacman -S --noconfirm --needed "$pkg"
  done

  # Enable required system services.
  sudo systemctl enable bluetooth.service
  sudo systemctl enable firewalld.service
  systemctl --user enable --now clipmon

  # Append environment variables to /etc/environment if not already set.
  local environment_file="/etc/environment"
  local entries=(
      "GTK_THEME=Adwaita:dark"
      "GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc"
      "QT_STYLE_OVERRIDE=Adwaita-dark"
      "XDG_CURRENT_DESKTOP=BSPMW"
  )

  for entry in "${entries[@]}"; do
    if ! grep -qF "$entry" "$environment_file"; then
      echo "$entry" >> "$environment_file"
    fi
  done

  # Install additional software (lwp) from its repository.
  echo "Installing lwp."
  git clone https://github.com/jszczerbinsky/lwp /tmp/lwp
  cd /tmp/lwp || exit

  mkdir build
  cd build || exit

  cmake ../
  cmake --build .
  cpack

  archive_name=$(find . -name "*.tar.gz" -print -quit)

  if [ -z "$archive_name" ]; then
    echo "Error: No .tar.gz archive found after cpack."
    exit 1
  fi

  echo "Extracting archive: $archive_name"
  sudo tar -o -xvf "$archive_name" -C /usr/local

  echo "lwp installation complete (or extraction complete)."
}

#######################################
# Function: install_yay
# Description:
#   Installs the AUR helper "yay" if it is not already installed.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
install_yay() {
  if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay || exit
    makepkg -si --noconfirm
    cd - || exit
    rm -rf /tmp/yay
  else
    echo "yay is already installed."
  fi
}

#######################################
# Function: install_yay_packages
# Description:
#   Installs a list of packages from the AUR using yay.
# Globals:
#   YAY_PACKAGES
# Arguments:
#   None
# Returns:
#   None
#######################################
install_yay_packages() {
  echo "Installing yay packages: ${YAY_PACKAGES[*]}"
  for pkg in "${YAY_PACKAGES[@]}"; do
    yay -S --noconfirm --needed "$pkg"
  done
}

#######################################
# Function: check_nvidia_gpu_and_install_drivers
# Description:
#   Detects if an NVIDIA GPU is present using lspci and installs the appropriate
#   NVIDIA drivers based on the GPU model. It configures mkinitcpio, adds kernel
#   parameters, and blacklists the nouveau driver. A GPU override can be provided
#   via command-line.
# Globals:
#   GPU_OVERRIDE
# Arguments:
#   None
# Returns:
#   None
#######################################
check_nvidia_gpu_and_install_drivers() {
  GPU_INFO=$(lspci | grep -i "nvidia")
  GPU_NUMBER=""

  if [[ -n "$GPU_INFO" ]]; then
    echo "NVIDIA GPU detected: $GPU_INFO"

    if [[ -n "$GPU_OVERRIDE" ]]; then
      GPU_NUMBER=$GPU_OVERRIDE
    else
      # Dummy extraction of GPU model for demonstration purposes.
      # Replace the following line with actual extraction logic as needed.
      GPU_MODEL=$(echo "NVIDIA Corporation GA104M [Some crap" | grep -oP 'NVIDIA Corporation \K.*?(?=\s|\[)')
      PREFIX=$(echo "$GPU_MODEL" | grep -oP '^[A-Z]+')

      # Determine GPU_NUMBER based on GPU model prefix.
      case $PREFIX in
        AD)
          GPU_NUMBER=190
          ;;
        NV)
          GPU_NUMBER=$(echo "$GPU_MODEL" | grep -oP '(?<=NV)\d+')
          ;;
        GA)
          GPU_NUMBER=170
          ;;
        TU)
          GPU_NUMBER=160
          ;;
        GV)
          GPU_NUMBER=140
          ;;
        GP)
          GPU_NUMBER=130
          ;;
        GM)
          GPU_NUMBER=110
          ;;
        GK|GF)
          GPU_NUMBER=100
          ;;
        GT)
          GPU_NUMBER=50
          ;;
        MCP)
          GPU_NUMBER=40
          ;;
        *)
          echo "Warning: Unrecognized GPU prefix $PREFIX. Cannot determine driver."
          return
          ;;
      esac

      echo "GPU Model: $GPU_MODEL"
      echo "Derived GPU Number: $GPU_NUMBER"
    fi

    # Install drivers based on the derived GPU number.
    if [[ $GPU_NUMBER -ge 160 ]]; then
      echo "Installing nvidia-open-dkms for Turing or newer GPUs... (>= GTX 1650)"
      sudo pacman -S --noconfirm --needed nvidia-open-dkms nvidia-settings nvidia-utils lib32-nvidia-utils nvtop opencl-nvidia
    elif [[ $GPU_NUMBER -ge 110 ]]; then
      echo "Installing nvidia-dkms for Maxwell to Ada Lovelace GPUs... (>= GTX 745)"
      sudo pacman -S --noconfirm --needed nvidia-dkms nvidia-settings nvidia-utils lib32-nvidia-utils nvtop opencl-nvidia
    elif [[ $GPU_NUMBER -ge 50 ]]; then
      echo "Installing nvidia-470xx-dkms for Kepler GPUs... (>= GeForce 8800)"
      yay -S --noconfirm nvidia-470xx-dkms nvidia-settings nvidia-utils lib32-nvidia-utils nvtop opencl-nvidia
    elif [[ $GPU_NUMBER -ge 40 ]]; then
      echo "Installing nvidia-390xx-dkms for Fermi GPUs... (>= GeForce 6800)"
      yay -S --noconfirm nvidia-390xx-dkms nvidia-settings nvidia-utils lib32-nvidia-utils nvtop opencl-nvidia
    elif [[ $GPU_NUMBER -ge 30 ]]; then
      echo "Installing nvidia-340xx-dkms for Tesla GPUs... (>= GeForce FX 5800)"
      yay -S --noconfirm nvidia-340xx-dkms nvidia-settings nvidia-utils lib32-nvidia-utils nvtop opencl-nvidia
    else
      echo "No suitable driver found for your GPU family."
      return
    fi

    # Configure mkinitcpio to include necessary NVIDIA modules.
    echo "Configuring mkinitcpio..."
    sudo sed -i 's/^\(MODULES=.*\)(.*)$/\1nvidia nvidia_modeset nvidia_uvm nvidia_drm\2/' /etc/mkinitcpio.conf

    sudo sed -i 's/\(HOOKS=.*\)filesystems/\1kms filesystems/' /etc/mkinitcpio.conf

    echo "Regenerating initramfs..."
    sudo mkinitcpio -P

    echo "Adding kernel parameter for NVIDIA DRM modesetting..."
    add_kernel_parameter "nvidia-drm.modeset=1"

    echo "Blacklisting nouveau driver..."
    blacklist_module "nouveau"

    # Create an Xorg configuration file to set NVIDIA as the primary GPU.
    local config_file="/etc/X11/xorg.conf.d/10-nvidia-primary.conf"

    if [ ! -f "$config_file" ]; then
        echo "Creating Xorg configuration file at $config_file..."
        sudo tee "$config_file" > /dev/null <<EOF
Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "PrimaryGpu" "yes"
EndSection
EOF
        echo "Xorg configuration file created."
    else
        echo "Xorg configuration file already exists at $config_file."
    fi

  else
    echo "No NVIDIA GPU detected."
  fi
}

#######################################
# Function: show_help
# Description:
#   Displays the help message with usage instructions.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --gpu <number>         Override GPU version check with a specific number."
  echo "  --restore [path]       Restore backup of ~/.config. If [path] is not provided, the most recent backup matching ~/.config_backup_* is used."
  echo "  --help, -h             Show this help message and exit."
}

#######################################
# Function: main
# Description:
#   Main entry point for the script. Parses command-line arguments, then calls
#   the necessary functions to clone the configuration repository, set up monitor
#   hotplugging, install packages, and install GPU drivers.
# Globals:
#   GPU_OVERRIDE
# Arguments:
#   Command-line arguments passed to the script.
# Returns:
#   None
#######################################
main() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --gpu)
        GPU_OVERRIDE=$2
        shift 2
        ;;
      --restore)
        # If a backup path is provided, pass it to restore_backup; otherwise, use an empty string.
        if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
          restore_backup "$2"
          shift 2
        else
          restore_backup ""
          shift 1
        fi
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done

  # Run the various setup functions sequentially.
  check_and_clone_config_directory
  setup_monitor_hotplug
  install_pacman_packages
  install_yay
  install_yay_packages
  check_nvidia_gpu_and_install_drivers

  echo "All tasks completed successfully."
}

# Execute the main function with all passed arguments.
main "$@"

