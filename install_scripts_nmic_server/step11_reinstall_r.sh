#!/bin/bash

###############################################################################
# Script: install_r_china.sh
# Description: Install R (CLI) on Ubuntu 24.04 using Tsinghua CRAN Mirror.
# OS: Ubuntu 24.04 (Noble Numbat)
# Mirror: Tsinghua University (TUNA)
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}>>> Starting R Environment Installation for Ubuntu 24.04...${NC}"

# 1. Check for root/sudo privileges
if [ "$EUID" -ne 0 ]; then 
  echo -e "${RED}Error: Please run this script with sudo.${NC}"
  echo "Usage: sudo bash $0"
  exit 1
fi

# 2. Update existing package list
echo -e "${YELLOW}>>> Updating existing package lists...${NC}"
apt-get update -qq

# 3. Install prerequisites for adding repositories
echo -e "${YELLOW}>>> Installing prerequisites (curl, gnupg, software-properties-common)...${NC}"
apt-get install -y -qq software-properties-common dirmngr gnupg wget

# 4. Setup CRAN GPG Key (official CRAN method)
echo -e "${YELLOW}>>> Importing CRAN GPG Key...${NC}"
mkdir -p /etc/apt/keyrings
rm -f /etc/apt/keyrings/cran.gpg /tmp/marutter_pubkey.asc
wget -O /tmp/marutter_pubkey.asc https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc
gpg --dearmor -o /etc/apt/keyrings/cran.gpg /tmp/marutter_pubkey.asc
chmod 644 /etc/apt/keyrings/cran.gpg
rm -f /tmp/marutter_pubkey.asc

# 5. Add CRAN Repository
echo -e "${YELLOW}>>> Adding CRAN Repository for Noble (24.04)...${NC}"
REPO_FILE="/etc/apt/sources.list.d/cran.list"
echo "deb [signed-by=/etc/apt/keyrings/cran.gpg] https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" > $REPO_FILE

# 6. Update package list with new repository
echo -e "${YELLOW}>>> Updating package lists with new repository...${NC}"
apt-get update -qq

# 7. Install R Base and Development files
echo -e "${GREEN}>>> Installing R Base and Dev packages...${NC}"
apt-get install -y -qq r-base r-base-dev

# 8. Install Common System Dependencies for R Packages
# This prevents compilation errors when installing packages like tidyverse, data.table, etc.
echo -e "${YELLOW}>>> Installing common system libraries for R packages...${NC}"
apt-get install -y -qq \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgit2-dev \
    make \
    cmake \
    git

# 9. Clean up
echo -e "${YELLOW}>>> Cleaning up apt cache...${NC}"
apt-get autoremove -y -qq
apt-get clean -qq

# 10. Verification
echo -e "${GREEN}>>> Installation Complete! Verifying R version...${NC}"
R --version | head -n 3

echo -e "${GREEN}>>> R environment is ready. Type 'R' to start.${NC}"