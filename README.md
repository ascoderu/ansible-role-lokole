# Ansible Role: Lokole

[![CI](https://github.com/ascoderu/ansible-role-lokole/workflows/CI/badge.svg)](https://github.com/ascoderu/ansible-role-lokole/actions)

Canonical Ansible role for deploying [Lokole](https://github.com/ascoderu/lokole) offline email system. This role serves as the **single source of truth** for Lokole configuration in Internet-in-a-Box (IIAB) and standalone deployments.

## About Lokole

Lokole is an offline email client developed by [Ascoderu](https://ascoderu.ca), a Canadian-Congolese non-profit. It provides simple email functionality for communities with limited internet connectivity.

**Features:**
- Self-service account creation
- Rich text email composition
- File attachments
- Multi-language support (French, Lingala, and more)
- Optional internet sync via USB modem, SIM card, or Ethernet

## Requirements

- **Ansible**: >= 2.11
- **Supported Platforms**:
  - Ubuntu 22.04 (Jammy), 24.04 (Noble), 26.04 (Oracular)
  - Debian 12 (Bookworm), 13 (Trixie)
  - Raspberry Pi OS
- **Python**: 3.9+ on target system
- **Supervisor**: For service management
- **NGINX** or **Apache**: For web proxy

## Role Variables

See [docs/VARIABLES.md](docs/VARIABLES.md) for complete documentation.

### Essential Variables

```yaml
lokole_install: True              # Enable installation
lokole_enabled: True              # Enable services
lokole_sim_type: LocalOnly        # Connection type: LocalOnly, Ethernet, hologram, mkwvconf
lokole_admin_user: admin          # Default admin username
lokole_admin_password: changeme   # Default admin password (CHANGE THIS!)
```

### Installation Sources

```yaml
# Option 1: Latest from PyPI (default)
# No additional variables needed

# Option 2: Specific PyPI version
lokole_version: "0.5.10"

# Option 3: Git commit (for development/testing)
lokole_commit: "abc123def456..."  # 40-char SHA
lokole_repo: https://github.com/ascoderu/lokole.git
```

**Priority**: `lokole_commit` > `lokole_version` > latest PyPI

### Paths and Configuration

```yaml
lokole_install_path: /library/lokole
lokole_user: lokole
lokole_url: /lokole
```

## Dependencies

When used within IIAB:
- `pylibs` role (provides shared Python utilities)

## Example Playbooks

### Standalone Deployment

```yaml
---
- hosts: email_servers
  become: yes
  roles:
    - role: ascoderu.lokole
      lokole_install: True
      lokole_enabled: True
      lokole_sim_type: LocalOnly
      lokole_admin_password: "{{ vault_lokole_password }}"
```

### IIAB Integration

```yaml
---
- hosts: localhost
  connection: local
  become: yes
  roles:
    - role: ascoderu.lokole
      when: lokole_install is defined and lokole_install
```

### Development Testing (Specific Commit)

```yaml
---
- hosts: test_servers
  become: yes
  roles:
    - role: ascoderu.lokole
      lokole_install: True
      lokole_enabled: True
      lokole_commit: "a1b2c3d4e5f6..."  # Your feature branch commit
      lokole_repo: https://github.com/yourfork/lokole.git
```

## Testing

### Simple Tests (IIAB-style)

```bash
# Run basic role test
ansible-playbook tests/test.yml

# Verify installation
./tests/verify.sh
```

### Molecule Tests (Optional)

```bash
# Install molecule
pip install molecule molecule-docker

# Run tests
molecule test

# Test specific platform
molecule test --platform-name ubuntu2404
```

See [docs/TESTING.md](docs/TESTING.md) for details.

## Usage

After installation, access Lokole at:
- **URL**: http://your-server/lokole
- **Admin account**: `Admin` (username) / `changeme` (password)

### Administration Tasks

```bash
# Create admin account
cd /library/lokole/venv
./python3 ./manage.py createadmin -n username -p password

# Reset database
./python3 ./manage.py resetdb
```

## Integration Testing

This role is tested via the [iiab-lokole-tests](https://github.com/ascoderu/iiab-lokole-tests) repository, which validates:
- Fresh IIAB installations
- Lokole upgrades
- Multiple Ubuntu LTS versions
- Physical Raspberry Pi hardware

## License

Apache License 2.0

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

- **Issues**: https://github.com/ascoderu/lokole/issues
- **Role Issues**: https://github.com/ascoderu/ansible-role-lokole/issues
- **IIAB Issues**: https://github.com/iiab/iiab/issues

## Author

Maintained by [Ascoderu](https://ascoderu.ca).

Originally part of [Internet-in-a-Box](https://github.com/iiab/iiab) project.
