#!/bin/bash

DIR=students
FILE=LCP_22-23_students.csv
Physics=Physics.csv
PoD=PoD.csv

if [ -d "$DIR" ];
then
    echo "$DIR directory already exist."
else
	echo "Creating $DIR directory"
	mkdir $DIR
fi

cd $DIR

if [ -f "$FILE" ];
then
    echo "$FILE already exists."
else
	echo "Downloading $FILE"
	wget https://www.dropbox.com/s/867rtx3az6e9gm8/LCP_22-23_students.csv
	echo "$FILE Downloaded"
fi

# append end of line at the end of file only if it's not already there
# this is done so the while loop over file doesn't skip the last line
sed -i -e '$a\' $FILE

# create files with PoD and Physics students

# initialize files with header and then append the rest
grep "Family name(s)" $FILE > $Physics
grep "Physics" $FILE >> $Physics

grep "Family name(s)" $FILE > $PoD
grep "PoD" $FILE >> $PoD

# initialize loop variables
max=$(grep -c "^A" $FILE)
maxL="A"

# find the letter with most counts
for x in {A..Z}
do
	c=$(grep -c "^$x" $FILE)
    echo "$x: $c"
	if [ $c -gt $max ];
	then
		max=$c
		maxL=$x
	fi
	
done

echo "The letter with most counts is $maxL, with a total of $max students"

# create files with "modulo 18" students groups

# initialize loop variables
nLine=0
nGroup=18
skipHeader=0

while read line;
do
	# skip header
	if (( skipHeader==0 ));
	then
		((skipHeader++))
		continue
	fi
	
	# set file name
	group=$(( nLine%nGroup ))
	groupFile="group$group.csv"
	
	# overwrite new files
	if (( nLine < nGroup ));
	then
		echo -n "" > $groupFile
	fi
	
	# append line on file
	echo "$line" >> $groupFile
	
	# increment line number
	((nLine++))

done < $FILE