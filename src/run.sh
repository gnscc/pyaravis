#!/bin/bash

cd /

# Fetch the latest release information
RELEASE_DATA=$(curl -s https://api.github.com/repos/AravisProject/aravis/releases/latest)

# Extract the download URL of the asset
DOWNLOAD_URL=$(echo "$RELEASE_DATA" | grep "browser_download_url" | cut -d '"' -f 4)
FULL_VERSION=$(echo "$RELEASE_DATA" | grep "tag_name" | cut -d '"' -f 4)
MAJOR_MINOR_VERSION=$(echo "$FULL_VERSION" | cut -d '.' -f 1,2)

LIB_PATH="/pyaravis/lib"

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
cd /

# Copy template __init__ file into output folder
rm -rf /pyaravis/*
cp /src/template.py /pyaravis/__init__.py

# Add current version
sed -i "s/__FULL_VERSION__/${FULL_VERSION}/g" "/pyaravis/__init__.py"
sed -i "s/__MAJOR_MINOR_VERSION__/${MAJOR_MINOR_VERSION}/g" "/pyaravis/__init__.py"

# Create lib path
mkdir -p $LIB_PATH

# Copy library
cp /aravis/build/src/libaravis-$MAJOR_MINOR_VERSION.so $LIB_PATH
cp /aravis/build/src/Aravis-$MAJOR_MINOR_VERSION.typelib $LIB_PATH

export GI_TYPELIB_PATH=/aravis/build/src
export LD_LIBRARY_PATH=/aravis/build/src

# Download pygobject-stubs
wget https://api.github.com/repos/pygobject/pygobject-stubs/tarball/v2.12.0
tar -xf v2.12.0

# Generate stubs for Python
echo "Generating stubs..."
python3 /pygobject-pygobject-stubs-6835396/tools/generate.py Aravis $MAJOR_MINOR_VERSION > /tmp/Aravis.pyi

python3 /src/fix_stubs.py /tmp/Aravis.pyi /pyaravis/__init__.pyi

# Allow full access outside the container
chmod -R 777  /pyaravis
