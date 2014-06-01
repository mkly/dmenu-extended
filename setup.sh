user=$SUDO_USER
path=`pwd`

if [ -e /usr/bin/python2 ]
then
    python=/usr/bin/python2
elif [ -e /usr/bin/python ]
then
    python=usr/bin/python
else
    echo "You must have Python installed (python 2)"
    exit
fi

if [ ! -w /usr/bin ]
then
    echo "This script requires elevated priveledges - run with sudo"
    exit
fi
echo "Checking for dmenu installation..."
if [ ! -e /usr/bin/dmenu ]
then
    echo "dmenu not already installed - Installing"
    echo ""
    if [ -e /usr/bin/apt-get ]
    then
        sudo apt-get install build-essential libx11-dev libxinerama-dev
        cd /tmp
        wget http://dl.suckless.org/tools/dmenu-4.5.tar.gz
        tar -xzf dmenu-4.5.tar.gz
        cd dmenu-4.5
        make
        sudo make install
        echo "dmenu has been installed from source"
    elif [ -e /usr/bin/yum ]
    then
        sudo yum install dmenu
        echo "dmenu has been installed from yum"
    elif [ -e /usr/bin/pacman ]
    then
        sudo pacman -S dmenu
        echo "dmenu has been installed from pacman"
    else
        echo "Could not determine package manager and dmenu not installed - Aborting"
        exit
    fi
else
    echo "dmenu has been found - will not install"
    echo "NOTE: dmenu 4.5 is recommended for the best searching capability"
fi
echo ""
echo "Installing dmenu-extended..."
cd "$path"
sudo python setup.py install
echo "Done!"
echo ""
su $SUDO_USER -c "python -c 'import dmenu_extended
dmenu_extended.setup_user_files(dmenu_extended.path_base)
'"
echo ""
echo "Creating signature file..."
if [ -O /home/$SUDO_USER/.config/dmenu-extended/signature.txt ]
then
    sudo chown $SUDO_USER /home/$SUDO_USER/.config/dmenu-extended/signature.txt
fi
echo "Downloading zip file to create sha1sum signature..."
su $user -c "curl https://github.com/markjones112358/dmenu-extended/archive/master.zip | sha1sum | awk '{print $1}' > /home/$SUDO_USER/.config/dmenu-extended/signature.txt"
echo "Done!"
echo ""
if [ -e /home/$SUDO_USER/.config/dmenu-extended/cache_scanned.txt ]
then
    echo "Existing cache file found, skipping cache rebuild"
else
    echo ""
    echo "*******************************************************************"
    echo "* You should now execute dmenu_extended_build to create the cache *"
    echo "*******************************************************************"
    echo ""
    echo "Doing so will scan your home directory for files and folders. If"
    echo "there are folders you do not wish to include in the cache, you"
    echo "should add them to the 'exclude_folders' entry of:"
    echo "/home/$SUDO_USER/.config/dmenu-extended/user_preferences.conf"
    echo ""
    echo "For example on the line containing:"
    echo "    'exclude_folders': [],"
    echo "Change it to:"
    echo "    'exclude_folders': ['~/Rubbish', '~/Ignore']"
    echo ""
    while true; do
        read -p "Would you like to build the cache now? [y/n]:" yn
        case $yn in
            [Yy]* ) su $user -c "dmenu_extended_build"; break;;
            [Nn]* ) echo "Build the cache at any time by executing 'dmenu_extended_build'"; break;;
            * ) echo "Please select either 'yes' or 'no'.";;
        esac
    done
fi
echo "Installation finished"
echo ""
