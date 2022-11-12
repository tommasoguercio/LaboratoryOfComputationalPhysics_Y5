#!/bin/bash

DIR=data
FILE=data.csv
FILETXT=data.txt

# change directory
if [ -d "$DIR" ];
then
    echo "$DIR directory already exist."
else
	echo "Creating $DIR directory"
	mkdir $DIR
fi

cp $FILE ./$DIR/$FILE

cd $DIR

# check if file exist
if [ ! -f "$FILE" ];
then
	echo "$FILE doesn't exist. Terminating bash script..."
	exit
fi

# copy csv file into txt file
cp $FILE $FILETXT

# delete metadata and commas
sed -i -e 's/#.*$//' $FILETXT
sed -i -e 's/,//g' $FILETXT

# delete empty lines
sed -i -e '/^$/d' $FILETXT

# append end of line at the end of file only if it's not already there
# this is done so the while loop over file doesn't skip the last line
sed -i -e '$a\' $FILETXT

# highlight even numbers
# grep --color '\w*[02468]\>' $FILETXT

# count even numbers
evNum=$(grep -o '\w*[02468]\>' $FILETXT | wc -l)
echo "There are $evNum even numbers in $FILETXT"

# loop over file to find entries smaller or greater than 100*sqrt(3)/2
threshold=$( echo 'scale=10;100*sqrt(3)/2' | bc)

# initialize counters
higher=0
lower=0

while read line;
do
	# split string line into an array
	read -r -a array <<< "$line"
	
	# compute sqrt(X^2 + Y^2 + Z^2) and compare to threshold
	
	# first loop is for xyz, second is for x'y'z'
	for i in 0 3;
	do
		x=${array[i]}
		y=${array[i+1]}
		z=${array[i+2]}
		module=$( echo "scale=10;sqrt($x^2 + $y^2 + $z^2)" | bc)
		
		if (( $(echo "$module > $threshold" |bc) ));
		then
			((higher++))
		else
			((lower++))
		fi
		
	done

done < $FILETXT

echo "$higher entries are higher than $threshold"
echo "$lower entries are lower than $threshold"

# checking if the user provided an input
if [ -z $1 ];
then
    echo "this script requires as input the number of copies to be created"
    exit
fi

for (( i=1; i<=$1; i++ ));
do
	# create and overwrite new file
	divFile="data$i.txt"
	touch $divFile
	echo -n "" > $divFile
	echo "writing on $divFile ..."
	
	# divide all values by i
	while read line;
	do
		# split string line into an array
		read -r -a array <<< "$line"
		
		# first loop over line values
		for j in {0..5};
		do
			# determine how many decimals to print
			if (( $i == 1 ))
			then
				s=0
			else
				if (( $i == 2 ))
				then
					s=1
				else
					s=2
				fi
			fi
			
			n=$( echo "scale=($s);${array[j]}/$i" | bc)
			echo -n "$n " >> $divFile
			
		done
		
		# print newline
		echo "" >> $divFile

	done < $FILETXT
	
done
