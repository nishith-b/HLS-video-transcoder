# 🎥 FFmpeg + Docker HLS Transcoding Guide

This project sets up a **Docker-based FFmpeg environment** for video segmentation and transcoding to multiple resolutions using HLS (HTTP Live Streaming). Ideal for adaptive streaming and local development.

---

## 📁 Folder Structure

```
.
└── assets
    └── video-js.min.css
    └── video.min.js
└── videos/
    └── Sample.mp4
├── Dockerfile
├── index.html
├── README.md
├── transcode.sh
```

> Place input videos in the `videos/` folder. Output will be saved inside the same folder.

---

## 🐳 Docker Setup

### Dockerfile

```Dockerfile
FROM ubuntu:focal

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs ffmpeg nano bash-completion

WORKDIR /home/app

COPY transcode.sh .
RUN chmod +x transcode.sh

CMD ["./transcode.sh"]
```

### Build Docker Image

```bash
docker build -t video_transcoder .
```

### Run Docker Container with Volume Mount

```bash
docker run -it -v /full/path/to/videos:/home/app/videos video_transcoder
```

> 📝 Replace `/full/path/to/videos` with your actual local path.

---

## 🧰 transcode.sh Script

This script will transcode `Sample.mp4` into 360p, 480p, and 720p HLS outputs, then create a **master playlist**.

```bash
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
```

---

## 🧪 Optional: Plain HLS Segmentation (No Scaling)

To only segment a video without changing resolution:

```bash
ffmpeg -i Sample.mp4 \
  -codec:v libx264 -codec:a aac \
  -hls_time 10 \
  -hls_playlist_type vod \
  -hls_segment_filename "videos/output/segment_%03d.ts" \
  videos/output/index.m3u8
```

---

## 🖥️ Output Folder Structure

```
videos/output/
├── 360p_000.ts, ...
├── 360p.m3u8
├── 480p_000.ts, ...
├── 480p.m3u8
├── 720p_000.ts, ...
├── 720p.m3u8
└── index.m3u8  ← Master playlist
```

---

## 🌐 Playback

Use [Video.js](https://videojs.com/) or [hls.js](https://github.com/video-dev/hls.js/) to stream:

```
/videos/output/index.m3u8
```

Your stream will adapt based on viewer bandwidth. 📶

## 📽️ Streaming HLS Video from S3

This project streams an HLS video (`.m3u8` and `.ts` segments) using a React frontend. The HLS playlist can be hosted on AWS S3 or tested locally using a local server.

---

### 🧾 Uploading HLS Video Manually to S3 (Optional)

To manually upload your HLS video files to S3:

1. **Prepare the files**:
   - You should have a `.m3u8` playlist file and associated `.ts` segment files.
   - Example:
     ```
     /output/
     ├── playlist.m3u8
     ├── segment0.ts
     ├── segment1.ts
     └── segment2.ts
     ```

2. **Create an S3 bucket (if not already created)**:
   - Go to the [AWS S3 Console](https://s3.console.aws.amazon.com/s3/home).
   - Click "Create bucket", choose a name, and configure permissions.

3. **Upload files**:
   - Navigate to your bucket > "Upload".
   - Upload the entire `/output/` folder contents.

4. **Make files public (optional for quick testing)**:
   - Select each file > "Actions" > "Make public"  
     _(Alternatively, use signed URLs or configure S3 bucket policy.)_

5. **Set CORS policy (to allow cross-origin access)**:
   In your bucket > Permissions > CORS configuration, paste:

   ```xml
   <CORSConfiguration>
     <CORSRule>
       <AllowedOrigin>*</AllowedOrigin>
       <AllowedMethod>GET</AllowedMethod>
       <AllowedHeader>*</AllowedHeader>
     </CORSRule>
   </CORSConfiguration>

6. **Get Signed or Public URL to Stream the Video**

---

## ✅ Requirements

- Docker with WSL2 (for Windows users)
- `videos/` folder with an input file (`Sample.mp4`)
- Stable internet (to pull Docker base image and packages)

---

🎉 **Happy Transcoding and Streaming!**
