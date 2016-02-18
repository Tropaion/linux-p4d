
# -----------------------
# example for HOME Matic
# -----------------------

# ---------------------
# User settings

HM_IP="192.168.1.4"
HM_PORT="8181"
DB_HOST="localhost"
HM_URL_BASE="http://$HM_IP:$HM_PORT/Text.exe?Antwort=dom.GetObject%28%22"

# list of parameters like "address#type address#type ..."

SENSORS="1#UD 2#UD 3#Ud 4#UD 21#VA 22#VA 25#VA 26#VA"
#0#DO 0#VA 1#DO"

# ---------------------
# script

MYSQL="mysql --batch --silent --host=$DB_HOST -u p4 -pp4 -Dp4 --default-character-set=utf8"

MAXTIME=`$MYSQL -e "select max(time) from samples;"`

for s in $SENSORS; do

    TYPE=`echo $s | sed s/".*#"/""/g`
    ADDR=`echo $s | sed s/"#.*"/""/g`

    if [ "$1" == "debug2" ]; then
        echo -------------------------------------------
        echo "select concat(replace(case when f.usrtitle is null or f.usrtitle = '' then f.title else f.usrtitle end, ' ', '%20'), '%22%29.State%28', s.value, '%29') from samples s, valuefacts f \
          where f.address = s.address and f.type = s.type \
          and time = '$MAXTIME' and s.address = '$ADDR' and s.type = '$TYPE';"
    fi

    PARAMS=`$MYSQL -e "select concat(replace(case when f.usrtitle is null or f.usrtitle = '' then f.title else f.usrtitle end, ' ', '%20'), '%22%29.State%28', s.value, '%29') from samples s, valuefacts f \
          where f.address = s.address and f.type = s.type \
          and time = '$MAXTIME' and s.address = $ADDR and s.type = '$TYPE';"`

    if [ "$1" == "debug" ]; then
        echo curl "$HM_URL_BASE$PARAMS;"
    else
        curl "$HM_URL_BASE$PARAMS;" > /dev/null 2>&1
    fi
       
done

