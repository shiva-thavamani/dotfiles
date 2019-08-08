alias reload!='. ~/.zshrc'


BASE="$HOME"
SOURCE="$BASE/source"

alias unpushed='git log --branches --not --remotes'
alias unpushed_summary='git log --branches --not --remotes --simplify-by-decoration --decorate --oneline'

alias less='less -R'
alias top='top -s1 -o cpu -R -F'
alias gf='git-flow'

alias rakedb='be rake db:drop; be rake db:create; be rake db:migrate; be rake db:seed'
alias be='bundle exec'

alias gs='gulp spec'
alias gsc='gulp spec_w_coverage'

alias speedtest='curl -o /dev/null http://speedtest.wdc01.softlayer.com/downloads/test1000.zip'

alias python2='/usr/local/bin/python'
alias pip2='/usr/local/bin/pip'
alias python='/usr/local/bin/python3'
alias pip='/usr/local/bin/pip3'


alias git-morning='goodmorning'
