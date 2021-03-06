# *********************************** Gary Bernhardt's pretty log ***********************************
show_git_head() {
    pretty_git_log -1
    git show -p --pretty="tformat:"
}

pretty_git_log() {
  HASH="%C(yellow)%h%Creset"
  RELATIVE_TIME="%Cgreen(%ar)%Creset"
  AUTHOR="%C(bold blue)<%an>%Creset"
  REFS="%C(red)%d%Creset"
  SUBJECT="%s"

  FORMAT="$HASH}$RELATIVE_TIME}$AUTHOR}$REFS $SUBJECT"

    git log --graph --pretty="tformat:${FORMAT}" $* |
        # Replace (2 years ago) with (2 years)
        sed -Ee 's/(^[^<]*) ago\)/\1)/' |
        # Replace (2 years, 5 months) with (2 years)
        sed -Ee 's/(^[^<]*), [[:digit:]]+ .*months?\)/\1)/' |
        # Line columns up based on } delimiter
        column -s '}' -t |
        # Page only if we need to
        less -FXRS
}
# / *********************************** Gary Bernhardt's pretty log ***********************************

# *********************************** git cherry-drop ***********************************
cherry_drop() {
  set -e
  REF_TO_DROP=`git show $1 --pretty=format:%H -q`
  HEAD=`git show HEAD --pretty=format:%H -q`
  shift

  # Stash changes if they exist
  if ! git diff-index --quiet HEAD --; then
    git stash && DIRTY=1
  fi

  if [[ $REF_TO_DROP == $HEAD ]]; then
    # Easy way to undo a commit:
    git reset --hard HEAD
  else
    # Rebase the commit out:
    git rebase --keep-empty --onto $REF_TO_DROP~1 $REF_TO_DROP
  fi

  # Unstash changes if they were stashed:
  [ -n "$DIRTY" ] && git stash pop

  # Great success:
  return 0
}
# *********************************** / git cherry-drop ***********************************


# *********************************** git goodmorning ***********************************
goodmorning_echo_red() {
  RED='\033[0;31m'
  NC='\033[0m' # No Color

  echo "${RED}--------- $1 ---------${NC}"
}

goodmorning_echo_yellow() {
  YELLOW='\033[0;33m'
  NC='\033[0m' # No Color

  echo "${YELLOW}--------- $1 ---------${NC}"
}

goodmorning_echo_green() {
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

  echo "${GREEN}--------- $1 ---------${NC}"
}

goodmorning_empty_lines() {
  for i in `seq 1 $1`;
  do
    echo ""
  done
}

semver() {
  printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ')
}
goodmorning_check_bundler() {
  GEMFILE_VER=$(cat Gemfile.lock | grep "BUNDLED WITH" -A1 | grep -v BUNDLED | awk '{print $1}')
  BUNDLER_VER=$(bundler --version | grep "Bundler version " | sed 's/[^0-9.]*//g')

  if [ $(semver $BUNDLER_VER) -lt $(semver $GEMFILE_VER) ]; then
    goodmorning_echo_yellow "Updating bundler from $BUNDLER_VER to $GEMFILE_VER... "
    gem install bundler -v $GEMFILE_VER
    goodmorning_empty_lines 2
  fi
}

goodmorning() {
  #set -e
  # clear

  CUR_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$CUR_BRANCH" = "master" ]]; then
    goodmorning_echo_green "Updating master..."
  else
    goodmorning_echo_green "Switching to master and updating..."
    git checkout master
  fi
  git pull --prune
  goodmorning_empty_lines 3

  if [ -f Gemfile ]; then
    goodmorning_check_bundler
    goodmorning_echo_green "Running bundle install..."
    # Use reverse grep to filter out dozens of unchanged lines,
    # such as "Using rake 10.5.0"
    bundle install | grep -v Using | grep -v "Fetching source index" | grep -v "Fetching gem metadata" || goodmorning_echo_yellow "Failed to bundle install!"
    goodmorning_empty_lines 3
  fi

  if [ -f package.json ]; then
    goodmorning_echo_green "Running yarn install..."
    # Safer:
    # yarn install --pure-lockfile --check-files && yarn postinstall
    # Faster:
    yarn install --pure-lockfile || goodmorning_echo_yellow "Failed to yarn install!"
    goodmorning_empty_lines 3
  fi

  # All done unless we're in a Rails project..
  if [ ! -f bin/rails ]; then
    goodmorning_echo_green "Finished!"
    return 0
  fi

  RAKE_CMD="rake"

  goodmorning_echo_green "Running $RAKE_CMD db:migrate..."
  `#{RAKE_CMD} db:migrate db:test:prepare` || goodmorning_echo_yellow "Failed to ready the database!"

  # Avoid noise generated from running migration on master:
  if [ -f db/structure.sql ]; then
    git checkout db/structure.sql
  fi
  if [ -f db/schema.rb ]; then
    git checkout db/schema.rb
  fi
  goodmorning_empty_lines 3

  mfaws

  goodmorning_echo_green " 💚💚💚💚💚💚 Finished! You're up to date 💚💚💚💚💚💚💚"
  return 0
}
# *********************************** / git goodmorning ***********************************

export UT_TEAM=tp
card_branch_name() {
    if [ ! -n "${UT_TEAM}" ]; then
        echo "\$UT_TEAM not set!" && return 1;
    fi

    project=$1
    url=$2

    if [[ $url = '' ]]; then
        url=$project
        project=''
    fi

    if [[ $project != '' ]]; then
        project="--${project}"
    fi

    cardid=`echo $url | cut -d/ -f5`;
    description=`echo $url | cut -d/ -f6 | sed -e 's/-$//g' | sed -E 's/^[[:digit:]-]+//g'`;
    echo "${UT_TEAM}${project}--${cardid}--${description}";
}

card_branch () {
    git checkout -b `card_branch_name $1 $2` master
}

open_branch () {
    git checkout `card_branch_name $1 $2`
}

