#!/usr/bin/env bash

#usage: 
#generate.sh  /path/to/fonts /path/to/cufon/convert.php /output/directory

old_ifs=${IFS}
IFS=$'
'

failed_log="$3/failed.log"
log_file="$3/convert.log"
touch $failed_log
touch $log_file
#make directories for fonts that don't have directories yet
find "$1" -depth 1 -type f | \
    while read F; do
    new=${F%.[^.]*}
    echo "Making directory $new and moving $F into it"
    mkdir "$new"
    mv "$F" "$new"
done

find "$1" -depth 1 -type d | \
    while read D; do
    fname=$(basename "$D");
    mkdir "$3/$fname"
    find "$D" -iname "*ttf" | \
        while read F; do
        js_out="$3/$fname/$fname.js"
        i_out="$3/$fname/$fname.png"

        echo "Generating $js_out..."

        old_log_size=$(stat -f "%z" $log_file)
        php "$2" -u "U+??" -b "Raphael.registerFont" -n "$fname" "$F" > $js_out 2>>$log_file
        new_log_size=$(stat -f "%z" $log_file)

        succeeded=true
        #if the log is larger, check for an error
        if [ $new_log_size -gt $old_log_size ] ; then
            #can't rely on exit code here... convert to using tail and =~
            last=$(tail -n2 $log_file)
            if [[ $last =~ 'status 1' ]] ;then
                echo $F >> $failed_log
                rm "$js_out"
                succeeded=false
            fi
        fi
        if $succeeded; then
            echo "Generating preview image $i_out" 
            convert -font "$F" -background "#fffaf0" -fill black -size 150x70 -gravity center label:"$fname" $i_out
            echo "$fname $js_out" >> "$3/files.txt"
        fi
        echo "--------------------" >> $log_file
    done
done

echo "Making image montage"
montage -label '' $3/*/*png -tile 4x -geometry +0+0 "$3/font_sprite.png"

if [ $(stat -f "%z" $failed_log) -gt 0 ] ; then
    echo "These failed: "
    cat $failed_log
fi

IFS=${old_ifs}
