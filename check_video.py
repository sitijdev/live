#!/usr/bin/env python3
import os
import sys
from datetime import datetime

def check_video_exists():
    folder_id = open('input_folder_id.txt').read().strip()
    video_name = "indah.mp4"
    
    # Cek menggunakan rclone lsf
    result = os.system(f'rclone lsf "gdrive:{folder_id}/{video_name}" --config gdrive_credentials.json')
    
    if result != 0:
        print(f"[ERROR] Video {video_name} tidak ditemukan di Google Drive")
        sys.exit(1)
    
    print(f"[INFO] Video {video_name} ditemukan di Google Drive")
    return True

if __name__ == "__main__":
    check_video_exists()
