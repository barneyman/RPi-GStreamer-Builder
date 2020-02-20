This is guide to build gstreamer from scratch.

# Update

This GStreamer builder for RPi is forked from cxphong/Build-gstreamer-Raspberry-Pi-3(https://github.com/cxphong/Build-gstreamer-Raspberry-Pi-3)

1. Update for latest Raspbian 
2. Add builder for WEBRTC


# Note

From gst-plugin-bad v1.3.1, *glimagesink* replaces *eglglessink*, and *glimagesink* does not automatically scale video to fit screen

# Build from scratch

## 1. Uninstall default gstreamer 1.0

```Shell
sudo apt-get remove gstreamer1.0
sudo apt-get remove gstreamer-1.0
```

## 2. Build

```Shell
chmod +x gstreamer-build.sh
./gstreamer-build.sh
```
After building success:

Header is in /usr/local/inlude/gstreamer-1.0 

Lib is in /usr/local/lib

## 3. Config

### Copy header

```Shell
sudo cp -r /usr/local/include/gstreamer-1.0 /usr/include/
```

**Note:**

In some version *gstconfig.h* is not in */usr/local/include/gstreamer-1.0/gst/* but in */usr/local/lib/gstreamer-1.0/include/gst*.

Must copy it to */usr/include/gstreamer-1.0/gst/*

### To link lib

```Shell
sudo nano /etc/ld.so.conf
```

### Add

```Shell
include /usr/local/lib
```

### Link 

```Shell
sudo ldconfig
```

# Using prebuilt 

## 1. Delete old build
	
## 2. Extract version you want & copy into file system

```Shell	
sudo cp -r -v local /usr/local
```

## 3. Build config (Same build above, if not)

## 4. Check
	
```Shell
gst-launch-1.0 --version
```

# Using eglglesink in later version

## 1. Copy

After install later version

```
cd gstreamer-1.2.4
sudo cp -r gstreamer-1.0/gst/egl/ /usr/include/gstreamer-1.0
sudo cp -r lib/*gl* /usr/local/lib/
sudo cp lib/gstreamer-1.0/libgsteglglessink.* /usr/local/lib/gstreamer-1.0/
```



