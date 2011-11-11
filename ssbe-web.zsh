# Curl webservice setuff.

autoload colors ; colors


function colindex {
  indent_level++
  COLOR=indent_colors[indent_level]
  echo -e "\$fg[$COLOR]]"
}

export ACCEPT_HEADER="Accept: application/vnd.absperf.sskj1+json, application/vnd.absperf.ssaj1+json, application/vnd.absperf.sscj1+json, application/vnd.absperf.ssmj1+json, application/vnd.absperf.sswj1+json, application/vnd.absolute-performance.syshep+json, application/x-sysshep+json, text/plain"
export ACCEPT_XML='Accept: application/vnd.absperf.ssac1+xml'
export ACCEPT_SSJ="Accept: application/x-sysshep+json"
export ACCEPT_WW="Accept: application/vnd.absperf.sswcj1+json"


CONTENT_SSCJ='Content-Type: application/vnd.absperf.sscj1+json'
CONTENT_SSAC='Content-Type: application/vnd.absperf.ssac1+json'
CONTENT_SSJ='Content-Type: application/vnd.absperf.ssj+json'
CONTENT_SSKJ='Content-Type: application/vnd.absperf.sskj1+json'
CONTENT_SSMJ='Content-Type: application/vnd.absperf.ssmj1+json'
CONTENT_SSAJ='Content-Type: application/vnd.absperf.ssaj1+json'
CONTENT_SSWJ='Content-Type: application/vnd.absperf.sswj1+json'

STD_ARG=(-v --anyauth -u $SSBE_USER:$SSBE_PASS)

export STD_ARG
NONVERBOSE_ARG=(--anyauth -u $SSBE_USER:$SSBE_PASS)

TIDYJSON=(ruby -rubygems -e "require 'json';puts JSON.pretty_generate(JSON.parse(STDIN.read),{:space_before => '$fg[magenta] ',:space => '$fg[cyan] ',:indent => '$fg[pr_green]  '}).gsub('\/','/')")

TIDYJSONNOCOL=(ruby -rubygems -e "require 'json';puts JSON.pretty_generate(JSON.parse(STDIN.read)).gsub('\/','/')")

function ndcurl {
  curl -v --anyauth -u $SSBE_USER:$SSBE_PASS -H "$ACCEPT_HEADER" "$@"
}

function devndcurl {
  curl $DEV_ARG -H "$ACCEPT_HEADER" "$@"
}

function dcurl {
  ndcurl "$@" | $TIDYJSON
}
function bwcurl {
  ndcurl "$@" | $TIDYJSONNOCOL
}
function vcurl {
  # requires netRW to really be useful, http://www.vim.org/scripts/script.php?script_id=1075
  # once that is installed, you can use the gf commend in vim to follow links in json docs.
  bwcurl $@ | vim --cmd 'let no_plugin_maps=1' -c 'set ft=json' -c 'au VimEnter * set nomod' -
}
function mcurl {
  dcurl -H $CONTENT_SSMJ -d $@
}

# SSCJ
function getsscj {
  dcurl -H $CONTENT_SSCJ $@
}
function putsscj {
  dcurl -X PUT -H $CONTENT_SSCJ -d $@
}
function postsscj {
  dcurl  -X POST -H $CONTENT_SSCJ -d $@
}
function delsscj {
  dcurl -X DELETE -H $CONTENT_SSCJ $@
}

# SSAC
function getssac {
  dcurl -H $CONTENT_SSAC -d $@
}
function putssac {
  dcurl -X PUT -H $CONTENT_SSAC -d $@
}
function postssac {
  dcurl -X POST -H $CONTENT_SSAC -d $@
}
function delssac {
  dcurl -X DELETE -H $CONTENT_SSAC $@
}

# SSJ
function getssj {
  curl $STD_ARG -H $ACCEPT_SSJ $@ | $TIDYJSON
}
function putssj {
  dcurl -X PUT -H $CONTENT_SSJ -d $@
}
function postssj {
  dcurl -X POST -H $CONTENT_SSJ -d $@
}
function delssj {
  dcurl -X DELETE -H $CONTENT_SSJ $@
}

