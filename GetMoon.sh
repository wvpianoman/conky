#!/bin/bash


# -------------------------------------------------------------------
# File: GetMoon.sh                                       /\
# Type: Bash Shell Script                               /_.\
# By Fernando Gilli fernando<at>wekers(dot)org    _,.-'/ `",\'-.,_
# Last modified:2020-12-27                     -~^    /______\`~~-^~:
# ------------------------
# Get Moon data from moongiant.com
# / OS : $Linux, $FreeBSD (X Window)
# -------------------------------------------------------------------

# ****************************

# Working directory
DirShell="$HOME/.conky/wekers"

# set language
lang="pt-br"

# put your hemisphere here:
# n for north
# s for south
hemisphere=s

# ****************************


# function: moonrise_set
moonrise_set () {
    case "$1" in
                "FirstQuarter")
                   echo "Noon/Midnight"
                ;;

                "FullMoon")
                   echo "6PM/6AM"
                ;;

                "LastQuarter")
                   echo "Midnight/Noon"
                ;;

                "NewMoon")
                   echo "6AM/6PM"
                ;;

                "WaningCrescent")
                   echo "3AM/3PM"
                ;;

                "WaningGibbous")
                   echo "9PM/9AM"
                ;;

                "WaxingCrescent")
                   echo "9AM/9PM"
                ;;

                "WaxingGibbous")
                   echo "3PM/3AM"
                ;;

                *)
                   echo "Unavailable"
        esac
}



wget -q -O ${DirShell}/raw "http://www.moongiant.com/phase/today" > /dev/null 2>&1


[ -f ${DirShell}/moon_tmp.jpg ] && rm ${DirShell}/moon_tmp.jpg
[ -f ${DirShell}/moon.jpg ] && rm ${DirShell}/moon.jpg

sed -i -e '/^ *$/d' -e 's/^ *//g' ${DirShell}/raw
sed -i '/var jArray=\|"todayMoonContainer"/!d' ${DirShell}/raw
sed -i -e '/var jArray/s/","/\n/g' -e 's/<span>\|<b>\|<\\\/span>\|<\\\/b>\|\\n//g' ${DirShell}/raw
sed -i 's/"\].*\[\"/\n/g' ${DirShell}/raw
sed -i '/var jArray/d' ${DirShell}/raw
sed -i -e 's/"\]};//g' -e 's/^.*today_phase\///g' -e 's/\.jpg.*$//g' ${DirShell}/raw
phase=$(sed -n 7p ${DirShell}/raw|sed 's/ //')
mrise_mset=$(moonrise_set $phase)
sed -i 7a$(moonrise_set $phase) ${DirShell}/raw
img_in=$(sed -n 50p ${DirShell}/raw)
now=$(date --date="now" +%H)



# Moon image
if [[ $now >=18 || $now < 06 ]]; then
  
# day moon -> more light
  sleep 1
  wget -q --output-document=${DirShell}/moon_tmp.jpg https://www.moongiant.com/images/today_phase/$img_in.jpg > /dev/null 2>&1


else

# night moon -> dark
# Can't download direct with wget
# To get moon image -> Pass Cloudflare DDOS Protection
  sleep 1
  curl https://static.die.net/moon/210.jpg --output "${DirShell}"/moon_tmp.jpg \
    -H 'Host: static.die.net' \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:33.0) Gecko/20100101 Firefox/33.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
    -H 'Accept-Language: en-US,en;q=0.5' \
    -H 'Referer: https://static.die.net/moon' \
    -H 'Connection: keep-alive' --compressed 
    
fi



sleep 1

# mirror moon image, hemisphere south
if [[ $hemisphere == s ]]; then
  convert -flop -colorspace rgb ${DirShell}/moon_tmp.jpg ${DirShell}/moon.jpg
  rm ${DirShell}/moon_tmp.jpg
else
  convert -colorspace rgb ${DirShell}/moon_tmp.jpg ${DirShell}/moon.jpg
  rm ${DirShell}/moon_tmp.jpg
fi


# Translate pt-br (moon phase name)
if [[ $lang == "pt-br" ]]; then

          sed -i -e 's/New Moon/Lua Nova/g' ${DirShell}/raw
	  sed -i -e 's/Full Moon/Lua Cheia/g' ${DirShell}/raw
	  sed -i -e 's/Waxing Crescent/Lua Crescente/g' ${DirShell}/raw
	  sed -i -e 's/Waxing Gibbous/Lua Crescente/g' ${DirShell}/raw
	  sed -i -e 's/Waning Crescent/Lua Minguante/g' ${DirShell}/raw
	  sed -i -e 's/Waning Gibbous/Lua Minguante/g' ${DirShell}/raw
	  sed -i -e 's/First Quarter/Quarto Crescente/g' ${DirShell}/raw
	  sed -i -e 's/Last Quarter/Quarto Minguante/g' ${DirShell}/raw

fi

# exec too
sh ${DirShell}/lune_die.sh > /dev/null 2>&1

#EOF

