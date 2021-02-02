#!/bin/bash
# uqm-megamod build script mod for nintendo switch using devkitPro

# functions

# die <message>
die() {
  [[ ! "$1" ]] && return
  printf '%s\n' "$1" >&2
  exit 1
}

# set_arg <var> <value>
set_arg() {
  [[ ! "$1" ]] && return
  [[ ! "$2" ]] && die "error: \"$1\" requires a non-empty option argument."
  export $1="${2#*=}"
}

# replace_vars <file-in> <file-out> <match> <value> ...
replace_vars() {
  local SED_ARGS
  local FILE_IN="$1" && shift
  local FILE_OUT="$1" && shift
  while (("$#")); do
    local VAR_IN="$1" && shift
    local VAR_OUT="$1" && shift
    [ -z ${VAR_OUT+x} ] && break
    [ "$VAR_OUT" == "@" ] && VAR_OUT=''
    SED_ARGS="$SED_ARGS s/$VAR_IN/$VAR_OUT/;"
  done
  sed "$SED_ARGS" "$FILE_IN" > "$FILE_OUT"
}

get_vars() {
  . ./build.vars.switch
  DEBUG="$__DEBUG__"
  . ./Makeproject

  [ -z ${FILE+x} ] && FILE="$uqm_NAME"
  [ -z ${BINDIR+x} ] && BINDIR="$uqm_INSTALL_BINDIR"

  [ -z ${TITLE+x} ] && TITLE="$SWITCH_TITLE"
  [ -z ${AUTHOR+x} ] && AUTHOR="$SWITCH_AUTHOR"
  [ -z ${VERSION+x} ] && VERSION="$SWITCH_VERSION"
  [ -z ${TITLEID+x} ] && TITLEID="$SWITCH_TITLEID"
  [ -z ${ICON+x} ] && ICON="$SWITCH_ICON"
  [ -z ${ROMFS+x} ] && ROMFS="$SWITCH_ROMFS"
}

help() {
  echo "uqm-megamod build script mod for nintendo switch using devkitPro"
  echo "usage: $(basename $0) [options] <command> [command-options]"
  echo
  echo "options:"
  echo "  -h, --help           Show this help screen"
  echo "  -v, --verbose        Display verbose info"
  echo "  -b, --bindir=DIR     Binary output directory (default: $BINDIR)"
  echo "  -o, --output=FILE    Output filename (default: $FILE)"
  echo "  -t, --title=TEXT     Game title (default: $TITLE)"
  echo "  -a, --author=TEXT    Author name (default: $AUTHOR)"
  echo "  -V, --version=TEXT   Game version (default: $VERSION)"
  echo "  -T, --titleid=TEXT   Game TITLEID (default: $TITLEID)"
  echo "  -i, --icon=FILE      Icon file (default: $ICON)"
  echo "  -r, --romfs          Build with romfs"
  echo "  -d, --debug          Build with DEBUG flag"
  echo
  echo "commands:"
  echo "  info                 Display game info parameters"
  echo "  clean                Clean up the build files"
  echo "  build                Build the source code for switch,"
  echo "                       calls './build.sh uqm \$@'"
  echo "  nro                  Generate the NRO executable"
}

info() {
  if [[ -z ${__VERBOSE__+x} ]]; then
    echo -n "$BINDIR/$FILE: $TITLE, $AUTHOR, $VERSION [$TITLEID]"
    [ ! -z ${ROMFS+x} ] && [ "$ROMFS" != "" ] && echo " (romfs: $ROMFS)" || echo && [ ! -z ${__DEBUG__+x} ] && echo "(DEBUG)" || echo
  else
    echo "bin dir: $BINDIR"
    echo "output:  $FILE"
    echo "title:   $TITLE"
    echo "author:  $AUTHOR"
    echo "version: $VERSION"
    echo "titleid: $TITLEID"
    echo "icon:    $ICON"
    [ ! -z ${ROMFS+x} ] && [ "$ROMFS" != "" ] && echo "romfs:   $ROMFS" || echo "romfs:   disabled"
    [ ! -z ${__DEBUG__+x} ] && echo "debug:   on" || echo "debug:   off"
  fi
}

clean() {
  echo "cleaning up"
  ./build.sh uqm clean
  rm -rf link.map ./bin ./Bin ./obj ./Obj "$BINDIR"
  exit
}

