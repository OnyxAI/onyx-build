#!/bin/bash -e

on_chroot << EOF
  sudo rm /etc/nginx/sites-available/default
EOF

install -m 644 files/default "${ROOTFS_DIR}/etc/nginx/sites-available/default"

on_chroot << EOF
  cd /home
  git clone --no-checkout https://github.com/OnyxAI/enclosure-onyx pi/enclosure.tmp

  mv pi/enclosure.tmp/.git pi/

  rmdir pi/enclosure.tmp
  cd pi

  git reset --hard HEAD

  cd /home/pi
  git clone https://github.com/OnyxAI/onyx

  cd onyx
  sudo bash install_debian_script.sh
  yarn config set "strict-ssl" false -g

  bash setup.sh

  cd /home/pi

  bash <(curl -L https://github.com/OnyxAI/onyx-wifi/raw/master/scripts/raspbian-install.sh)
EOF

on_chroot << EOF
	SUDO_USER="${FIRST_USER_NAME}" raspi-config nonint do_boot_behaviour B4
EOF
