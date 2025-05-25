#!/bin/bash

cd ~/Desktop && \
touch Test.bat && \
cat > Test.bat <<'EOF'
@echo off

pause
exit
EOF