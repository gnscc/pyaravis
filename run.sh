#!/bin/bash

# Fetch the latest release information
RELEASE_DATA=$(curl -s https://api.github.com/repos/AravisProject/aravis/releases/latest)

# Extract the download URL of the asset
DOWNLOAD_URL=$(echo "$RELEASE_DATA" | grep "browser_download_url" | cut -d '"' -f 4)
FULL_VERSION=$(echo "$RELEASE_DATA" | grep "tag_name" | cut -d '"' -f 4)
MAJOR_MINOR_VERSION=$(echo "$FULL_VERSION" | cut -d '.' -f 1,2)

LIB_PATH="/pyaravis/aravis/lib"

# Create lib path
mkdir -p $LIB_PATH

# Download the file
echo "Downloading latest release from: $DOWNLOAD_URL"
wget -q --show-progress "$DOWNLOAD_URL"

# Extract the file
echo "Extracting the file..."
tar -xf aravis-$FULL_VERSION.tar.xz
mv aravis-$FULL_VERSION/ aravis/

# Build
echo "Building..."
cd ./aravis
meson setup build
cd ./build
ninja

# Copy library
cp /aravis/build/src/libaravis-$MAJOR_MINOR_VERSION.so $LIB_PATH
cp /aravis/build/src/Aravis-$MAJOR_MINOR_VERSION.typelib $LIB_PATH
ln -s $LIB_PATH/libaravis-$MAJOR_MINOR_VERSION.so $LIB_PATH/libaravis-$MAJOR_MINOR_VERSION.so.0

export GI_TYPELIB_PATH=$LIB_PATH
export LD_LIBRARY_PATH=$LIB_PATH

# Download pygobject-stubs
cd /
wget https://api.github.com/repos/pygobject/pygobject-stubs/tarball/v2.12.0
tar -xf v2.12.0

# Generate stubs for Python
echo "Generating stubs..."
cd /pygobject-pygobject-stubs-6835396/tools
python3 generate.py Aravis $MAJOR_MINOR_VERSION > /tmp/aravis.pyi

cd /pyaravis
python3 fix_stubs.py /tmp/aravis.pyi ./aravis/aravis.pyi

# Fix __init__.py
sed -i "s/__REPLACE_VERSION__/${MAJOR_MINOR_VERSION}/g" "/pyaravis/aravis/__init__.py"