build() {
  info

  if [[ -z "$DEVKITPRO" ]] && [[ ! -d "$DEVKITPRO" ]] || [[ ! -d "$DEVKITPRO/portlibs/switch" ]]; then
    die "error: devkitPro is not available. Make sure it is installed and \$DEVKITPRO is defined."
  fi
  
  [[ ! -f ./build.vars.switch ]] && die "error: ./build.vars.switch is missing, cannot proceed"
  [[ ! -f ./config_unix.h.switch ]] && die "error: ./build.vars.switch is missing, cannot proceed"

  echo "copying build files"
  [ ! -d "$BINDIR" ] && mkdir -p "$BINDIR"
  [ ! -f build.vars ] && echo | ./build.sh uqm config

  if ! cmp build.vars build.vars.switch >/dev/null 2>&1; then
    rm -f ./build.vars
    cp ./build.vars.switch ./build.vars
  fi

  if [ -z ${__DEBUG__+x} ]; then
    replace_vars build.vars.switch build.vars @DEBUG_DEF@ -DNDEBUG @DEBUG_FLAG@ "@"
  else
    replace_vars build.vars.switch build.vars @DEBUG_DEF@ -DDEBUG @DEBUG_FLAG@ "1"
  fi

  if ! cmp config_unix.h config_unix.h.switch >/dev/null 2>&1; then
    rm -f ./config_unix.h
    cp ./config_unix.h.switch ./config_unix.h
  fi

  echo "compiling ELF file \"$FILE\""
  ./build.sh uqm $@
  
  [[ ! -f "$FILE" ]] && die "error: can't find ELF file \"$FILE\""
  
  mv "$FILE" "$BINDIR/$FILE"
  
  nro
}

nro() {
  [[ ! -f "$BINDIR/$FILE" ]] && die "error: can't find ELF file, make sure to build first"
  
  echo "generating $FILE.nacp"
  ${DEVKITPRO}/tools/bin/nacptool --create "$TITLE" "$AUTHOR" "$VERSION" "$BINDIR/$FILE.nacp" --titleid="$TITLEID"
  
  if [[ ! -z ${ROMFS+x} ]] && [[ "$ROMFS" != "" ]]; then
    [[ ! -d ./romfs ]] && die "error: specified romfs directory '$ROMFS' does not exist"
    echo "generating $FILE.romfs"
    ROMFS_ARG="--romfs=$BINDIR/$FILE.romfs"
    ${DEVKITPRO}/tools/bin/build_romfs "$ROMFS" "$ROMFS_ARG"
  fi
  
  echo "generating $FILE.nso"
  ${DEVKITPRO}/tools/bin/elf2nso "$BINDIR/$FILE" "$BINDIR/$FILE.nso"
  
  echo "generating $FILE.nro"
  ${DEVKITPRO}/tools/bin/elf2nro "$BINDIR/$FILE" "$BINDIR/$FILE.nro" --icon="$ICON" --nacp="$BINDIR/$FILE.nacp" "$ROMFS_ARG"
  
  echo "done!"
  
  exit
}

# arguments

if [ $# -eq 0 ]; then
  help
  exit
fi

while :; do
  case $1 in
    -h|-\?|--help) help; exit;;
    -b|--bindir) set_arg BINDIR "$2" && shift;;
    --bindir=?*) set_arg BINDIR "$1";;
    -o|--output) set_arg FILE "$2" && shift;;
    --output=?*) set_arg FILE "$1";;
    -t|--title) set_arg TITLE "$2" && shift;;
    --title=?*) set_arg TITLE "$1";;
    -a|--author) set_arg AUTHOR "$2" && shift;;
    --author=?*) set_arg AUTHOR "$1";;
    -V|--version) set_arg VERSION "$2" && shift;;
    --version=?*) set_arg VERSION "$1";;
    -T|--titleid) set_arg TITLEID "$2" && shift;;
    --titleid=?*) set_arg TITLEID "$1";;
    -i|--icon) set_arg ICON "$2" && shift;;
    --icon=?*) set_arg ICON "$1";;
    -r|--romfs) set_arg ROMFS "$2" && shift;;
    --romfs=?*) set_arg ROMFS "$1";;
    -v|--verbose) __VERBOSE__="1";;
    -d|--debug) __DEBUG__="1";;
    --) shift; break;;
    -?*) die "error: unknown option: $1";;
    *) break;;
  esac
  shift
done

get_vars

# commands

while :; do
  case $1 in
    info) info; exit;;
    clean) clean; exit;;
    build) shift && build $@; exit;;
    nro) nro; exit;;
    ?*) die "error: unknown command: $1"; exit;;
    *) break
  esac
  shift
done

# unhandled

help
exit
