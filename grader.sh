#!/bin/bash

display_usage() {
    echo "Usage: [path/to/executable] [path/to/testacase/folder] [time limit]"
    exit
}

if [ "$#" -ne 3 ]; then
    display_usage
    exit 1
fi

PROGRAM=$1
TEST_FILES=$2
TIME_LIMIT=$3

RED="tput setaf 1"
GREEN="tput setaf 2"
RESET="tput sgr0"

COUNTER=0
PASSED=0
FAILED=0
for file in `ls $TEST_FILES/input* | sort -V`;
do
	(( COUNTER += 1))
	file="$file"
	infile=${file/"$TEST_FILES/"/}
        outfile="${infile/input/output}"
	OUT=$(cat "$TEST_FILES"/"$outfile")
	IN_TIME=$(date +%s.%N)
        MY_OUT=$(./"$PROGRAM" < "$TEST_FILES"/"$infile")
	OUT_TIME=$(date +%s.%N)
	TOTAL_TIME=$(bc -l <<< "scale=2; $OUT_TIME-$IN_TIME")
	if [ "$OUT" == "$MY_OUT" ]; then
		printf $infile;
                printf ": "
		if (( $(bc -l <<< "$TOTAL_TIME < $TIME_LIMIT") )); then
                	${GREEN}
                	(( PASSED += 1 ))
                	printf "Passed ";
                else
			${RED}
			(( FAILED += 1 ))
			printf "Time Exceeded ";
		fi
		${RESET}
        else
		(( FAILED += 1 ))
                printf $infile;
                printf ": "
                ${RED};
                printf "Wrong Answer ";     
        fi
	${RESET}
	printf " $TOTAL_TIME sec\n";

done

PASS_RATE=$(bc -l <<< "scale=2; $PASSED * 100 / $COUNTER")
echo ""
echo "==========================="
echo "ALL = $COUNTER"
${GREEN}
echo "PASSED = $PASSED"
${RED}
echo "FAILED = $FAILED"
${RESET}
echo "==========================="

exit 0