# SSKJ
function getsskj {
  dcurl -H $CONTENT_SSKJ $@
}
function putsskj {
  dcurl -X PUT -H $CONTENT_SSKJ -d $@
}
function postsskj {
  dcurl -X POST -H $CONTENT_SSKJ -d $@
}
function delsskj {
  dcurl -X DELETE -H $CONTENT_SSKJ $@
}

# SSMJ
function getssmj {
  dcurl -H $CONTENT_SSMJ $@
}
function putssmj {
  dcurl -X PUT -H $CONTENT_SSMJ -d $@
}
function postssmj {
  dcurl -X POST -H $CONTENT_SSMJ -d $@
}
function delssmj {
  dcurl -X DELETE -H $CONTENT_SSMJ $@
}

# SSAJ
function getssaj {
  dcurl -H $CONTENT_SSAJ $@
}
function putssaj {
  dcurl -X PUT -H $CONTENT_SSAJ -d $@
}
function postssaj {
  dcurl -X POST -H $CONTENT_SSAJ -d $@
}
function delssaj {
  dcurl -X DELETE -H $CONTENT_SSAJ $@
}

# SSWJ
function getsswj {
  dcurl -H $CONTENT_SSWJ $@
}
function putsswj {
  dcurl -X PUT -H $CONTENT_SSWJ -d $@
}
function postsswj {
  dcurl -X POST -H $CONTENT_SSWJ -d $@
}
function delsswj {
  dcurl -X DELETE -H $CONTENT_SSWJ $@
}

# Other
function getxml {
  curl $STD_ARG -H $ACCEPT_XML $@
}
function postform {
  curl -d $@
}

function getww {
  curl $STD_ARG -H $ACCEPT_WW $@
}

function ecurl {
  dcurl $@ 2>/tmp/.ssws.err | grep -vP '("href"|ed_at"|"id")' > /tmp/.ssws.out || exit -1
  cp -a /tmp/.ssws.out /tmp/.ssws.out.ref
  vim --cmd 'let no_plugin_maps=1' -c 'set ft=json' -c 'au VimEnter * set nomod' /tmp/.ssws.out
  CONTENT_TYPE=`cut -f2- -d' ' /tmp/.ssws.err | grep Content-Type | tail -1`
  if [ `find /tmp/.ssws.out -newer /tmp/.ssws.out.ref | wc -l` -gt 0 ]; then
    dcurl -X PUT -d@/tmp/.ssws.out -H $CONTENT_TYPE $@
    if [ $? -ne 0 ]; then
      mv /tmp/.ssws.out /tmp/ssws.out
      rm -f /tmp/.ssws.out.ref /tmp/.ssws.out
      echo "ERROR! Check /tmp/ssws.out"
    fi
  else
    echo "No changes"
  fi

rm -f /tmp/.ssws.err /tmp/.ssws.out /tmp/.ssws.out.ref
}


function li_report_color {
# fuck yes check this shit out
 curl $NONVERBOSE_ARG -s -H "$ACCEPT_HEADER" "$@" | ruby -rubygems -e "require 'json';require 'time';JSON.parse(STDIN.read)['items'].sort {|a,b| a['clientname'] <=> b['clientname']}.each {|i| printf(\"%18.18s %-38.38s %s%5i %s\n\", \"$fg[green]#{i['clientname']}\",\"$fg[white]#{i['hostname']}\",\"$fg[red]\",(Time.now-Time.parse(i['last_message'])).to_i/60,\" minutes ago$fg[white]\")}"
}

function li_report {
# fuck yes check this shit out
 curl $NONVERBOSE_ARG -s -H "$ACCEPT_HEADER" "$@" | ruby -rubygems -e "require 'json';require 'time';JSON.parse(STDIN.read)['items'].sort {|a,b| a['clientname'] <=> b['clientname']}.each {|i| printf(\"%18.18s %-38.38s %s%5i %s\n\", \"#{i['clientname']}\",\"#{i['hostname']}\",\"\",(Time.now-Time.parse(i['last_message'])).to_i/60,\" minutes ago\")}"
}
