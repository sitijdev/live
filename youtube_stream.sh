#!/bin/bash

# Konfigurasi timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
USERNAME="sitijdev"
VIDEO_NAME="indah.mp4"

# Baca YouTube Stream Key
YOUTUBE_STREAM_KEY=$(cat youtube_stream_key.txt)

# Baca Google Drive Folder ID
FOLDER_ID=$(cat input_folder_id.txt)

# Buat direktori temporer untuk menyimpan video
mkdir -p temp_videos

# Setup logging
exec 1> >(tee -a "stream_${TIMESTAMP}.log")
exec 2>&1

echo "[INFO] Starting stream at ${TIMESTAMP} by ${USERNAME}"

# Fungsi untuk melakukan streaming video ke YouTube
stream_to_youtube() {
    local video_file="$1"
    echo "[INFO] Streaming file: $video_file"
    ffmpeg -re -i "$video_file" \
        -c:v copy \
        -c:a copy \
        -f flv \
        "rtmp://a.rtmp.youtube.com/live2/$YOUTUBE_STREAM_KEY" \
        2>&1
}

# Fungsi untuk membersihkan file temporary
cleanup() {
    echo "[INFO] Membersihkan file temporary..."
    rm -rf temp_videos
    echo "[INFO] Stream selesai pada $(date +"%Y-%m-%d %H:%M:%S")"
    exit 0
}

# Register cleanup function pada exit
trap cleanup EXIT

echo "[INFO] Mendownload $VIDEO_NAME dari Google Drive..."

# Download video spesifik dari Google Drive
rclone copy "gdrive:$FOLDER_ID/$VIDEO_NAME" temp_videos --config gdrive_credentials.json

if [ -f "temp_videos/$VIDEO_NAME" ]; then
    echo "[INFO] File $VIDEO_NAME berhasil didownload"
    echo "[INFO] Memulai streaming ke YouTube..."
    stream_to_youtube "temp_videos/$VIDEO_NAME"
else
    echo "[ERROR] File $VIDEO_NAME tidak ditemukan di Google Drive"
    exit 1
fi
