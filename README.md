# ansible-workstations

The purpose of this repository is to provide a set of Ansible playbooks for setting up workstations.

## Prerequisites

- installed ansible
- Created file called inventory.ini with the following content:

```
[main_workstation]
192.168.123.123 ansible_user='user' ansible_sudo_pass='pass'

```

## Usage

For proper samba setup please adjust configuration file [main.yml](samba_data/vars/main.yml).

Run command to run the playbook: ```ansible-playbook -i inventory.ini main_workstation.yml```.

## Main Workstation

[main_workstation.yml](main_workstation.yml) describes configuration of main workstation.
