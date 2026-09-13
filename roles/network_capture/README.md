# Network Capture Role

This Ansible role deploys a continuous network traffic capture service on the control server using SSH pipe technology. The service captures traffic from a remote server via encrypted SSH and saves it locally. **By default, SSH traffic is excluded to avoid capturing the control channel.**

## Overview

The role deploys a systemd service that continuously captures network traffic from a remote server using SSH pipes, processes it locally with tcpdump, truncates packets with editcap, and saves timestamped PCAP files.

### Pipeline Architecture

```
Remote Server                Control Server (systemd service)
┌──────────────┐            ┌──────────────────┐
│   tcpdump    │            │   SSH pipe       │
│  (capture)   │─── SSH ────│   tcpdump filter │
│  (filtered)  │(encrypted) │       │          │
└──────────────┘            │   editcap        │
                           │ (truncate)       │
                           │       │          │
                           │ capture_*.pcap   │
                           │ (timestamped)    │
                           └──────────────────┘
```

## Key Features

- 🔒 **SSH Encrypted**: All traffic transmitted over encrypted SSH
- ✂️ **Packet Truncation**: Optional packet size limiting via editcap
- 🔍 **BPF Filters**: Flexible Berkeley Packet Filter syntax
- ❌ **SSH Excluded**: By default excludes control channel traffic (port 22)
- 🔄 **Continuous Service**: Runs as systemd service with auto-restart
- ⏰ **Timestamped Files**: Creates `capture_<timestamp>.pcap` files
- 📦 **Local Processing**: All processing on control server

## Usage

### Deploy via Ansible

```yaml
- hosts: control_servers
  vars:
    target_server: "remote.example.com"
    ssh_user: "capture_user"
    ssh_key: "/home/user/.ssh/id_rsa"
    capture_interface: "eth0"
    packet_truncation: 100
    capture_output_dir: "/opt/network-capture"
  roles:
    - network-capture
```

### Service Management

Once deployed, manage the service like any systemd service:

```bash
# View service status
sudo systemctl status network-capture

# View logs
sudo journalctl -u network-capture -f

# Stop the service
sudo systemctl stop network-capture

# Restart the service
sudo systemctl restart network-capture

# View captured files
ls -lah /opt/network-capture/
```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `target_server` | Remote server IP or hostname | `192.168.1.100` |
| `ssh_user` | SSH username on remote server | `root` |
| `ssh_key` | Path to SSH private key on control server | `/home/user/.ssh/id_rsa` |
| `capture_interface` | Network interface to capture on | `eth0` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ssh_port` | SSH port on remote server | `22` |
| `packet_truncation` | Truncate packets to N bytes (0 = no truncation) | `100` |
| `capture_output_dir` | Local directory for PCAP files | `/opt/network-capture` |
| `capture_filter` | BPF filter (excludes SSH by default) | `not tcp port {{ ssh_port }} and not udp port {{ ssh_port }}` |

### SSH Exclusion

By default, the capture filter excludes SSH traffic:

```yaml
# Default behavior (excludes SSH)
capture_filter: "not tcp port {{ ssh_port }} and not udp port {{ ssh_port }}"
```

To capture all traffic including SSH:

```yaml
capture_filter: ""  # Empty filter captures everything
```

### Custom BPF Filters

Override the default filter for specific traffic capture:

```yaml
# HTTP/HTTPS only
capture_filter: "(tcp port 80 or tcp port 443) and not tcp port {{ ssh_port }}"

# Specific host only (excluding SSH)
capture_filter: "dst 10.0.0.5 and not tcp port {{ ssh_port }}"

# TCP SYN packets (excluding SSH)
capture_filter: "tcp.flags.syn==1 and not tcp port {{ ssh_port }}"

# DNS traffic
capture_filter: "udp port 53"
```

## Requirements

### On Control Server (Ansible host)
- `tcpdump` - for reading and processing captured packets
- `wireshark-common` - provides `editcap` utility
- `openssh-client` - for SSH connections
- systemd - for service management
- Root/sudo access for systemd service deployment

### On Remote Server (target)
- `tcpdump` - for capturing packets
- `sudo` privileges for tcpdump execution

## Installation

Install required packages on control server:

```bash
# Debian/Ubuntu
sudo apt-get install tcpdump wireshark-common openssh-client

# RHEL/CentOS
sudo yum install tcpdump wireshark openssh-clients

# Alpine
apk add tcpdump wireshark openssh-client
```

## Advanced Usage

### Monitoring Captures

```bash
# Real-time log monitoring
sudo journalctl -u network-capture -f

# Check for errors
sudo journalctl -u network-capture -p err

# Service status with auto-refresh
watch sudo systemctl status network-capture
```

### Analyzing Captures

```bash
# View captures directory
ls -lah /opt/network-capture/

# Merge multiple PCAP files
mergecap -w merged.pcap capture_*.pcap

# Extract HTTP traffic from latest capture
tshark -r /opt/network-capture/capture_*.pcap -f "tcp port 80" -w http_only.pcap

