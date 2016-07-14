#! /bin/bash
# =#= tab-width: 4 =#= #########################################################
#
# FILENAME: install.sh
#
# Copyright 2015 Florian Kerle <flo.kerle@gmx.at>
# Released under the 'GNU General Public License v3'
#
# DESCRIPTION:
#	igh ethercat-master installation script
#
# CHANGELOG:
# ==========
# user   	| date       | changes
# ----------|------------|-----------------------------------------------------
# f.kerle	| 11.06.2015 | initial release
#
################################################################################

SCRIPTNAME=$(basename $0)
SCRIPTPATH=$(cd $(dirname $0); pwd -P)

# XXX: adapt
INSTALL_PATH='/opt/etherlab'
PRESERVE_DIR='./preserve.d'

# === MAIN === #
echo -e "\n"
echo "========================================="
echo -e "$SCRIPTNAME:	executing...\n\n"

# --enable-<driver_name>
# where <driver_name> is one of:
# 	- generic	[included by default]
# 	- 8139too	[indluced by default]
# 	- r8169
# 	- e100
# 	- e1000
# 	- e1000e

OPTIONS="--prefix $INSTALL_PATH"
#OPTIONS+=" --enable-debug-if"
OPTIONS+=" --enable-cycles"
DEVICES="--enable-e1000e"
./configure $OPTIONS $DEVICES

make clean

make
make modules
make doc

# preserve config files
pushd "$PRESERVE_DIR"
for f in $(find . -type f); do
	f=${f#./}

	if [[ -e ${INSTALL_PATH}/$f ]]; then
		sudo cp -fa ${INSTALL_PATH}/$f $f
	fi
done
popd

sudo make install
sudo make modules_install
sudo depmod

# put a symlink for Module.symvers in a known place
# (used i.e. by linuxcnc-ethercat)
MOD_DIR="/usr/realtime-$(uname -r)/modules/ethercat"
sudo mkdir -p $MOD_DIR
sudo ln -sf "$PWD/Module.symvers" "$MOD_DIR/Module.symvers"

# symlink include file dir
# (used i.e. by linuxcnc-ethercat)
ln -sf "$PWD/include" "/usr/local/include/ethercat"

sudo ln -sf $INSTALL_PATH/bin/ethercat /usr/local/bin/
sudo ln -sf $INSTALL_PATH/etc/init.d/ethercat /etc/init.d/
sudo ln -sf $INSTALL_PATH/etc/sysconfig/ethercat /etc/default/

pushd "$PRESERVE_DIR"
for f in $(find . -type f); do
	f=${f#./}

	mkdir -p ${INSTALL_PATH}
	sudo cp -fa ${f} ${INSTALL_PATH}/$f
done
popd

echo -e "\n"
echo -e "$SCRIPTNAME:	finished"
echo "========================================="

exit
