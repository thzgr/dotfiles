#!/bin/bash

CDY="$(echo $PWD)"
CURRENT_USER="$(echo $USER)"

echo "Current directory: $CDY"
echo "Current user: $CURRENT_USER"

echo "# # # # # # # # #"
echo "# Github setup  #"
echo "# # # # # # # # #"
read -p "Email address: " myEmailAddress
read -p "Github username: " githubUserName
read -sp "Github token: " ghToken

echo "deb http://deb.volian.org/volian/ scar main" | sudo tee /etc/apt/sources.list.d/volian-archive-scar-unstable.list
wget -qO - https://deb.volian.org/volian/scar.key | sudo tee /etc/apt/trusted.gpg.d/volian-archive-scar-unstable.gpg > /dev/null
echo "deb-src http://deb.volian.org/volian/ scar main" | sudo tee -a /etc/apt/sources.list.d/volian-archive-scar-unstable.list

sudo apt update && sudo apt install nala -y

sudo nala upgrade -y

# Install VSCodium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list

sudo nala update && sudo nala install codium -y

# Copy Codium config file
sudo mkdir /home/$CURRENT_USER/.config/VSCodium
sudo mkdir /home/$CURRENT_USER/.config/VSCodium/User
sudo cp $CDY/VSCodium/product.json /home/$CURRENT_USER/.config/VSCodium/
sudo cp $CDY/VSCodium/User/* /home/$CURRENT_USER/.config/VSCodium/User/

# Check if flatpak is installed, if not install
if ! [ -x "$(command -v flatpak)" ]; then
	echo 'ERROR: Flatpak is not installed.' >&2
	echo 'Installing Flatpak...'
	sudo nala install flatpak
	flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
	echo 'Flatpak is installed!'
else
	flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
	echo 'Flatpak is installed!' >&2
fi

# Install some softwares via apt
sudo nala install apt-transport-https ca-certificates gnupg lsb-release fonts-powerline lm-sensors -y
sudo nala install xdotool xclip gnome-tweaks firefox git wget curl -y
sudo nala install texlive latexmk chktex -y

# Install GH CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo nala update && sudo nala install gh -y

#-------------------------
# Download YoutubeMusic
#-------------------------
RELEASE_VERSION_YTM=$(wget -qO - "https://api.github.com/repos/th-ch/youtube-music/releases/latest" | grep -Po '"tag_name": ?"v\K.*?(?=")')
wget -O /home/$CURRENT_USER/Downloads/YTM.deb "https://github.com/th-ch/youtube-music/releases/download/v${RELEASE_VERSION_YTM}/youtube-music_${RELEASE_VERSION_YTM}_amd64.deb"
sudo nala install /home/$CURRENT_USER/Downloads/YTM.deb

#-------------------------
# Download Micro editor
#-------------------------
cd /usr/bin
curl https://getmic.ro/r | sudo sh
cd $CDY

#-------------------------
# Install Docker + Docker compose
#-------------------------
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 
sudo nala update
sudo nala install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo usermod -aG docker $CURRENT_USER

#-------------------------
# Install OnlyOffice
#-------------------------
flatpak install --user flathub org.onlyoffice.desktopeditors -y

#-------------------------
# Install Joplin
#-------------------------
flatpak install --user flathub net.cozic.joplin_desktop -y

#-------------------------
# Install Bitwarden
#-------------------------
flatpak install --user flathub com.bitwarden.desktop -y

#-------------------------
# Install Ext Manager
#-------------------------
flatpak install --user flathub com.mattjakeman.ExtensionManager -y

#-------------------------
# Install Jitsi Meet
#-------------------------
# flatpak install --user flathub org.jitsi.jitsi-meet -y

#-------------------------
# Install VLC
#-------------------------
flatpak install --user flathub org.videolan.VLC -y

#-------------------------
# Install GIMP
#-------------------------
flatpak install --user flathub org.gimp.GIMP -y

#-------------------------
# Install Session Desktop
#-------------------------
# flatpak install --user flathub network.loki.Session -y

#-------------------------
# Install MEGASync
#-------------------------
flatpak install --user flathub nz.mega.MEGAsync -y

#-------------------------
# Install Tutanota Desktop
#-------------------------
flatpak install --user flathub com.tutanota.Tutanota -y

#-------------------------
# Install Gnome Auth
#-------------------------
flatpak install --user flathub com.belmoussaoui.Authenticator -y

#-------------------------
# Install Zotero
#-------------------------
flatpak install --user flathub org.zotero.Zotero -y

#-------------------------
# Install Amberol
#-------------------------
flatpak install --user flathub io.bassi.Amberol -y

#-------------------------
# Install Ungoogled Chromium
#-------------------------
flatpak install --user flathub com.github.Eloston.UngoogledChromium -y

#-------------------------
# Install Flatseal
#-------------------------
flatpak install --user flathub com.github.tchx84.Flatseal -y

#-------------------------
# Install auto-cpufreq
#-------------------------
git clone https://github.com/AdnanHodzic/auto-cpufreq.git /home/$CURRENT_USER/auto-cpufreq
cd /home/$CURRENT_USER/auto-cpufreq && sudo ./auto-cpufreq-installer

sudo cp $CDY/auto-cpufreq.conf /etc/auto-cpufreq.conf

#-------------------------
# Settings git config
#-------------------------
printf "Setting git config global user name and email"
git config --global user.name githubUserName
git config --global user.email myEmailAddress

if ! [ -z "$ghToken" ]; then
	{
	 sudo touch /home/$CURRENT_USER/.token.txt
	 echo $ghToken >> sudo /home/$CURRENT_USER/.token.txt
	 gh auth login --with-token < sudo /home/$CURRENT_USER/.token.txt
	 sudo rm -rf /home/$CURRENT_USER/.token.txt
	 echo "Github logged in."
	} || {
	 echo "Github NOT logged in. Check if everything is good or retry."
	}
else
	echo "No GH Token has been passed."
fi

#-------------------------
# Installing Miniconda
#-------------------------
printf "Downloading miniconda installer and installing miniconda for Linux"
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /home/$CURRENT_USER/Downloads/miniconda.sh
bash /home/$CURRENT_USER/Downloads/miniconda.sh -b -p /home/$CURRENT_USER/miniconda

if ! [ -x "$(command -v conda)" ]; then
	export PATH="$HOME/miniconda/bin:$PATH"
	/home/$CURRENT_USER/miniconda/bin/conda init
else
	/home/$CURRENT_USER/miniconda/bin/conda init
fi

#-------------------------
# Install prompter
#-------------------------
# Create the directory inside .config for the shell configs
printf "Copy prompt file to folder"
mkdir -p /home/$CURRENT_USER/.config/gr8sh/
sudo cp $CDY/gr8sh/prompt.sh /home/$CURRENT_USER/.config/gr8sh/
sudo cp $CDY/gr8sh/prompt.config /home/$CURRENT_USER/.config/gr8sh/

#-------------------------
# Copy micro configs
#-------------------------
printf "Copy micro config to folder"
sudo cp $CDY/micro/settings.json /home/$CURRENT_USER/.config/micro/
sudo cp $CDY/micro/bindings.json /home/$CURRENT_USER/.config/micro/

micro --plugin install lsp
micro --plugin install filemanager

pip install python-lsp-server[all]
pip install pylsp-mypy

#-------------------------
# Update .bashrc
#-------------------------
cat $CDY/tobash.conf >> sudo /home/$CURRENT_USER/.bashrc

#-------------------------
# Customize Gnome
#-------------------------
git clone https://github.com/jmattheis/gruvbox-dark-icons-gtk /home/$CURRENT_USER/.icons/gruvbox-dark-icons-gtk
gsettings set org.gnome.desktop.interface icon-theme 'gruvbox-dark-icons-gtk'

# Add Doid Sans Mono Nerd Font
mkdir -p /home/$CURRENT_USER/.local/share/fonts && \
cd /home/$CURRENT_USER/.local/share/fonts && \
curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" \
https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

#-------------------------
# Install Polybar and rofi
#-------------------------
sudo nala install polybar rofi -y

sudo mkdir /home/$CURRENT_USER/.config/polybar
sudo cp -r $CDY/polybar/* /home/$CURRENT_USER/.config/polybar/

sudo mkdir /home/$CURRENT_USER/.config/rofi
sudo cp -r $CDY/rofi/* /home/$CURRENT_USER/.config/rofi/

