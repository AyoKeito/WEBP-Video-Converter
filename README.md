# WEBP-Video-Converter
Convert (virtually) any video to WEBP

<p align="center">
	<img src="https://github.com/AyoKeito/WEBP-Video-Converter/blob/master/40TBJzf.png" width="800">
</p>

## Just drag&drop one file and select the name you want
- MediaInfo is checking for file dimensions (720p or lower are recommended)
- ffmpeg is extracting frames from video
- img2webp is combining these frames into WEBP file

## Possible porblems:
- **Try to avoid** videos **more than 300-500 frames long** - they may cause problems for the encoder (no file will be created then).
- **Try to avoid** resolutions **higher than 1280x720** - they probably won't achieve selected framerate (file will be created, but will drop frames and lag).
- You can type your own framerate into the box, but **weird (not already in list) framerates may cause problems** (file will be created, but will drop frames and randomly jump between frames)
- Try to avoid lower than maximum quality for big (~HD) videos - they may look bad.
- You can **only encode one file** - no queue is available.

All the temp files are removed after encoding.

You can put **your own** MediaInfo.exe **CLI** and ffmpeg.exe into the same folder. Program will use them if they are placed there before it's launched. Otherwise, built-in versions will be extracted and deleted after use.

You can use **your own** img2webp.exe. To do so, you should create a folder that's named as your input file minus resolution and put it there before program is launched.
