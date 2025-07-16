#!/bin/bash

INPUT="videos/Sample.mp4"
OUT_DIR="videos/output"
mkdir -p "$OUT_DIR"

echo "Transcoding to 360p..."
ffmpeg -i "$INPUT" -vf "scale=640:360" -c:v libx264 -b:v 800k -c:a aac -b:a 96k \
  -hls_time 6 -hls_playlist_type vod \
  -hls_segment_filename "$OUT_DIR/360p_%03d.ts" \
  "$OUT_DIR/360p.m3u8"

echo "Transcoding to 480p..."
ffmpeg -i "$INPUT" -vf "scale=854:480" -c:v libx264 -b:v 1400k -c:a aac -b:a 128k \
  -hls_time 6 -hls_playlist_type vod \
  -hls_segment_filename "$OUT_DIR/480p_%03d.ts" \
  "$OUT_DIR/480p.m3u8"

echo "Transcoding to 720p..."
ffmpeg -i "$INPUT" -vf "scale=1280:720" -c:v libx264 -b:v 2800k -c:a aac -b:a 128k \
  -hls_time 6 -hls_playlist_type vod \
  -hls_segment_filename "$OUT_DIR/720p_%03d.ts" \
  "$OUT_DIR/720p.m3u8"

echo "Creating master playlist..."
cat <<EOF > "$OUT_DIR/index.m3u8"
#EXTM3U
#EXT-X-VERSION:3

#EXT-X-STREAM-INF:BANDWIDTH=1000000,RESOLUTION=640x360
360p.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=1500000,RESOLUTION=854x480
480p.m3u8

#EXT-X-STREAM-INF:BANDWIDTH=3000000,RESOLUTION=1280x720
720p.m3u8
EOF

echo "✅ All done! Check videos/output/ for results."