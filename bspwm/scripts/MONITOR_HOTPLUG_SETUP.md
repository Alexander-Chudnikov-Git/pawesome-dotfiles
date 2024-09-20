# Monitor Hotplug Setup

## Step 1: Create a udev Rule for Monitor Hotplug

Create a file at `/etc/udev/rules.d/99-monitor-hotplug.rules` with the following content. This rule triggers a systemd service to restart when a monitor change is detected.

```bash
# /etc/udev/rules.d/99-monitor-hotplug.rules

# When a monitor change is detected in the drm subsystem, restart the hotplug-monitor service
ACTION=="change", SUBSYSTEM=="drm", RUN+="/usr/bin/systemctl restart hotplug-monitor.service"
```

## Step 2: Set Up the Systemd Service

Create a systemd service file at /etc/systemd/system/hotplug-monitor.service with the following content. This service handles monitor setup and is triggered by the udev rule.
```bash
# /etc/systemd/system/hotplug-monitor.service

[Unit]
Description=Monitor Hotplug Service

[Service]
Type=forking
User=<USERNAME>
ExecStart=/home/<USERNAME>/.config/bspwm/scripts/monitor_setup.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

Replace <USERNAME> with your actual username in both files. This configuration ensures that your monitor setup script runs whenever a monitor change event is detected.
