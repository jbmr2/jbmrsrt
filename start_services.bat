@echo off
cd /d "d:\srt"
echo Starting MediaMTX...
start /B mediamtx.exe
echo Starting Web Manager...
start /B node server.js
echo Services started.
