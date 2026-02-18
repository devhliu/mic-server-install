# Fixing Deferred Package Upgrade in Ubuntu WSL2

To resolve the deferred upgrade for cloud-init, you can try these solutions in sequence:

1. First, try forcing the upgrade:

```bash
sudo apt-get install --no-install-recommends cloud-init
```

2. If that doesn't work, try updating the package lists and upgrading again:

```bash
sudo apt-get update && sudo apt-get dist-upgrade
```

3. If the issue persists, you can try to remove and reinstall cloud-init:

```bash
sudo apt-get remove cloud-init
sudo apt-get install cloud-init
```

4. If you don't need cloud-init (it's generally not required in WSL2), you can safely remove it:

```bash
sudo apt-get remove cloud-init
sudo apt-get autoremove
```

5. After any of these steps, clean up the package cache:

```bash
sudo apt-get clean
sudo apt-get autoclean
```

Choose the solution that best fits your needs. If you're using WSL2 for development, option 4 (removing cloud-init) is often the simplest solution as this package is primarily used for cloud instance initialization and isn't necessary for local development environments.

# LATEX
sudo apt install texlive-pictures texlive-science texlive-latex-extra latexmk