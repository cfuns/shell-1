#!/bin/bash

DIR=`dirname $0`
CONF_DIR="$DIR/../conf/"
STATUS_DIR="$DIR/../status/"
FLAG_DIR="$DIR/../flag/"
LOG_DIR="$DIR/../log/"

EXCLUDE_CMD=""
RSYNC_INIT_CMD="rsync -av --bwlimit=10000 -e ssh"


source "$DIR/list.conf"
source "$DIR/alarm.sh"


RSYNC_NEED_AMOUNT=${#RSYNC_REGISTER[*]}

count=0

while [ $count -lt $RSYNC_NEED_AMOUNT ]
do
    rsync_register_name=${RSYNC_REGISTER[$count]}

# creative log file
    > "$LOG_DIR/$rsync_register_name".log

# get src value name
    rsync_src_value_name="$rsync_register_name"_src_dir
# get src dir name
    rsync_src_dir_name=$(eval echo \${${rsync_src_value_name}[0]})
    echo $rsync_src_dir_name

# get exclude value name
    rsync_exclude_value_name="$rsync_register_name"_exclude_dir

# make the total cmd by exclude
    if [ $( eval echo \${${rsync_exclude_value_name}[0]} ) != "null" ]
    then
        exclude_count=0
        while [ $exclude_count -lt $(eval echo \${#${rsync_exclude_value_name}[*]}) ]
        do
            exclude_filename=$(eval echo \${${rsync_exclude_value_name}[$exclude_count]})
            echo $exclude_filename
            EXCLUDE_CMD="$EXCLUDE_CMD --exclude=$exclude_filename"
            exclude_count=$[ $exclude_count + 1 ]
        done
    fi
    
    $RSYNC_INIT_CMD $EXCLUDE_CMD $SOURCE_HOST:$rsync_src_dir_name $SAVE_RSYNC_DIR </dev/null &>"$LOG_DIR/$rsync_register_name".log

    count=$[ $count + 1 ]
done

exit 0
