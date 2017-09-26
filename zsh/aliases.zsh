alias reload!='. ~/.zshrc'


BASE="$HOME/Documents"
SOURCE="$BASE/Source"
hash -d gitrepos="$BASE/Source/git"
hash -d ewn="/Users/chris/Source/EWN/newspresso/"
hash -d dbc="/Users/chris/Source/DBC/"
hash -d cic="/Users/chris/Source/DBC/Cohorts/2015/NYC/cicadas/"
hash -d in="/Users/chris/Inbox/"

alias unpushed='git log --branches --not --remotes'
alias unpushed_summary='git log --branches --not --remotes --simplify-by-decoration --decorate --oneline'

alias less='less -R'
alias top='top -s1 -o cpu -R -F'
alias gf='git-flow'

alias rakedb='be rake db:drop; be rake db:create; be rake db:migrate; be rake db:seed'
alias be='bundle exec'

alias gs='gulp spec'
alias gsc='gulp spec_w_coverage'
