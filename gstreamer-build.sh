#!/bin/bash

# Set your target branch
BRANCH="1.16.2"

# Create a log file of the build as well as displaying the build on the tty as it runs
exec > >(tee build_gstreamer.log)
exec 2>&1

# Update and Upgrade the Pi, otherwise the build may fail due to inconsistencies
sudo apt-get update && sudo apt-get upgrade -y

# Get the required libraries
# libdirac-dev is not availble
sudo apt-get install -y build-essential autotools-dev automake autoconf \
                        libtool autopoint libxml2-dev zlib1g-dev libglib2.0-dev \
                        pkg-config bison flex python3 git gtk-doc-tools libasound2-dev \
                        libgudev-1.0-dev libxt-dev libvorbis-dev libcdparanoia-dev \
                        libpango1.0-dev libtheora-dev libvisual-0.4-dev iso-codes \
                        libgtk-3-dev libraw1394-dev libiec61883-dev libavc1394-dev \
                        libv4l-dev libcairo2-dev libcaca-dev libspeex-dev libpng-dev \
                        libshout3-dev libjpeg-dev libaa1-dev libflac-dev libdv4-dev \
                        libtag1-dev libwavpack-dev libpulse-dev libsoup2.4-dev libbz2-dev \
                        libcdaudio-dev libdc1394-22-dev ladspa-sdk libass-dev \
                        libcurl4-gnutls-dev libdca-dev libdvdnav-dev \
                        libexempi-dev libexif-dev libfaad-dev libgme-dev libgsm1-dev \
                        libiptcdata0-dev libkate-dev libmimic-dev libmms-dev \
                        libmodplug-dev libmpcdec-dev libofa0-dev libopus-dev \
                        librsvg2-dev librtmp-dev libschroedinger-dev libslv2-dev \
                        libsndfile1-dev libsoundtouch-dev libspandsp-dev libx11-dev \
                        libxvidcore-dev libzbar-dev libzvbi-dev liba52-0.7.4-dev \
                        libcdio-dev libdvdread-dev libmad0-dev libmp3lame-dev \
                        libmpeg2-4-dev libopencore-amrnb-dev libopencore-amrwb-dev \
                        libsidplay1-dev libtwolame-dev libx264-dev libusb-1.0 \
                        python-gi-dev yasm python3-dev libgirepository1.0-dev \
                        libsrtp-dev liborc-dev

#get repos if they are not there yet
[ ! -d gstreamer ] && git clone git://anongit.freedesktop.org/git/gstreamer/gstreamer
[ ! -d gst-plugins-base ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-base
[ ! -d gst-plugins-good ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-good
[ ! -d gst-plugins-bad ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-bad
[ ! -d gst-libav ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-libav
[ ! -d gst-plugins-ugly ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-ugly
[ ! -d gst-omx ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-omx
[ ! -d libnice ] && git clone https://gitlab.freedesktop.org/libnice/libnice
[ ! -d webrtc-audio-processing ] git clone git://anongit.freedesktop.org/pulseaudio/webrtc-audio-processing

export LD_LIBRARY_PATH=/usr/local/lib/

#libnice for webrtc
cd libnice
./autogen.sh
./configure --enable-compile-warnings=no
make -j4 
sudo make install
cd ..

#webrtc-audio-processing for webrtcdsp
cd webrtc-audio-processing
./autogen.sh
./configure
make -j4 
sudo make install
cd ..

cd gstreamer
git checkout $BRANCH
./autogen.sh --disable-gtk-doc
make -j4
sudo make install
cd ..

cd gst-plugins-base
git checkout $BRANCH
./autogen.sh --disable-gtk-doc --disable-examples
make -j4
sudo make install
cd ..

cd gst-libav
git checkout $BRANCH
./autogen.sh --disable-gtk-doc --enable-orc
make -j4
sudo make install
cd ..

cd gst-plugins-good
git checkout $BRANCH
./autogen.sh --disable-gtk-doc
make -j4
sudo make install
cd ..

cd gst-plugins-ugly
git checkout $BRANCH
./autogen.sh --disable-gtk-doc
make -j4
sudo make install
cd ..

cd gst-plugins-bad
git checkout $BRANCH
./autogen.sh --disable-gtk-doc
export CFLAGS='-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux/'
export LDFLAGS='-L/opt/vc/lib'
./configure CFLAGS='-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux/' LDFLAGS='-L/opt/vc/lib' \
--disable-gtk-doc --disable-opengl --enable-gles2 --enable-egl --disable-glx \
--disable-x11 --disable-wayland --enable-dispmanx \
--with-gles2-module-name=/opt/vc/lib/libGLESv2.so \
--with-egl-module-name=/opt/vc/lib/libEGL.so
make CFLAGS+='-Wno-error -Wno-redundant-decls' LDFLAGS+='-L/opt/vc/lib' -j4
sudo make install
cd ..

# omx support
cd gst-omx
git checkout $BRANCH
export LDFLAGS='-L/opt/vc/lib' \
CFLAGS='-I/opt/vc/include -I/opt/vc/include/IL -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/IL' \
CPPFLAGS='-I/opt/vc/include -I/opt/vc/include/IL -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/IL'\
PKG_CONFIG_PATH='/opt/vc/lib/pkgconfig'
./autogen.sh --disable-gtk-doc --with-omx-target=rpi
make CFLAGS+='-Wno-error -Wno-redundant-decls' LDFLAGS+='-L/opt/vc/lib' -j4
sudo make install
cd ..

#finish up
sudo ln -s /usr/local/include/gstreamer-1.0 /usr/include
sudo ldconfig

#print version
gst-inspect-1.0 --gst-version
