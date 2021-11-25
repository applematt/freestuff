#!/bin/bash
#
# a simple utility to convert *.(MP|mp)4 files into an MP3 with a normalized filename.
# requires ffmpeg in your path
#
# we have error handling built-in, so this isn't necessarily needed
# + unless you're paranoid.
# set -e

# variables

# misc
declare -a FORMATS
declare -a FILES
FORMATS=( "mp4" "MP4" "mkv" "MKV" "webm" "WEBM" )
WORKDIR="$(pwd)"
FFMPEG="$(which ffmpeg)"
DEBUG=0
MP3COUNT=0

# commonly used exit codes
E_SUCCESS=0
E_FAIL=1
E_GENFAIL=89

# color codes
C_RESET="\e[0m"
C_BOLD="\e[1m"
C_ULINE="\e[4m"
C_RED="\e[31m"
C_GREEN="\e[32m"
C_YELLOW="\e[33m"
C_BLUE="\e[34m"
C_LGREEN="\e[92m"
C_BGRED="\e[7;49;31m"
C_BGGREEN="\e[7;49;32m"
C_BGYELLOW="\e[7;49;33m"
C_BGBLUE="\e[7;49;34m"
C_BGWHITE="\e[7;49;37m"

# functions

# printer function for printing preformatted or auto-formatted messages (with color)
# colors: info = white, warn = yellow, fail = red
printer () {
    case "$1" in
	info)
	    shift
	    printf "${C_BGWHITE}[info]${C_RESET} ${1}\n"
	    ;;
	warn)
	    shift
	    printf "${C_BGYELLOW}[warn]${C_RESET} ${1}\n"
	    ;;
	fail)
	    shift
	    printf "${C_BGRED}[fail]${C_RESET} ${1}\n"
	    ;;
	text)
	    shift
	    printf "${1}"
	    ;;
    esac
}

# spinner function to display pretty "please wait" text during long-running commands
spinner () {
    # PID of most recently executed background pipeline
    PID=$!

    # Store the background process id in a temp file to use in err_handler
    TMPFILE=$(mktemp)
    echo $(jobs -p) > "${TMPFILE}"

    # Create spinner array
    SPINNER[0]="-"
    SPINNER[1]="\\\\"
    SPINNER[2]="|"
    SPINNER[3]="/"

    # Loop while the process is running
    while kill -0 $PID 2>/dev/null
    do
	for SPINCHAR in "${SPINNER[@]}"
	do
	    if kill -0 $PID 2>/dev/null
	    then
		# Display the spinner in 1/4 states
		printf "\b\b\b\b${C_BOLD}[${C_RESET}${C_LGREEN}$SPINCHAR${C_RESET}${C_BOLD}]${C_RESET} " >&9
		sleep .5
	    else
		break
	    fi
	done
    done

    # Check if background process failed
    if wait $PID
    then
	printf "\b\b\b\b${C_BOLD}[${C_RESET}${C_LGREEN}-done-${C_RESET}${C_BOLD}]${C_RESET} \n" >&9
    else
	RTCVAL=$?
	false
    fi

    # Set background process id value to -1 representing no background process running to err_handler
    echo "-1" > "${TMPFILE}"
    tput sgr0 >&9
    rm -f $TMPFILE
    return $RTCVAL
}

# perform standard clean-up operations
cleanup () {
	# close fd 9
	exec 9>&-	
}

# miscellaneous environment settings
# Sets file descriptor to 9 for the special printer function and the spinner.
exec 9>&1
# run cleanup operations on exit (like closing our file descriptor)
trap cleanup EXIT

# main
[ -z "$FFMPEG" ] \
    && printer fail "ffmpeg is required, but could not be found in your path.\n\tPATH=${PATH}" \
    && exit $E_GENFAIL

printer text "${C_BOLD}[NOTICE]${C_RESET} I only operate on the current working directory.\n\nYou are in: ${C_BGBLUE}${WORKDIR}${C_RESET}\n\nFiles with the following extensions will be harmlessly converted into an MP3 file:\n\n${FORMATS[*]}\n"

for FORMAT in ${FORMATS[@]}
do
    for FILE in "$WORKDIR"/*.$FORMAT
    do
	[ -e "$FILE" ] \
	    && let MP3COUNT+=1 \
	    && FILES=( "${FILES[@]}" "$FILE" ) \
	    && [ $DEBUG -eq 1 ] && printer text "\nFound: $FILE\n"
    done
done

[ $MP3COUNT -lt 1 ] \
    && printer text "\n${C_BLUE}No files found.${C_RESET}\n" \
    && exit $E_SUCCESS \
    || printer text "\n${C_BLUE}${MP3COUNT} files found.${C_RESET}\n" \

while [[ ! $REPLY =~ [ynYN] ]]
do
    read -e -p "Continue? [y/n, Y/N] " -n 1
    if [[ $REPLY =~ [nN] ]]
    then
	printer text "\nExiting.\n"
	exit $E_FAIL
    fi
done

for FILE in "${FILES[@]}"
do
    FILEBASE="${FILE##/*/}"
    printer text "\n"
    printer info "Now processing: ${C_BOLD}${FILEBASE}${C_RESET}"
    # i'm silly and don't know any other way
    # + to do this (natively) in bash.
    FILEOUT="${FILEBASE//\_/-}"
    FILEOUT="${FILEOUT// /_}"; FILEOUT="${FILEOUT//\._/_}"; FILEOUT="${FILEOUT// _ /_}"
    FILEOUT="${FILEOUT//_-/-}"; FILEOUT="${FILEOUT//-_/-}"; FILEOUT="${FILEOUT// _/-}"
    FILEOUT="${FILEOUT//[\#\&\+\'\(\)\,\:\[\]\!]/}"
    FILEOUT="${FILEOUT//__/}"; FILEOUT="${FILEOUT//--/}"; FILEOUT="${FILEOUT// /}"
    for EXT in ${FORMATS[@]}
    do
	FILEOUT="${FILEOUT/\.$EXT/.mp3}"
    done

    [ -e $FILEOUT ] \
	&& printer warn "File exists: ${C_YELLOW}${FILEOUT}${C_RESET}" \
	&& printer warn "This file already exists. Assuming re-run and moving on ..." \
	&& continue

    # -write_xing 0 is maybe mac-specific?
    $FFMPEG -loglevel error -report -n -ignore_unknown -i "$FILE" -f mp3 -write_xing 0 "$WORKDIR/$FILEOUT" & spinner
    if [[ $? -eq 0 ]]
    then
	printer text "${C_BGGREEN}[ding]${C_RESET} Fries are done: ${C_GREEN}${FILEOUT}${C_RESET}\n"
    else
	printer fail "ERROR PROCESSING: ${FILE}"
    fi
done

printer text "\nDone!\n"

exit $E_SUCCESS
