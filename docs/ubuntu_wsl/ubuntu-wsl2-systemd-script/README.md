# ubuntu-wsl2-systemd-script
Script to enable systemd support on current Ubuntu WSL2 images from the Windows store. 
Script is unsupported and will no longer be maintained, but will be up here because it is used by quite some people.
I am not responsible for broken installations, fights with your roommates and police ringing your door ;-).

Instructions from [the snapcraft forum](https://forum.snapcraft.io/t/running-snaps-on-wsl2-insiders-only-for-now/13033) turned into a script. Thanks to [Daniel](https://forum.snapcraft.io/u/daniel) on the Snapcraft forum! 

## Usage
You need ```git``` to be installed for the commands below to work. Use
```sh
sudo apt install git
```
to do so.
### Run the script and commands
```sh
git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git
cd ubuntu-wsl2-systemd-script/
bash ubuntu-wsl2-systemd-script.sh
# Enter your password and wait until the script has finished
```
### Then restart the Ubuntu shell and try running systemctl
```sh
systemctl

```
If you don't get an error and see a list of units, the script worked.

Have fun using systemd on your Ubuntu WSL2 image. You may use and change and distribute this script in whatever way you'd like. 


# Adding and Updating Username and Password for Ubuntu 24.04 LTS in WSL2

To add a new user or update the password for an existing user in your Ubuntu 24.04 LTS running on WSL2, you can follow these steps:

## Adding a New User

1. Open your WSL2 Ubuntu terminal and use the following commands:

```bash
# Add a new user
sudo adduser newusername

# Follow the prompts to set password and user information
```

2. To give the new user sudo privileges:

```bash
# Add the user to the sudo group
sudo usermod -aG sudo newusername
```

3. To switch to the new user:

```bash
su - newusername
```

## Updating Password for Existing User

1. To change your own password:

```bash
passwd
```

2. To change another user's password (requires sudo):

```bash
sudo passwd username
```

## Setting Default User for WSL2

If you want to change the default user that logs in when you start your WSL2 Ubuntu:

1. Open PowerShell or Command Prompt as Administrator
2. Run the following command:

```powershell
wsl --user newusername
```

3. To make this change permanent, you can set the default user in the WSL configuration:

```powershell
wsl --distribution Ubuntu-24.04 --user newusername
```

4. Alternatively, you can edit the WSL configuration file:

```powershell
wsl --terminate Ubuntu-24.04
ubuntu2404 config --default-user newusername
```

Remember that when changing passwords in WSL2, you'll need to use strong passwords that meet Ubuntu's security requirements, typically including a mix of uppercase and lowercase letters, numbers, and special characters.