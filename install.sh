#!/usr/bin/env bash

ILOG=$PWD/logs/install.log

status_check() {
    if [ $? -eq 0 ]
    then
        echo -e "$1 - Installed"
    else
        echo -e "$1 - Failed!"
    fi
}

debian_install() {
    echo -e '=====================\nINSTALLING FOR DEBIAN\n=====================\n' > "$ILOG"

    echo -ne 'Python3\r'
    sudo apt -y install python3 python3-pip &>> "$ILOG"
    status_check Python3
    echo -e '\n--------------------\n' >> "$ILOG"

    echo -ne 'PIP\r'
    sudo apt -y install python3-pip &>> "$ILOG"
    status_check Pip
    echo -e '\n--------------------\n' >> "$ILOG"

    echo -ne 'PHP\r'
    sudo apt -y install php &>> "$ILOG"
    status_check PHP
    echo -e '\n--------------------\n' >> "$ILOG"
}

termux_install() {
    echo -e '=====================\nINSTALLING FOR TERMUX\n=====================\n' > "$ILOG"

    echo -ne 'Python3\r'
    apt -y install python &>> "$ILOG"
    status_check Python3
    echo -e '\n--------------------\n' >> "$ILOG"

    echo -ne 'PHP\r'
    apt -y install php &>> "$ILOG"
    status_check PHP
    echo -e '\n--------------------\n' >> "$ILOG"
}

arch_install() {
    echo -e '=========================\nINSTALLING FOR ARCH LINUX\n=========================\n' > "$ILOG"

    echo -ne 'Python3\r'
    yes | sudo pacman -S python3 python-pip --needed &>> "$ILOG"
    status_check Python3
    echo -e '\n--------------------\n' >> "$ILOG"

    echo -ne 'PIP\r'
    yes | sudo pacman -S python-pip --needed &>> "$ILOG"
    status_check Pip
    echo -e '\n--------------------\n' >> "$ILOG"

    echo -ne 'PHP\r'
    yes | sudo pacman -S php --needed &>> "$ILOG"
    status_check PHP
    echo -e '\n--------------------\n' >> "$ILOG"
}

# Cloudflared Download
get_cloudflared() {
    
    url="$1"
    file=`basename $url`
    if [[ -e "$file" ]]; then
    
        rm -rf "$file"
    fi
    
    wget --no-check-certificate "$url" > /dev/null 2>&1
    
    if [[ -e "$file" ]]; then
        mv -f "$file" .host/cloudflared > /dev/null 2>&1
        chmod +x .host/cloudflared > /dev/null 2>&1
        
    else
        echo -e "\n${RED}[${WHITE}!${RED}]${RED} Error, Install Cloudflared manually."
        { clear; exit 1; }
    fi
}


cloudflared_download_and_install() {
    
    if [[ -e ".host/cloudflared" ]]; then
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${GREEN} Cloudflared already installed."
        sleep 1
    
    else
    
        echo -e "\n${GREEN}[${WHITE}+${GREEN}]${MAGENTA} Downloading and Installing Cloudflared..."${WHITE}
        
        architecture=$(uname -m)
        
        if [[ ("$architecture" == *'arm'*) || ("$architecture" == *'Android'*) ]]; then
            get_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm'
        
        elif [[ "$architecture" == *'aarch64'* ]]; then
            get_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64'
        
        elif [[ "$architecture" == *'x86_64'* ]]; then
            get_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64'
        
        else
            get_cloudflared 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386'
        fi
    fi

}


echo -e '[!] Installing Dependencies...\n'

if [ -f '/etc/arch-release' ]; then
    arch_install
else
    if [ "$OSTYPE" == 'linux-android' ]; then
        termux_install
    else
        debian_install
    fi
fi

echo -ne 'Requests\r'
pip3 install requests &>> "$ILOG"
status_check Requests
echo -e '\n--------------------\n' >> "$ILOG"

echo -ne 'Packaging\r'
pip3 install packaging &>> "$ILOG"
status_check Packaging
echo -e '\n--------------------\n' >> "$ILOG"



echo -ne 'Create Directories\r'

# Directories
if [[ ! -d ".host" ]]; then
    mkdir -p ".host"
fi

if [[ ! -d ".www" ]]; then
    mkdir -p ".www"
fi

if [[ ! -d ".tunnels_log" ]]; then
    mkdir -p ".tunnels_log"
fi


echo -ne 'Cloudflared\r'


cloudflared_download_and_install

echo -e '\n--------------------\n' >> "$ILOG"

chmod -R 777 .tunnels_log
chmod -R 777 .host



# Clear content of log files

truncate -s 0 .tunnels_log/.cloudfl.log 

echo -e '=========\nCOMPLETED\n=========\n' >> "$ILOG"

echo -e '\n[+] Log Saved :' "$ILOG"
