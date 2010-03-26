# Curl webservice setuff.

autoload colors ; colors


function colindex {
  indent_level++
  COLOR=indent_colors[indent_level]
  echo -e "\$fg[$COLOR]]"
}

ACCEPT_HEADER="Accept: application/vnd.absperf.sskj1+json, application/vnd.absperf.ssaj1+json, application/vnd.absperf.sscj1+json, application/vnd.absperf.ssmj1+json, application/vnd.absolute-performance.syshep+json, application/x-sysshep+json, text/plain"
ACCEPT_XML='Accept: application/vnd.absperf.ssac1+xml'
ACCEPT_SSJ="Accept: application/x-sysshep+json"


CONTENT_SSCJ='Content-Type: application/vnd.absperf.sscj1+json'
CONTENT_SSAC='Content-Type: application/vnd.absperf.ssac1+json'
CONTENT_SSJ='Content-Type: application/vnd.absperf.ssj+json'
CONTENT_SSKJ='Content-Type: application/vnd.absperf.sskj1+json'
CONTENT_SSMJ='Content-Type: application/vnd.absperf.ssmj1+json'

STD_ARG=(-v --anyauth -u dev:dev)
NONVERBOSE_ARG=(--anyauth -u dev:dev)

TIDYJSON=(ruby -rubygems -e "require 'json';puts JSON.pretty_generate(JSON.parse(STDIN.read),{:space_before => '$fg[magenta] ',:space => '$fg[cyan] ',:indent => '$fg[pr_green]  '}).gsub('\/','/')")

TIDYJSONNOCOL=(ruby -rubygems -e "require 'json';puts JSON.pretty_generate(JSON.parse(STDIN.read)).gsub('\/','/')")

function ndcurl { 
  curl $STD_ARG -H "$ACCEPT_HEADER" "$@" 
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
function postsscj {
  dcurl  -H $CONTENT_SSCJ -d $@
}
function putsscj {
  dcurl -X PUT -H $CONTENT_SSCJ -d $@
}
function putssac {
  dcurl -X PUT -H $CONTENT_SSAC -d $@
}
function postssac {
  dcurl -X POST -H $CONTENT_SSAC -d $@
}
function postssj {
  dcurl -H $CONTENT_SSJ -d $@
}
function putssj {
  dcurl -X PUT -H $CONTENT_SSJ -d $@
}
function postsskj {
  dcurl -H $CONTENT_SSKJ -d $@
}
function putsskj {
  dcurl -X PUT -H $CONTENT_SSKJ -d $@
}
function postssmj {
  dcurl -H $CONTENT_SSMJ -d $@
}
function putssmj {
  dcurl -X PUT -H $CONTENT_SSMJ -d $@
}
function getxml {
  curl $STD_ARG -H $ACCEPT_XML $@
}
function postform {
  dcurl -d $@
}
function getssj {
  curl $STD_ARG -H $ACCEPT_SSJ $@
}

function li_report_color {
# fuck yes check this shit out
 curl $NONVERBOSE_ARG -s -H "$ACCEPT_HEADER" "$@" | ruby -rubygems -e "require 'json';require 'time';JSON.parse(STDIN.read)['items'].sort {|a,b| a['clientname'] <=> b['clientname']}.each {|i| printf(\"%18.18s %-38.38s %s%5i %s\n\", \"$fg[green]#{i['clientname']}\",\"$fg[white]#{i['hostname']}\",\"$fg[red]\",(Time.now-Time.parse(i['last_message'])).to_i/60,\" minutes ago$fg[white]\")}"
}

function li_report {
# fuck yes check this shit out
 curl $NONVERBOSE_ARG -s -H "$ACCEPT_HEADER" "$@" | ruby -rubygems -e "require 'json';require 'time';JSON.parse(STDIN.read)['items'].sort {|a,b| a['clientname'] <=> b['clientname']}.each {|i| printf(\"%18.18s %-38.38s %s%5i %s\n\", \"#{i['clientname']}\",\"#{i['hostname']}\",\"\",(Time.now-Time.parse(i['last_message'])).to_i/60,\" minutes ago\")}"
}