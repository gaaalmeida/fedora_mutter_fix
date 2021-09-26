if [ ! ${EUID} -eq 0 ]; then
    echo "This script needs administratives privileges! Run with sudo."
    exit
fi

FEDORA_VERSION=$(echo -ne "f" && cat /etc/os-release | grep 'VERSION_ID' | grep -oE '[0-9\.]+$')
INSTALLED_MUTTER_VERSION=$(rpm -qa mutter)
MUTTER_PATCHED_FILE=$(eval echo ~${SUDO_USER})
SYSTEM_ARCH=$(uname -i)

# Check if mutter is already patched
is_patched()
{
    if [[ -f $MUTTER_PATCHED_FILE ]]; then
        return 0
    else
        return 1
    fi
}

download_rpm()
{
    if $PYTHON3_IS_INSTALLED; then
        echo "yes"
    else
        echo "Installing Python 3 and pip3"
        dnf install -y python3 pip3
        pip3 install selenium
        download_rpm
    fi
}

patch_mutter()
{
    # Download and extract Mutter
    echo -ne "Downloading mutter...\033[0K\r"
    mkdir srpm_mutter &&
    cd srpm_mutter &&
    dnf download --source --arch $SYSTEM_ARCH mutter &> /dev/null &&
    echo -ne "Extracting SRPM\033[0K\r"
    rpm2cpio mutter*.src.rpm | cpio -idmv &> /dev/null &&
    tar -xf mutter*.tar.xz &&
    TAR_NAME=$(basename mutter*.tar.xz) &&

    # Patch Mutter
    echo -ne "Patching Mutter\033[0K\r"
    cd mutter*/
    cd src &&
    cd backends &&
    cd x11 &&
    sed -i '/XkbNewKeyboardNotify/d' ./meta-backend-x11.c &&

    # Compressing Mutter

    echo -ne "Compressing Mutter\033[0K\r"
    cd ../../../../ &&
    rm -rf mutter*.tar.xz &&
    tar c mutter*/ | xz > $TAR_NAME

    # Building the RPM
    echo -ne "Building the patched RPM\033[0K\r"
    fedpkg --release $FEDORA_VERSION local &&
   
    # Installing
    echo -ne "Installing patched mutter\033[0K\r"
    cd x86_64/ &&
    rpm -U --replacefiles --replacepkgs mutter-*.rpm
}

# Check if has a update available

dnf check-update -q mutter &> /dev/null

if [ $? -eq 0 ]; then
    if is_patched; then
        echo "The package is up to date and patched"
        exit
    else
        patch_mutter
    fi
else
    patch_mutter
fi
