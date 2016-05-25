#!/bin/bash
#
# Script name: count_files.sh
#
# Description: Counts the number of files of each filetype in current directory and its
# subdirectories.
#
# Input: None
#
# Output: Prints out extension followed by the number of files found with that extension
# type.
#
# Pseudocode: The script took the basename of every file found and counted the number of
# files that contained no '.' in their name, storing it in $noext. It then found the
# basenames again, ignoring the files already counted in noext, delimiting by '.' and
# taking the last field, sorting, and counting the number of each type. 

 
noext=0
for basename in `find -type f | awk -F/ '{ print $NF}'`
do
        # Count files that have no extension
        if [[ "$basename" != *"."* ]]; then
                let noext=$noext+1
        fi
done

#print number of files with no extension
echo "      $noext noext"
#find and count all other files and ext types 
find -type f | awk -F/ '{print $NF}' | grep . | awk -F. '{print $NF}' | sort | uniq -c

