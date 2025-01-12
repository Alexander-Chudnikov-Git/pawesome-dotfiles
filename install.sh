#!/bin/bash

PACMAN_PACKAGES=("base-devel" "cmake" "libconfig" "sdl2" "udev" "xorg-xprop" "xdotool" "xdo" "acpi" "acpi_call" "brightnessctl" "pamixer" "nerd-fonts" "font-manager" "kitty" "firefox" "git" "wget" "curl" "mesa" "less" "qt5" "qt6" "python-pyqt5" "python-pyqt6" "xorg-xrandr" "picom" "polybar" "rofi" "dunst" "polkit-gnome" "network-manager-applet" "blueman" "udisks2" "thunar" "gvfs" "xarchiver" "thunar-archive-plugin" "thunar-media-tags-plugin" "thunar-shares-plugin" "thunar-volman" "tumbler" "libgsf" "webp-pixbuf-loader" "gvfs-mtp" "sshfs" "gvfs-smb" "udiskie" "flameshot" "dex" "xclip" "xsel" "gnome-themes-extra" "default-cursors" "neofetch" "firewalld")
YAY_PACKAGES=("xkb-switch" "clipmon-git" "raw-thumbnailer" "tumbler-extra-thumbnailers" "libinput-gestures" "adwaita-qt6" "lite-xl" "lpm" "librewolf-bin" "simplescreenrecorder" "64gram-desktop")
GPU_OVERRIDE=""

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

add_kernel_parameter() {
  local parameter="$1"
  local bootloader

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
    if ! grep -q "$parameter" /etc/default/grub; then
      sudo sed -i "s/\(GRUB_CMDLINE_LINUX_DEFAULT=.*\)\"/\1 $parameter\"/" /etc/default/grub
      echo "Updating GRUB configuration..."
      sudo grub-mkconfig -o /boot/grub/grub.cfg
    else
      echo "Kernel parameter '$parameter' already exists in GRUB configuration."
    fi
  elif [[ "$bootloader" == "systemd-boot" ]]; then
    local entry_file=$(find /boot/loader/entries/ -name "*.conf" -print0 | xargs -0 grep -l "linux" | head -n 1)
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

setup_monitor_hotplug() {
    local username
    username=$(whoami)
    local udev_rule_file="/etc/udev/rules.d/99-monitor-hotplug.rules"
    local systemd_service_file="/etc/systemd/system/hotplug-monitor.service"
    local monitor_setup_script="/home/$username/.config/bspwm/scripts/monitor_setup.sh"

    if [[ ! -f "$udev_rule_file" ]]; then
        echo "Creating udev rule at $udev_rule_file..."
        sudo bash -c "cat > $udev_rule_file" <<EOF
ACTION=="change", SUBSYSTEM=="drm", RUN+="/usr/bin/systemctl restart hotplug-monitor.service"
EOF
        echo "Udev rule created."
    else
        echo "Udev rule already exists at $udev_rule_file."
    fi

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

install_pacman_packages() {
  echo "Installing pacman packages: ${PACMAN_PACKAGES[*]}"
  sudo pacman -Syu --noconfirm
  for pkg in "${PACMAN_PACKAGES[@]}"; do
    sudo pacman -S --noconfirm --needed "$pkg"
  done

  sudo systemctl enable bluetooth.service
  sudo systemctl enable firewalld.service
  systemctl --user enable --now clipmon

  local environment_file="/etc/environment"
  local entries=(
      "GTK_THEME=Adwaita:dark"
      "GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc"
      "QT_STYLE_OVERRIDE=Adwaita-dark"
      "XDG_CURRENT_DESKTOP=KDE"
  )

  for entry in "${entries[@]}"; do
    if ! grep -qF "$entry" "$environment_file"; then
      echo "$entry" >> "$environment_file"
    fi
  done

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

install_yay_packages() {
  echo "Installing yay packages: ${YAY_PACKAGES[*]}"
  for pkg in "${YAY_PACKAGES[@]}"; do
    yay -S --noconfirm --needed "$pkg"
  done
}

check_nvidia_gpu_and_install_drivers() {
  GPU_INFO=$(lspci | grep -i "nvidia")
  GPU_NUMBER=""

  if [[ -n "$GPU_INFO" ]]; then
    echo "NVIDIA GPU detected: $GPU_INFO"

    if [[ -n "$GPU_OVERRIDE" ]]; then
      GPU_NUMBER=$GPU_OVERRIDE
    else
      GPU_MODEL=$(echo "NVIDIA Corporation GA104M [Some crap" | grep -oP 'NVIDIA Corporation \K.*?(?=\s|\[)')
      PREFIX=$(echo "$GPU_MODEL" | grep -oP '^[A-Z]+')

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

    echo "Configuring mkinitcpio..."
    sudo sed -i 's/^\(MODULES=.*\)(.*)$/\1nvidia nvidia_modeset nvidia_uvm nvidia_drm\2/' /etc/mkinitcpio.conf

    sudo sed -i 's/\(HOOKS=.*\)filesystems/\1kms filesystems/' /etc/mkinitcpio.conf

    echo "Regenerating initramfs..."
    sudo mkinitcpio -P

    echo "Adding kernel parameter for NVIDIA DRM modesetting..."
    add_kernel_parameter "nvidia-drm.modeset=1"

    echo "Blacklisting nouveau driver..."
    blacklist_module "nouveau"

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

show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --gpu <number>     Override GPU version check with a specific number."
  echo "  --help, -h         Show this help message and exit."
}

main() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      --gpu)
        GPU_OVERRIDE=$2
        shift 2
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

  setup_monitor_hotplug
  install_pacman_packages
  install_yay
  install_yay_packages

  check_nvidia_gpu_and_install_drivers

  echo "All tasks completed successfully."
}

main "$@"

