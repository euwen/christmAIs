#!/bin/bash
#
# Automated set-up script for christmAIs for any workspace
#
# Usage
# -----
# To use this script, simply run `./install-christmais.sh`
#

# Exit on error
set -e

finish() {
  if (( $? != 0)); then
    echo ""
    echo "================================================"
    echo "christmAIs did not install successfully"
    echo "Please refer to manual setup instructions:"
    echo "https://github.com/thinkingmachines/christmAIs"
    echo "================================================"
    echo ""
  fi
}
trap finish EXIT

# For printing error messages
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  exit 1
}

# Download important files
echo ""
echo "============================================"
echo "Downloading model checkpoint, categories, and"
echo "webdriver (chromedriver)                    "
echo "============================================"
echo ""

# Get categories.txt
if [ -f categories/categories.txt ]; then
    echo "categories.txt exists! Skipping download..."
else
    wget https://storage.googleapis.com/tm-christmais/categories.txt && \
        mkdir categories && \
        mv categories.txt categories/
fi

# Get model checkpoint
if [ -f ckpt/model.ckpt.index ]; then
    echo "model checkpoint exists! Skipping download..."
else
    wget https://storage.googleapis.com/download.magenta.tensorflow.org/models/arbitrary_style_transfer.tar.gz && \
        mkdir ckpt && \
        tar --strip-components 1 -xvzf arbitrary_style_transfer.tar.gz -C ckpt/
fi

# Get chromedriver
if [ -f webdriver/chromedriver ]; then
    echo "chromedriver exists! Skipping download..."
else
    wget https://chromedriver.storage.googleapis.com/2.44/chromedriver_linux64.zip && \
        mkdir webdriver && \
        unzip chromedriver_*.zip -d webdriver
fi

echo ""
echo "============================================"
echo "Download success! The following files are   "
echo "now stored in filesystem:                   "
echo "- categories: ./categories/categories.txt   "
echo "- model.ckpt: ./ckpt/model.ckpt             "
echo "- chromedriver: ./webdriver/chromedriver    "
echo "============================================"
echo ""

# Download style images
echo ""
echo "============================================"
echo "Downloading style images from               "
echo "Google Cloud Storage                        "
echo "============================================"
echo ""

# Sample style images
declare -a stylenames=(
    "ang_kiukok.jpg"
    "cassis.jpg"
    "composition.jpg"
    "dancer_flowers.jpg"
    "impression_sunrise.jpg"
    "la_grande_jatte.jpg"
    "la_muse.jpg"
    "marilyn_monroe.jpg"
    "pila_sa_bigas.jpg"
    "rain_princess.jpg"
    "seated_nude.jpg"
    "starry_night.jpg"
    "the_scream.jpg"
    "the_wave.jpg"
    "tres_marias.jpg"
    )

if ls styles/*.jpg 1> /dev/null 2>&1; then
    echo "Style files exists!"
else
    echo "Creating styles/ directory..."
    mkdir styles;
    for i in "${stylenames[@]}"
        do
            echo "Downloading $i into styles/..."
            wget -P styles/ https://storage.googleapis.com/tm-christmais/styles/$i
        done
fi

echo ""
echo "============================================"
echo "Download success! The following files are   "
echo "now stored in filesystem:                   "
echo "- style images: ./styles/*.jpg              "
echo "============================================"
echo ""

# Install rtmidi for realtime midi IO
if [[ $(which apt-get) ]]; then
    echo ""
    echo "============================================"
    echo "installing rtmidi Linux library dependencies"
    echo "sudo privileges required"
    echo "============================================"
    echo ""
    sudo apt-get install build-essential libasound2-dev libjack-dev python3-dev tk-dev python-tk python3-tk
fi
pip install --pre python-rtmidi

if [[ $(which apt-get) ]]; then
    echo ""
    echo "============================================"
    echo "installing chromium for the webdriver       "
    echo "sudo privileges required"
    echo "============================================"
    echo ""
    sudo apt-get install chromium
fi

# Set up the magenta dependency
echo ""
echo "=============================="
echo "installing magenta dependency"
echo "=============================="
echo ""
pip install magenta

# Clone christmAIs repository
echo ""
echo "=============================="
echo "cloning christmAIs repository"
echo "=============================="
echo ""

python setup.py install

echo ""
echo "=============================="
echo "christmAIs Install Success!"
echo "=============================="
echo ""
