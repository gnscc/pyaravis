FROM ubuntu:latest

RUN apt-get update -y && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Madrid apt-get install -y --no-install-recommends \
    libxml2-dev libglib2.0-dev cmake libusb-1.0-0-dev gobject-introspection \
    libgtk-3-dev gtk-doc-tools  xsltproc libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev \
    libgirepository1.0-dev gettext python3-dev python3-pip wget curl
RUN pip3 install meson ninja Markdown toml typogrify gi-docgen pygobject --break-system-packages
