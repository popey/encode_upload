#!/bin/bash
# Job which runs every hour to make a video of the previous hour and delete images

# When was an hour ago?
YYYY=`date -d '1 hour ago' "+%Y"`
MM=`date -d '1 hour ago' "+%m"`
DD=`date -d '1 hour ago' "+%d"`
HH=`date -d '1 hour ago' "+%H"`

# Two pass x264 encoding at a fairly decent bitrate
# Uses 60fps so we get 1 hour of real time = 1 min of video
mencoder "mf:///home/alan/Pictures/webcam/archive/$YYYY/$MM/$DD/$HH/*.jpg" \
  -mf fps=60 -o /home/alan/Pictures/webcam/$YYYY$MM$DD$HH.avi -ovc x264  \
  -x264encopts direct=auto:pass=1:turbo:bitrate=9600:bframes=1:me=umh:partitions=all:\
  trellis=1:qp_step=4:qcomp=0.7:direct_pred=auto:keyint=300 -vf scale=-1:-10,harddup

mencoder "mf:///home/alan/Pictures/webcam/archive/$YYYY/$MM/$DD/$HH/*.jpg" \
  -mf fps=60 -o /home/alan/Pictures/webcam/$YYYY$MM$DD$HH.avi -ovc x264 \
  -x264encopts direct=auto:pass=2:bitrate=9600:frameref=5:bframes=1:me=umh:partitions=all:\
  trellis=1:qp_step=4:qcomp=0.7:direct_pred=auto:keyint=300 -vf scale=-1:-10,harddup \
  -o /home/alan/Videos/webcam/$YYYY$MM$DD$HH.avi

# Delete the photos once the video is made
rm -rf /home/alan/Pictures/webcam/archive/$YYYY/$MM/$DD/$HH

# Upload the video to YouTube
cd ~/Applications/youtube-upload-0.7.3
python youtube_upload/youtube_upload.py --email=########## \
  --password=########## --private --title="$YYYY$MM$DD$HH" 
  --description="Time lapse of Farnborough sky at $HH on $DD $MM $YYYY" \
  --category="Entertainment" --keywords="timelapse" \
  /home/alan/Videos/webcam/$YYYY$MM$DD$HH.avi
cd

# Delete the temp video
rm -rf /home/alan/Videos/webcam/$YYYY$MM$DD$HH.avi
