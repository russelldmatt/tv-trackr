#!/bin/bash

function parse-episode() {
    pup 'json{}' \
	| jq '.[0].children | .[0] | .children | .[1].children | .[0].children' \
 	| jq -c '{ 
episode : .[0].children | .[0].text,
name : .[1].children | .[0].text,
aire_date : .[0].children | .[1].text,
}' 
}
   
function parse-episode-list() { 
    pup .tvobject-episode-col-info \
	| pup-print-machine \
	| while read episode_html; do echo $episode_html | parse-episode ; done
}

function pad-episode-number() { 
    sed 's/Episode \([0-9]\)"/Episode 0\1"/g'
}

function pad-season-number() { 
    sed 's/Season \([0-9]\),/Season 0\1,/g'
}

function sort-episodes {
    jq -c . | pad-season-number | pad-episode-number | sort 
}

function query-all-seasons() {
    name=$1
    show_id=$2
    num_seasons=$3;
    for season in $(seq 1 $num_seasons); do 
	curl "http://www.tvguide.com/tvshows/${name}/episodes-season-${season}/${show_id}/" | parse-episode-list 
    done
}
    
function query-last-man-on-earth() { query-all-seasons the-last-man-on-earth 658293 3; }
function query-broad-city() { query-all-seasons broad-city 622634 3; }
function query-ballers() { query-all-seasons ballers 795630 2; }
function query-brooklyn-99() { query-all-seasons brooklyn-nine-nine 555483 4; }
function query-game-of-thrones() { query-all-seasons game-of-thrones 305628 6; }
function query-modern-family() { query-all-seasons modern-family 297616 8; } 
function query-south-park() { query-all-seasons south-park 100402 20; }
function query-its-always-sunny-in-philadelphia() { query-all-seasons its-always-sunny-in-philadelphia 191585 11; }
function query-the-league() { query-all-seasons the-league 299011 7; }
function query-narcos() { query-all-seasons narcos 586956 2; }
function query-the-night-of() { query-all-seasons the-night-of 924264 1; }
function query-westworld() { query-all-seasons westworld 724110 1; }

function query-all-and-store-in-show-episodes-dir() { 
    query-last-man-on-earth > show-episodes/last-man-on-earth.json
    query-broad-city > show-episodes/broad-city.json
    query-ballers > show-episodes/ballers.json
    query-brooklyn-99 > show-episodes/brooklyn-99.json
    query-game-of-thrones > show-episodes/game-of-thrones.json
    query-modern-family > show-episodes/modern-family.json
    query-south-park > show-episodes/south-park.json
    query-its-always-sunny-in-philadelphia > show-episodes/its-always-sunny-in-philadelphia.json
    query-the-league > show-episodes/the-league.json
    query-narcos > show-episodes/narcos.json
    query-the-night-of > show-episodes/the-night-of.json
    query-westworld > show-episodes/westworld.json
}

# cat page-*.html \
#     | pup '.case' \
#     | pup-print-machine 2>/dev/null \
#     | pup 'json{}' \
#     | jq '.children | .[1].children | .[]' \
#     | jq -c '{ 
# zagat_id : .["data-id"], 
# href : .["href"], 
# name : .children | .[1].children | .[0].text, 
# food : .children | .[1].children | .[2].children | .[0].children | .[0].children | .[1].text,
# decor : .children | .[1].children | .[2].children | .[0].children | .[1].children | .[1].text,
# service : .children | .[1].children | .[2].children | .[0].children | .[2].children | .[1].text,
# cost : .children | .[1].children | .[2].children | .[0].children | .[3].children | .[1].text,
# cuisine : .children | .[1].children | .[1].children | .[0].text,
# neighborhood : .children | .[1].children | .[1].children | .[1].text,
# }' \
#     | sed 's/\$//g' \
#     | json2csv -p -k zagat_id,name,href,food,decor,service,cost,cuisine,neighborhood \
#     | sed 's/,-,/,,/g' \
#     | sed 's/,-,/,,/g' \
#     | ( read header; echo $header; sort | uniq ) \
#     | cat > manhattan.csv

# csvjoin <(cat manhattan.csv | sed 's/cost/zagat_cost/g') <(csvcut -c cost manhattan.csv | (read x; echo $x; sed 's/I/20/' | sed 's/M/35/g' | sed 's/VE/80/g' | sed 's/E/50/g' | sed 's/Ã‚//g' )) \
#     | csvcut -c zagat_id,name,href,food,decor,service,cost,zagat_cost,cuisine,neighborhood \
#     | cat > manhattan-joined.csv



