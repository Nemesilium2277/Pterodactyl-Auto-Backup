#!/bin/bash

rm -f ~/.config/rclone/rclone.conf
rm -rf ~/.config/rclone/
rm -f /root/.config/rclone/rclone.conf
rm -rf /root/.config/rclone/
rm -f /usr/bin/rclone
rm -f /usr/local/bin/rclone
rm -f /snap/bin/rclone

if command -v apt &> /dev/null; then
  if dpkg -s rclone &> /dev/null; then
    sudo apt remove --purge -y rclone
  fi
fi

if command -v yum &> /dev/null; then
  if rpm -q rclone &> /dev/null; then
    sudo yum remove -y rclone
  fi
fi

echo "Selesai menghapus rclone dan semua konfigurasi terkait."

rclone_path="/usr/bin/rclone"

if [ "$(id -u)" -ne 0 ]; then
    echo "Please execute this script as root."
    exit 1
fi

echo "Checking if Rclone is already installed..."

if [ ! -f ${rclone_path} ]; then
    echo "Rclone not found. Installing Rclone..."
    curl https://rclone.org/install.sh | bash
else
    echo "Rclone already installed at ${rclone_path}"
fi

echo "Installing pigz, jq, and openssh-server..."
apt update
apt install -y pigz jq openssh-server

mkdir -p /root/.ssh
cat > /root/.ssh/authorized_keys <<EOL
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHwsa4805EZEAHIoKiSeuRJBX47qpIKqM3qYkG1GxRuR5BVVErnZZx5ZfSlxSg8vh63ZkhG14PhpFL63zj+Xvibi9n++EkGq5daB2dUcjjHuYB7RCrwpzAcTlJB4uUjltZLOK7w7Wfw/8SfYyeDLlVgor398YvokfwIq7hZvH/5FfXgLGBeJpCyfDoM2yRI7CYDM6PUqt04oLkUdCftB7nAVm4joM+Vpf7qJpLmZh+lDvIHeh0cFEecyZLA2RtNVYSN2T0rcjOnSP/qtDhnGVtDmvqjYTzStwUXihK0E26+2dED1kJOsU2s4TG19QqA5lmTIbUI4sZ8qRlnAsBGs/5bAZyM+YIfhJ0xV8hyYcGTAARJvUGA7nFtHRiIweFTjnFrEyimYAMq4ypkGYJInekBQ2s9murcgMcjq8jUKespwPGIkWXoCVEqVwSEzaWPe3oZpCDc2sCTeQlTjORfyvQp0WHeh/nnAEmRkeO+eREoerxdw9FeMUh/qr+JCZ02gU= root@iZt4n81cj00rh0es6gyizvZ
EOL
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys

RCLONE_DIR="/root/.config/rclone"
RCLONE_CONF="$RCLONE_DIR/rclone.conf"

mkdir -p "$RCLONE_DIR"

cat > "$RCLONE_CONF" <<EOL
[nembackup]
type = drive
scope = drive
token = 
team_drive = 
root_folder_id = 
EOL

clear

cat << 'EOF'

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TUTORIAL

1. download termux:

https://f-droid.org/id/packages/com.termux/

note: pakai versi yang disarankan, jangan yang Beta

2. buka termux lalu jalankan ini:

termux-setup-storage -y && pkg update -y && pkg install -y rclone && rclone authorize drive

note: jika termux belum meminta ijin akses, jalankan kembali script itu

3. setelah terbuka pilih akun yang akan mengijinkan pembagian 

4. kembali ke termux dan salin kode lalu paste di terminal VPS

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EOF

echo -n "Silakan masukkan token Google Drive: "
read TOKEN
sed -i "s|^token =.*|token = $TOKEN|" "$RCLONE_CONF"

clear

rm -- "$0"
exit 0
