# Contains small functions sourced by ~/.bashrc
# Contents as of September 2015: round, bkp, wscp, extract

# "round()" was modified from 
# http://stempell.com/2009/08/rechnen-in-bash/
# It allows you to evaluate and round math expressions with
# floating point numbers
round () {
  # Make sure only 1 or 2 variables passed
  if [ "$#" -gt 2 ] || [ "$#" == 0 ] ; then
    echo 'Usage: round "expr" scale. Default scale is 0'
    return 1
  elif [ "$#" == 1 ] ; then
    # If no scale was passed, set scale to 0
    set -- "${@:1}" "0"
  fi

  # Make sure scale >= 0
  if [ "$2" -lt 0 ] ; then
    echo "Scale must be >= 0"
    return 1
  fi

  # Evaluate
  if [ "$2" == 0 ] ; then
    echo $(printf %.0f $(echo "scale=0;($1+0.5)/1" | bc))
  else
    echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*($1))+0.5)/(10^$2)" | bc))
  fi
}

# Shortcut for executing a command within each subdirectory
all () {
  for d in */; do
    cd $d
    ("$1")
    cd ../
  done
}

# Changes all files in current directory of the form w*.all to w*.res
w_all_to_res () {
  for f in w*.all; do
    mv $f ${f%.all}.res
  done
}

# Shortcut for (git add *; git commit -m "message"; git push origin master)
gu () {
    if [ "$#" -ne 1 ]; then
        echo 'Usage: gu "commit message"'
        return 1
    fi
    git add *
    git commit -m "$1"
    git push origin master
}

# Creates a backup folder in ~/tmp containing copies of files passed
# to the function.
# Format = YYYY-MM-DD-bkp-#
bkp ()
{
    # Create tmp directory if it doesn't exist
    mkdir -p $HOME/tmp
    DATE=$(date +%F)
    c=1
    while [ -e ~/tmp/$DATE-bkp-$c ]
    do
        if [ $c -gt 1000 ]
        then
            # something probably went wrong if c got up to 1000
            echo "Exiting bkp. c got up to $c in while loop."
            return 0
        fi
        c=$(($c+1))
    done
    bkp_dir=~/tmp/$DATE-bkp-$c
    mkdir $bkp_dir
    cp -r --parents $@ $bkp_dir
    echo "Created backup folder $bkp_dir"
}

# scp to work computer
wscp() {
    if [ "$#" == 0 ] ; then
        echo "No files provided."
        return 1
    fi
    scp -r $@ lindsb@TWN345-2.seas.upenn.edu:/Users/lindsb/Desktop
}

# Extract function to unpack zipped files
# Courtesy of https://bbs.archlinux.org/viewtopic.php?id=110601
extract () {
   if [ -f $1 ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf $1 && cd $(echo $1 | sed 's/.tar.bz2//')    ;;
           *.tar.gz)    tar xvzf $1 && cd $(echo $1 | sed 's/.tar.gz//')    ;;
           *.bz2)       bunzip2 $1 && cd $(echo $1 | sed 's/.bz2//')    ;;
           *.rar)       unrar x $1 && cd $(echo $1 | sed 's/.rar//')    ;;
           *.gz)        gunzip $1 && cd $(echo $1 | sed 's/.gz//')    ;;
           *.tar)       tar xvf $1 && cd $(echo $1 | sed 's/.tar//')    ;;
           *.tbz2)      tar xvjf $1 && cd $(echo $1 | sed 's/.tbz2//')    ;;
           *.tgz)       tar xvzf $1 && cd $(echo $1 | sed 's/.tgz//')    ;;
           *.zip)       unzip $1 && cd $(echo $1 | sed 's/.zip//')    ;;
           *.Z)         uncompress $1 && cd $(echo $1 | sed 's/.Z//')    ;;
           *.7z)        7z x $1 && cd $(echo $1 | sed 's/.7z//')    ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file!"
   fi
 }