# Protocol statistics
tshark -r /opt/network-capture/capture_*.pcap -z protocol,tree

# Convert to CSV
tshark -r /opt/network-capture/capture_*.pcap -T fields -E header=y -E separator=, > analysis.csv
```

### Multiple Captures

Deploy separate instances for different interfaces or remote servers:

```yaml
- name: Deploy capture from remote1
  include_role:
    name: network-capture
  vars:
    target_server: "remote1.example.com"
    capture_output_dir: "/opt/network-capture/remote1"
    capture_interface: "eth0"

- name: Deploy capture from remote2
  include_role:
    name: network-capture
  vars:
    target_server: "remote2.example.com"
    capture_output_dir: "/opt/network-capture/remote2"
    capture_interface: "eth1"
```

### Large Captures with Low Bandwidth

Use aggressive truncation to reduce file size:

```yaml
packet_truncation: 64  # Capture only headers (~64 bytes)
capture_filter: "tcp port 80"  # Filter for specific protocol
```

## Security Considerations

1. **Private Key**: Store SSH private keys securely; consider using Ansible Vault
   ```bash
   ansible-vault encrypt roles/network-capture/vars/secret.yml
   ```

2. **Sudo Access**: Remote user needs sudo access for tcpdump
   ```bash
   echo "user ALL=(ALL) NOPASSWD: tcpdump" | sudo tee -a /etc/sudoers.d/tcpdump
   ```

3. **Network Traffic**: Data is transmitted over SSH with full encryption

4. **Storage**: PCAP files may contain sensitive data; secure storage:
   ```bash
   chmod 700 /opt/network-capture/
   ```

5. **SSH Exclusion**: Default filter excludes control channel to prevent self-capture

6. **Service Permissions**: Service runs as root for packet capture privileges

## Troubleshooting

### Service Won't Start

```bash
# Check service status and errors
sudo systemctl status network-capture
sudo journalctl -u network-capture -n 50

# Verify systemd file syntax
sudo systemd-analyze verify /etc/systemd/system/network-capture.service
```

### SSH Connection Issues

```bash
# Test SSH connectivity
ssh -i /path/to/key -v user@remote "sudo tcpdump -h"

# If using non-standard port
ssh -i /path/to/key -v -p 2222 user@remote "sudo tcpdump -h"

# Check SSH key permissions
ls -la /path/to/key
chmod 600 /path/to/key
```

### Permission Denied

```bash
# Verify sudo access on remote
ssh user@remote "sudo tcpdump -i eth0 -c 1"

# Configure passwordless sudo if needed
echo "user ALL=(ALL) NOPASSWD: tcpdump" | sudo tee -a /etc/sudoers.d/tcpdump

# Make systemd service has access to SSH key
ls -la /path/to/ssh/key
sudo chown root:root /path/to/ssh/key
sudo chmod 600 /path/to/ssh/key
```

### No Captures Being Created

```bash
# Check service is running
sudo systemctl is-active network-capture

# View recent logs
sudo journalctl -u network-capture -n 20

# Check if capture directory exists and is writable
ls -ld /opt/network-capture/
sudo chmod 755 /opt/network-capture/

# Test manual capture
ssh -i /path/to/key user@remote "sudo tcpdump -i eth0 -c 5"
```

### Large PCAP Files

Reduce file size with packet truncation:

```yaml
packet_truncation: 64  # Headers only
# OR filter for specific traffic
capture_filter: "(tcp port 80 or tcp port 443) and not tcp port {{ ssh_port }}"
```

### Verifying Correct Filter

Test the BPF filter before deployment:

```bash
# Local test
tcpdump -i eth0 'not tcp port 22' -c 5

# Remote test via SSH
ssh user@remote "sudo tcpdump -i eth0 'not tcp port 22' -c 5"
```

## Output Analysis

Timestamped PCAP files are saved in `capture_output_dir`:

```bash
# List captures
ls -lh /opt/network-capture/capture_*.pcap

# View recent capture
tcpdump -r /opt/network-capture/capture_*.pcap | head -20

# Import into Wireshark
wireshark /opt/network-capture/capture_*.pcap

# Analyze with tshark
tshark -r /opt/network-capture/capture_*.pcap -z io,stat,1

# Extract to CSV
tshark -r /opt/network-capture/capture_*.pcap -T fields -E header=y -E separator=, > capture.csv
```

## File Structure

```
/opt/network-capture/
├── capture_1720779140.pcap      # Timestamped capture file
├── capture_1720779540.pcap      # Another capture
└── capture_1720779940.pcap      # Latest capture
```

Timestamps are Unix epoch seconds (seconds since 1970-01-01 UTC).

## Service Restart Behavior

The service uses `Restart=always` with `RestartSec=5`, which means:
- If the capture process exits, it automatically restarts after 5 seconds
- `StartLimitBurst=5` allows up to 5 restarts
- `StartLimitIntervalSec=60` within a 60-second window
- After 5 failures in 60 seconds, manual `systemctl start` is required
