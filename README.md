# ansible-workstations

The purpose of this repository is to provide a set of Ansible playbooks for setting up workstations, specifically designed for my personal use. It requires specific files to be placed on SMB storage, such as the database backup. Please note that this source code might still be found useful by others despite its personal origins and requirements.

## Prerequisites

- installed ansible
- Created file called inventory.ini with the following content:

```
[main_workstation]
192.168.123.123 ansible_user='user' ansible_sudo_pass='pass'

```

## Usage

For proper samba setup please adjust configuration files for [data storage](samba_data/vars/main.yml) and [photos storage](samba_photos/vars/main.yml) and [setup database](roles/setup_database/vars/main.yml).

Run command to run the playbook: ```ansible-playbook -i inventory.ini main_workstation.yml```.

## Main Workstation

[main_workstation.yml](main_workstation.yml) describes configuration of main workstation.

## Roles

### ping

Test connectivity using `ping`.

### firewall

Configure firewall rules to restrict incoming connections.

### upgrade

Upgrade the system packages to latest version.

### standard_packages

Install essential packages for a workstation.

### samba_data

Configure Samba storage for data.

### samba_photos

Configure Samba storage for photos.

### pycharm

Install PyCharm IDE.

### setup_pycharm_projects

Clone PyCharm project related repositories.

### ollama

(Note: There is no role named 'ollama' under the specified directory. Please check the actual contents of the directory.)

### android_studio

Install Android Studio IDE.

### setup_android_projects

Clone Android Studio project related repositories.

### keepassxc

Install KeePassXC password manager.

### snort

Install Snort intrusion detection system.

### opensnitch

Install OpenSnitch network monitoring tool.

### setup_database

Create and configure a database for development environment of Lingua Sytes.
