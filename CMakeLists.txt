cmake_minimum_required(VERSION 3.17)
set(CMAKE_CXX_STANDARD 14)
project(UrQuanMasters)

# Macros



# Includes

include(TestBigEndian)
include(CheckIncludeFiles)
include(CheckFunctionExists)

# Options

if (UNIX)
    set(CONTENTDIR ~/.local/share/${PROJECT_NAME}/content)
    set(USERDIR ~/.local/share/${PROJECT_NAME})
elseif(WIN32)
    set(CONTENTDIR ./content)
    set(USERDIR .)
endif()

###

# Debug

option(OPTION_DEBUG "Debugging build" ON)
cmake_dependent_option(OPTION_STRICT "Strict compile checks" OFF "OPTION_DEBUG" OFF)

if(OPTION_DEBUG)
    add_definitions(-DDEBUG)
    add_compile_options(-g -O0 -W -Wall -DDEBUG)
    link_libraries("-O0")
    if(OPTION_STRICT)
        add_compile_options(
            -O1 -pedantic-errors -ansi -trigraphs
            -Wcast-qual -Wmissing-declarations
            -Wwrite-strings -Wimplicit -Wreturn-type -Wformat
            -Wswitch -Wcomment -Wchar-subscripts
            -Wparentheses -Wcast-align -Wuninitialized
            -Wbad-function-cast -Wmissing-prototypes
            -Wstrict-prototypes -Wdeclaration-after-statement
            -Waggregate-return -Wpointer-arith
            -Wshadow -Werror
            -Wnested-externs -Winline
        )
    endif()
else()
    add_compile_options(-O3)
    add_definitions(-DNDEBUG)
endif()

# Graphics engine

option(OPTION_USE_SDL2 "Use SDL2 for graphics" ON)
cmake_dependent_option(OPTION_HAVE_OPENGL "Strict compile checks" OFF "NOT OPTION_USE_SDL2" OFF)

if(OPTION_USE_SDL2)
    add_definitions(-DGFXMODULE_SDL -DSDL_DIR=SDL2)
    ###use_library SDL2
    #set(graphics sdl2)
else()
    add_definitions(-DGFXMODULE_SDL)
    #set(GFXMODULE sdl)
    ###use_library SDL 1.2.8
    if(OPTION_HAVE_OPENGL)
        add_definitions(-DHAVE_OPENGL)
        #set(HAVE_OPENGL 1)
        ###use_library opengl
        #set(graphics opengl)
    else()
        add_definitions(-DGFXMODULE_SDL -DSDL_DIR=SDL)
        #set(HAVE_OPENGL 0)
        #set(graphics pure)
    endif()
endif()

# Sound backend

option(OPTION_USE_MIXSDL "Use MixSDL or OpenAL for sound" ON)

if(OPTION_USE_MIXSDL)
    #set(SOUNDMODULE mixsdl)
else()
    add_definitions(-DHAVE_OPENAL)
    #set(SOUNDMODULE openal)
    ###use_library openal
endif()

# Tracker music support

option(OPTION_USE_INCLUDED_MIKMOD "Use included or system libmikmod" ON)

if(OPTION_USE_INCLUDED_MIKMOD)
    add_definitions(-DUSE_INTERNAL_MIKMOD)
    #set(USE_INTERNAL_MIKMOD 1)
else()
    #unset(USE_INTERNAL_MIKMOD)
    ###use_library libmikmod
endif()

# Lua scripting

option(OPTION_USE_INCLUDED_LUA "Use included or system Lua library" ON)

if(OPTION_USE_INCLUDED_LUA)
    add_definitions(-DUSE_INTERNAL_LUA)
    #set(USE_INTERNAL_LUA 1)
else()
    #unset(USE_INTERNAL_LUA)
    ###use_library lua 5.2.0
endif()

# Ogg Vorbis codec

option(OPTION_USE_VORBIS "Use libogg + libvorbis for Ogg support" ON)
cmake_dependent_option(OPTION_USE_TREMOR "Use Tremor for Ogg support (avoids floating point math)" OFF "NOT OPTION_USE_VORBIS" ON)

if(OPTION_USE_VORBIS)
    #set(OGGVORBIS vorbisfile)
    ###use_library vorbisfile
else()
    if(OPTION_USE_TREMOR)
        add_definitions(-DOVCODEC_TREMOR)
        #set(OGGVORBIS tremor)
        ###use_library tremor
    else()
        add_definitions(-DOVCODEC_NONE)
        #set(OGGVORBIS none)
    endif()
endif()

# Network Supermelee support

option(OPTION_HAVE_NETWORK "Network Supermelee support" ON)
cmake_dependent_option(OPTION_IPV6 "Use IPv6" ON "OPTION_HAVE_NETWORK" OFF)

if(OPTION_HAVE_NETWORK)
    if(OPTION_IPV6)
        add_definitions(-DNETPLAY=NETPLAY_FULL)
        #set(NETPLAY FULL)
        ###use_library netlibs
    else()
        add_definitions(-DNETPLAY=NETPLAY_IPV4)
        #set(NETPLAY IPV4)
        ###use_library netlibs
    endif()
else()
    #unset(NETPLAY)
endif()

# Joystick support

option(OPTION_USE_JOYSTICK "Joystick support" ON)

if(OPTION_USE_JOYSTICK)
    add_definitions(-DHAVE_JOYSTICK)
    #set(joystick enabled)
else()
    #set(joystick disabled)
endif()

# Support zip i/o

option(OPTION_USE_ZIP "Support zip i/o" ON)

if(OPTION_USE_ZIP)
    add_definitions(-DHAVE_ZIP=1)
    #set(USE_ZIP_IO 1)
    ###use_library zlib
endif()

# Use platform acceleration (asm, etc.)

option(OPTION_USE_PLATFORM_ACCELERATION "Use platform acceleration (asm, etc.)" ON)

if(OPTION_USE_PLATFORM_ACCELERATION)
    add_definitions(-DUSE_PLATFORM_ACCEL)
    #set(USE_PLATFORM_ACCEL 1)
else()
    #set(USE_PLATFORM_ACCEL 0)
endif()

# Thread library

option(OPTION_USE_SDL_THREAD "Use SDL thead library instead of pthread" ON)

if(OPTION_USE_SDL_THREAD)
    add_definitions(-DTHREADLIB_SDL)
    #set(THREADLIB SDL)
else()
    add_definitions(-DTHREADLIB_PTHREAD)
    #set(THREADLIB PTHREAD)
    ###use_library pthread
endif()

###

#option(SOUNDMODULE "" 'mixsdl')
#option(OGGVORBIS "" 'vorbisfile')
#option(USE_INTERNAL_MIKMOD "" '1')
#option(USE_INTERNAL_LUA "" '1')
#option(HAVE_GETOPT_LONG "" '\#define HAVE_GETOPT_LONG')
#option(HAVE_REGEX "" '1')
#option(GFXMODULE "" 'sdl')
#option(HAVE_OPENGL "" '0')
#option(USE_ZIP_IO "" '1')
#option(USE_PLATFORM_ACCEL "" '1')
#option(THREADLIB "" 'SDL')
#option(NETPLAY "" 'FULL')
#option(USE_WINSOCK "" '')

# Configure file

test_big_endian(WORDS_BIGENDIAN)
check_include_files(dirent.h HAVE_READDIR_R)
check_include_files(stdlib.h HAVE_SETENV)
check_include_files(string.h HAVE_STRUPR)
check_include_files(strings.h HAVE_STRCASECMP_UQM)
check_include_files(string.h HAVE_STRICMP)
check_include_files(getopt.h HAVE_GETOPT_LONG)
check_include_files(wctype.h HAVE_ISWGRAPH)
check_include_files(stddef.h HAVE_WCHAR_T)
check_include_files(wchar.h HAVE_WINT_T)
check_include_files(stdbool.h HAVE__BOOL)
check_include_files(sys/types.h REGEX)

configure_file(config_unix.h.in config_unix.h)
target_include_directories(${PROJECT_NAME} PUBLIC "${PROJECT_BINARY_DIR}")

# Targets

add_custom_target(debug
    COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Debug ${CMAKE_SOURCE_DIR}
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target all
    COMMENT "Switch CMAKE_BUILD_TYPE to Debug"
)

add_custom_target(release
    COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release ${CMAKE_SOURCE_DIR}
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target all
    COMMENT "Switch CMAKE_BUILD_TYPE to Release"
)

add_custom_target(run COMMAND mycode
    COMMENT "Run with ${CMAKE_BUILD_TYPE} configuration"
)

# Compiler parameters

add_definitions(
    -DGFXMODULE_SDL
    -DSDL_DIR=SDL2
    -D_REENTRANT
    -DDEBUG
    -DUSE_INTERNAL_MIKMOD
    -DUSE_INTERNAL_LUA
    -DNETPLAY=NETPLAY_FULL
    -DHAVE_JOYSTICK
    -DHAVE_ZIP=1
    -DUSE_PLATFORM_ACCEL
    -DTHREADLIB_SDL
)

add_compile_options(
    -g
    -O0
    -W
    -Wall
    -fno-rtti
    -fno-exceptions
    -nostdinc++
)

# Source code and directories

if(not REGEX or REGEX equal 0)
    include_directories(src/regex)
endif()

include_directories(
    /usr/include/SDL2
    .
    src
    src/abxadec
    src/darwin
    src/getopt
    src/libs
    src/libs/callback
    src/libs/cdp
    src/libs/decomp
    src/libs/file
    src/libs/graphics
    src/libs/graphics/sdl
    src/libs/heap
    src/libs/input
    src/libs/input/sdl
    src/libs/list
    src/libs/log
    src/libs/lua
    src/libs/luauqm
    src/libs/math
    src/libs/md5
    src/libs/mikmod
    src/libs/network
    src/libs/network/connect
    src/libs/network/netmanager
    src/libs/network/socket
    src/libs/resource
    src/libs/sound
    src/libs/sound/decoders
    src/libs/sound/mixer
    src/libs/sound/mixer/nosound
    src/libs/sound/mixer/sdl
    src/libs/sound/openal
    src/libs/strings
    src/libs/threads
    src/libs/threads/pthread
    src/libs/threads/sdl
    src/libs/time
    src/libs/time/sdl
    src/libs/uio
    src/libs/uio/stdio
    src/libs/uio/zip
    src/libs/video
    src/symbian
    src/uqm
    src/uqm/comm
    src/uqm/comm/arilou
    src/uqm/comm/blackur
    src/uqm/comm/chmmr
    src/uqm/comm/comandr
    src/uqm/comm/druuge
    src/uqm/comm/ilwrath
    src/uqm/comm/melnorm
    src/uqm/comm/mycon
    src/uqm/comm/orz
    src/uqm/comm/pkunk
    src/uqm/comm/rebel
    src/uqm/comm/shofixt
    src/uqm/comm/slyhome
    src/uqm/comm/slyland
    src/uqm/comm/spahome
    src/uqm/comm/spathi
    src/uqm/comm/starbas
    src/uqm/comm/supox
    src/uqm/comm/syreen
    src/uqm/comm/talkpet
    src/uqm/comm/thradd
    src/uqm/comm/umgah
    src/uqm/comm/urquan
    src/uqm/comm/utwig
    src/uqm/comm/vux
    src/uqm/comm/yehat
    src/uqm/comm/zoqfot
    src/uqm/lua
    src/uqm/lua/luafuncs
    src/uqm/planets
    src/uqm/planets/generate
    src/uqm/ships
    src/uqm/ships/androsyn
    src/uqm/ships/arilou
    src/uqm/ships/blackurq
    src/uqm/ships/chenjesu
    src/uqm/ships/chmmr
    src/uqm/ships/druuge
    src/uqm/ships/human
    src/uqm/ships/ilwrath
    src/uqm/ships/lastbat
    src/uqm/ships/melnorme
    src/uqm/ships/mmrnmhrm
    src/uqm/ships/mycon
    src/uqm/ships/orz
    src/uqm/ships/pkunk
    src/uqm/ships/probe
    src/uqm/ships/shofixti
    src/uqm/ships/sis_ship
    src/uqm/ships/slylandr
    src/uqm/ships/spathi
    src/uqm/ships/supox
    src/uqm/ships/syreen
    src/uqm/ships/thradd
    src/uqm/ships/umgah
    src/uqm/ships/urquan
    src/uqm/ships/utwig
    src/uqm/ships/vux
    src/uqm/ships/yehat
    src/uqm/ships/zoqfot
    src/uqm/supermelee
    src/uqm/supermelee/netplay
    src/uqm/supermelee/netplay/proto
)

add_executable(${PROJECT_NAME}
    src/abxadec/abxaud.c
    src/abxadec/abxaud.h
    src/darwin/SDLMain.h
    src/darwin/SDLMain.m
    src/getopt/getopt.c
    src/getopt/getopt.h
    src/getopt/getopt1.c
    src/libs/callback/alarm.c
    src/libs/callback/alarm.h
    src/libs/callback/async.c
    src/libs/callback/async.h
    src/libs/callback/callback.c
    src/libs/callback/callback.h
    src/libs/cdp/cdp.c
    src/libs/cdp/cdp.h
    src/libs/cdp/cdp_alli.h
    src/libs/cdp/cdp_iio.h
    src/libs/cdp/cdp_imem.h
    src/libs/cdp/cdp_isnd.h
    src/libs/cdp/cdp_ivid.h
    src/libs/cdp/cdpapi.c
    src/libs/cdp/cdpapi.h
    src/libs/cdp/cdpint.h
    src/libs/cdp/cdpmod.h
    src/libs/cdp/windl.c
    src/libs/cdp/windl.h
    src/libs/decomp/lzdecode.c
    src/libs/decomp/lzencode.c
    src/libs/decomp/lzh.h
    src/libs/decomp/update.c
    src/libs/file/dirs.c
    src/libs/file/files.c
    src/libs/file/filintrn.h
    src/libs/file/temp.c
    src/libs/graphics/sdl/2xscalers.c
    src/libs/graphics/sdl/2xscalers.h
    src/libs/graphics/sdl/2xscalers_3dnow.c
    src/libs/graphics/sdl/2xscalers_mmx.c
    src/libs/graphics/sdl/2xscalers_mmx.h
    src/libs/graphics/sdl/2xscalers_sse.c
    src/libs/graphics/sdl/biadv2x.c
    src/libs/graphics/sdl/bilinear2x.c
    src/libs/graphics/sdl/canvas.c
    src/libs/graphics/sdl/hq2x.c
    src/libs/graphics/sdl/nearest2x.c
    src/libs/graphics/sdl/opengl.c
    src/libs/graphics/sdl/opengl.h
    src/libs/graphics/sdl/palette.c
    src/libs/graphics/sdl/palette.h
    src/libs/graphics/sdl/png2sdl.c
    src/libs/graphics/sdl/png2sdl.h
    src/libs/graphics/sdl/primitives.c
    src/libs/graphics/sdl/primitives.h
    src/libs/graphics/sdl/pure.c
    src/libs/graphics/sdl/pure.h
    src/libs/graphics/sdl/rotozoom.c
    src/libs/graphics/sdl/rotozoom.h
    src/libs/graphics/sdl/scaleint.h
    src/libs/graphics/sdl/scalemmx.h
    src/libs/graphics/sdl/scalers.c
    src/libs/graphics/sdl/scalers.h
    src/libs/graphics/sdl/sdl1_common.c
    src/libs/graphics/sdl/sdl2_common.c
    src/libs/graphics/sdl/sdl2_pure.c
    src/libs/graphics/sdl/sdl_common.c
    src/libs/graphics/sdl/sdl_common.h
    src/libs/graphics/sdl/sdluio.c
    src/libs/graphics/sdl/sdluio.h
    src/libs/graphics/sdl/triscan2x.c
    src/libs/graphics/bbox.c
    src/libs/graphics/bbox.h
    src/libs/graphics/boxint.c
    src/libs/graphics/clipline.c
    src/libs/graphics/cmap.c
    src/libs/graphics/cmap.h
    src/libs/graphics/context.c
    src/libs/graphics/context.h
    src/libs/graphics/dcqueue.c
    src/libs/graphics/dcqueue.h
    src/libs/graphics/drawable.c
    src/libs/graphics/drawable.h
    src/libs/graphics/drawcmd.h
    src/libs/graphics/filegfx.c
    src/libs/graphics/font.c
    src/libs/graphics/font.h
    src/libs/graphics/frame.c
    src/libs/graphics/gfx_common.c
    src/libs/graphics/gfx_common.h
    src/libs/graphics/gfxintrn.h
    src/libs/graphics/gfxload.c
    src/libs/graphics/intersec.c
    src/libs/graphics/loaddisp.c
    src/libs/graphics/pixmap.c
    src/libs/graphics/prim.h
    src/libs/graphics/resgfx.c
    src/libs/graphics/tfb_draw.c
    src/libs/graphics/tfb_draw.h
    src/libs/graphics/tfb_prim.c
    src/libs/graphics/tfb_prim.h
    src/libs/graphics/widgets.c
    src/libs/graphics/widgets.h
    src/libs/heap/heap.c
    src/libs/heap/heap.h
    src/libs/input/sdl/input.c
    src/libs/input/sdl/input.h
    src/libs/input/sdl/keynames.c
    src/libs/input/sdl/keynames.h
    src/libs/input/sdl/vcontrol.c
    src/libs/input/sdl/vcontrol.h
    src/libs/input/inpintrn.h
    src/libs/input/input_common.c
    src/libs/input/input_common.h
    src/libs/list/list.c
    src/libs/list/list.h
    src/libs/log/loginternal.h
    src/libs/log/msgbox.h
    src/libs/log/msgbox_macosx.m
    src/libs/log/msgbox_stub.c
    src/libs/log/msgbox_win.c
    src/libs/log/uqmlog.c
    src/libs/log/uqmlog.h
    src/libs/lua/lapi.c
    src/libs/lua/lapi.h
    src/libs/lua/lauxlib.c
    src/libs/lua/lauxlib.h
    src/libs/lua/lbaselib.c
    src/libs/lua/lbitlib.c
    src/libs/lua/lcode.c
    src/libs/lua/lcode.h
    src/libs/lua/lcorolib.c
    src/libs/lua/lctype.c
    src/libs/lua/lctype.h
    src/libs/lua/ldblib.c
    src/libs/lua/ldebug.c
    src/libs/lua/ldebug.h
    src/libs/lua/ldo.c
    src/libs/lua/ldo.h
    src/libs/lua/ldump.c
    src/libs/lua/lfunc.c
    src/libs/lua/lfunc.h
    src/libs/lua/lgc.c
    src/libs/lua/lgc.h
    src/libs/lua/linit.c
    src/libs/lua/liolib.c
    src/libs/lua/llex.c
    src/libs/lua/llex.h
    src/libs/lua/llimits.h
    src/libs/lua/lmathlib.c
    src/libs/lua/lmem.c
    src/libs/lua/lmem.h
    src/libs/lua/loadlib.c
    src/libs/lua/lobject.c
    src/libs/lua/lobject.h
    src/libs/lua/lopcodes.c
    src/libs/lua/lopcodes.h
    src/libs/lua/loslib.c
    src/libs/lua/lparser.c
    src/libs/lua/lparser.h
    src/libs/lua/lstate.c
    src/libs/lua/lstate.h
    src/libs/lua/lstring.c
    src/libs/lua/lstring.h
    src/libs/lua/lstrlib.c
    src/libs/lua/ltable.c
    src/libs/lua/ltable.h
    src/libs/lua/ltablib.c
    src/libs/lua/ltm.c
    src/libs/lua/ltm.h
    src/libs/lua/lua.c
    src/libs/lua/lua.h
    src/libs/lua/lua.hpp
    src/libs/lua/luac.c
    src/libs/lua/luaconf.h
    src/libs/lua/lualib.h
    src/libs/lua/lundump.c
    src/libs/lua/lundump.h
    src/libs/lua/lvm.c
    src/libs/lua/lvm.h
    src/libs/lua/lzio.c
    src/libs/lua/lzio.h
    src/libs/luauqm/luauqm.c
    src/libs/luauqm/luauqm.h
    src/libs/luauqm/scriptres.c
    src/libs/luauqm/scriptres.h
    src/libs/math/mthintrn.h
    src/libs/math/random.c
    src/libs/math/random.h
    src/libs/math/random2.c
    src/libs/math/sqrt.c
    src/libs/md5/md5.c
    src/libs/md5/md5.h
    src/libs/memory/w_memlib.c
    src/libs/mikmod/drv_nos.c
    src/libs/mikmod/load_it.c
    src/libs/mikmod/load_mod.c
    src/libs/mikmod/load_s3m.c
    src/libs/mikmod/load_stm.c
    src/libs/mikmod/load_xm.c
    src/libs/mikmod/mdreg.c
    src/libs/mikmod/mdriver.c
    src/libs/mikmod/mikmod.h
    src/libs/mikmod/mikmod_build.h
    src/libs/mikmod/mikmod_internals.h
    src/libs/mikmod/mloader.c
    src/libs/mikmod/mlreg.c
    src/libs/mikmod/mlutil.c
    src/libs/mikmod/mmalloc.c
    src/libs/mikmod/mmerror.c
    src/libs/mikmod/mmio.c
    src/libs/mikmod/mplayer.c
    src/libs/mikmod/munitrk.c
    src/libs/mikmod/mwav.c
    src/libs/mikmod/npertab.c
    src/libs/mikmod/sloader.c
    src/libs/mikmod/virtch.c
    src/libs/mikmod/virtch2.c
    src/libs/mikmod/virtch_common.c
    src/libs/network/connect/connect.c
    src/libs/network/connect/connect.h
    src/libs/network/connect/listen.c
    src/libs/network/connect/listen.h
    src/libs/network/connect/resolve.c
    src/libs/network/connect/resolve.h
    src/libs/network/netmanager/ndesc.c
    src/libs/network/netmanager/ndesc.h
    src/libs/network/netmanager/netmanager.h
    src/libs/network/netmanager/netmanager_bsd.c
    src/libs/network/netmanager/netmanager_bsd.h
    src/libs/network/netmanager/netmanager_win.c
    src/libs/network/netmanager/netmanager_win.h
    src/libs/network/socket/socket.c
    src/libs/network/socket/socket.h
    src/libs/network/socket/socket_bsd.c
    src/libs/network/socket/socket_bsd.h
    src/libs/network/socket/socket_win.c
    src/libs/network/socket/socket_win.h
    src/libs/network/bytesex.h
    src/libs/network/netport.c
    src/libs/network/netport.h
    src/libs/network/network.h
    src/libs/network/network_bsd.c
    src/libs/network/network_win.c
    src/libs/network/wspiapiwrap.c
    src/libs/network/wspiapiwrap.h
    src/libs/resource/direct.c
    src/libs/resource/filecntl.c
    src/libs/resource/getres.c
    src/libs/resource/index.h
    src/libs/resource/loadres.c
    src/libs/resource/propfile.c
    src/libs/resource/propfile.h
    src/libs/resource/resinit.c
    src/libs/resource/resintrn.h
    src/libs/resource/stringbank.c
    src/libs/resource/stringbank.h
    src/libs/sound/decoders/aiffaud.c
    src/libs/sound/decoders/aiffaud.h
    src/libs/sound/decoders/decoder.c
    src/libs/sound/decoders/decoder.h
    src/libs/sound/decoders/dukaud.c
    src/libs/sound/decoders/dukaud.h
    src/libs/sound/decoders/modaud.c
    src/libs/sound/decoders/modaud.h
    src/libs/sound/decoders/oggaud.c
    src/libs/sound/decoders/oggaud.h
    src/libs/sound/decoders/wav.c
    src/libs/sound/decoders/wav.h
    src/libs/sound/mixer/nosound/audiodrv_nosound.c
    src/libs/sound/mixer/nosound/audiodrv_nosound.h
    src/libs/sound/mixer/sdl/audiodrv_sdl.c
    src/libs/sound/mixer/sdl/audiodrv_sdl.h
    src/libs/sound/mixer/mixer.c
    src/libs/sound/mixer/mixer.h
    src/libs/sound/mixer/mixerint.h
    src/libs/sound/openal/audiodrv_openal.c
    src/libs/sound/openal/audiodrv_openal.h
    src/libs/sound/audiocore.c
    src/libs/sound/audiocore.h
    src/libs/sound/fileinst.c
    src/libs/sound/music.c
    src/libs/sound/resinst.c
    src/libs/sound/sfx.c
    src/libs/sound/sndintrn.h
    src/libs/sound/sound.c
    src/libs/sound/sound.h
    src/libs/sound/stream.c
    src/libs/sound/stream.h
    src/libs/sound/trackint.h
    src/libs/sound/trackplayer.c
    src/libs/sound/trackplayer.h
    src/libs/strings/getstr.c
    src/libs/strings/sfileins.c
    src/libs/strings/sresins.c
    src/libs/strings/stringhashtable.c
    src/libs/strings/stringhashtable.h
    src/libs/strings/strings.c
    src/libs/strings/strintrn.h
    src/libs/strings/unicode.c
    src/libs/task/tasklib.c
    src/libs/threads/pthread/posixthreads.c
    src/libs/threads/pthread/posixthreads.h
    src/libs/threads/sdl/sdlthreads.c
    src/libs/threads/sdl/sdlthreads.h
    src/libs/threads/thrcommon.c
    src/libs/threads/thrcommon.h
    src/libs/time/sdl/sdltime.c
    src/libs/time/sdl/sdltime.h
    src/libs/time/timecommon.c
    src/libs/time/timecommon.h
    src/libs/uio/stdio/stdio.c
    src/libs/uio/stdio/stdio.h
    src/libs/uio/zip/zip.c
    src/libs/uio/zip/zip.h
    src/libs/uio/charhashtable.c
    src/libs/uio/charhashtable.h
    src/libs/uio/debug.c
    src/libs/uio/debug.h
    src/libs/uio/defaultfs.c
    src/libs/uio/defaultfs.h
    src/libs/uio/fileblock.c
    src/libs/uio/fileblock.h
    src/libs/uio/fstypes.c
    src/libs/uio/fstypes.h
    src/libs/uio/getint.h
    src/libs/uio/gphys.c
    src/libs/uio/gphys.h
    src/libs/uio/hashtable.c
    src/libs/uio/hashtable.h
    src/libs/uio/io.c
    src/libs/uio/io.h
    src/libs/uio/ioaux.c
    src/libs/uio/ioaux.h
    src/libs/uio/iointrn.h
    src/libs/uio/match.c
    src/libs/uio/match.h
    src/libs/uio/mem.h
    src/libs/uio/memdebug.c
    src/libs/uio/memdebug.h
    src/libs/uio/mount.c
    src/libs/uio/mount.h
    src/libs/uio/mounttree.c
    src/libs/uio/mounttree.h
    src/libs/uio/paths.c
    src/libs/uio/paths.h
    src/libs/uio/physical.c
    src/libs/uio/physical.h
    src/libs/uio/types.h
    src/libs/uio/uioport.h
    src/libs/uio/uiostream.c
    src/libs/uio/uiostream.h
    src/libs/uio/uioutils.c
    src/libs/uio/uioutils.h
    src/libs/uio/utils.c
    src/libs/uio/utils.h
    src/libs/video/dukvid.c
    src/libs/video/dukvid.h
    src/libs/video/legacyplayer.c
    src/libs/video/vfileins.c
    src/libs/video/video.c
    src/libs/video/video.h
    src/libs/video/videodec.c
    src/libs/video/videodec.h
    src/libs/video/vidintrn.h
    src/libs/video/vidplayer.c
    src/libs/video/vidplayer.h
    src/libs/video/vresins.c
    src/libs/alarm.h
    src/libs/async.h
    src/libs/callback.h
    src/libs/cdplib.h
    src/libs/compiler.h
    src/libs/declib.h
    src/libs/file.h
    src/libs/gfxlib.h
    src/libs/heap.h
    src/libs/inplib.h
    src/libs/list.h
    src/libs/log.h
    src/libs/mathlib.h
    src/libs/md5.h
    src/libs/memlib.h
    src/libs/misc.h
    src/libs/net.h
    src/libs/platform.h
    src/libs/reslib.h
    src/libs/scriptlib.h
    src/libs/sndlib.h
    src/libs/strlib.h
    src/libs/tasklib.h
    src/libs/threadlib.h
    src/libs/timelib.h
    src/libs/uio.h
    src/libs/uioutils.h
    src/libs/unicode.h
    src/libs/vidlib.h
    src/regex/regex.c
    src/regex/regex.h
    src/regex/regex_internal.h
    src/symbian/config.h
    src/symbian/uqmapp.cpp
    src/uqm/comm/arilou/arilouc.c
    src/uqm/comm/arilou/resinst.h
    src/uqm/comm/arilou/strings.h
    src/uqm/comm/blackur/blackurc.c
    src/uqm/comm/blackur/resinst.h
    src/uqm/comm/blackur/strings.h
    src/uqm/comm/chmmr/chmmrc.c
    src/uqm/comm/chmmr/resinst.h
    src/uqm/comm/chmmr/strings.h
    src/uqm/comm/comandr/comandr.c
    src/uqm/comm/comandr/resinst.h
    src/uqm/comm/comandr/strings.h
    src/uqm/comm/druuge/druugec.c
    src/uqm/comm/druuge/resinst.h
    src/uqm/comm/druuge/strings.h
    src/uqm/comm/ilwrath/ilwrathc.c
    src/uqm/comm/ilwrath/resinst.h
    src/uqm/comm/ilwrath/strings.h
    src/uqm/comm/melnorm/melnorm.c
    src/uqm/comm/melnorm/resinst.h
    src/uqm/comm/melnorm/strings.h
    src/uqm/comm/mycon/myconc.c
    src/uqm/comm/mycon/resinst.h
    src/uqm/comm/mycon/strings.h
    src/uqm/comm/orz/orzc.c
    src/uqm/comm/orz/resinst.h
    src/uqm/comm/orz/strings.h
    src/uqm/comm/pkunk/pkunkc.c
    src/uqm/comm/pkunk/resinst.h
    src/uqm/comm/pkunk/strings.h
    src/uqm/comm/rebel/rebel.c
    src/uqm/comm/rebel/strings.h
    src/uqm/comm/shofixt/resinst.h
    src/uqm/comm/shofixt/shofixt.c
    src/uqm/comm/shofixt/strings.h
    src/uqm/comm/slyhome/resinst.h
    src/uqm/comm/slyhome/slyhome.c
    src/uqm/comm/slyhome/strings.h
    src/uqm/comm/slyland/resinst.h
    src/uqm/comm/slyland/slyland.c
    src/uqm/comm/slyland/strings.h
    src/uqm/comm/spahome/spahome.c
    src/uqm/comm/spahome/strings.h
    src/uqm/comm/spathi/resinst.h
    src/uqm/comm/spathi/spathic.c
    src/uqm/comm/spathi/strings.h
    src/uqm/comm/starbas/starbas.c
    src/uqm/comm/starbas/strings.h
    src/uqm/comm/supox/resinst.h
    src/uqm/comm/supox/strings.h
    src/uqm/comm/supox/supoxc.c
    src/uqm/comm/syreen/resinst.h
    src/uqm/comm/syreen/strings.h
    src/uqm/comm/syreen/syreenc.c
    src/uqm/comm/talkpet/resinst.h
    src/uqm/comm/talkpet/strings.h
    src/uqm/comm/talkpet/talkpet.c
    src/uqm/comm/thradd/resinst.h
    src/uqm/comm/thradd/strings.h
    src/uqm/comm/thradd/thraddc.c
    src/uqm/comm/umgah/resinst.h
    src/uqm/comm/umgah/strings.h
    src/uqm/comm/umgah/umgahc.c
    src/uqm/comm/urquan/resinst.h
    src/uqm/comm/urquan/strings.h
    src/uqm/comm/urquan/urquanc.c
    src/uqm/comm/utwig/resinst.h
    src/uqm/comm/utwig/strings.h
    src/uqm/comm/utwig/utwigc.c
    src/uqm/comm/vux/resinst.h
    src/uqm/comm/vux/strings.h
    src/uqm/comm/vux/vuxc.c
    src/uqm/comm/yehat/resinst.h
    src/uqm/comm/yehat/strings.h
    src/uqm/comm/yehat/yehatc.c
    src/uqm/comm/zoqfot/resinst.h
    src/uqm/comm/zoqfot/strings.h
    src/uqm/comm/zoqfot/zoqfotc.c
    src/uqm/comm/commall.h
    src/uqm/lua/luafuncs/commfuncs.c
    src/uqm/lua/luafuncs/commfuncs.h
    src/uqm/lua/luafuncs/customfuncs.c
    src/uqm/lua/luafuncs/customfuncs.h
    src/uqm/lua/luafuncs/eventfuncs.c
    src/uqm/lua/luafuncs/eventfuncs.h
    src/uqm/lua/luafuncs/logfuncs.c
    src/uqm/lua/luafuncs/logfuncs.h
    src/uqm/lua/luafuncs/statefuncs.c
    src/uqm/lua/luafuncs/statefuncs.h
    src/uqm/lua/luacomm.c
    src/uqm/lua/luacomm.h
    src/uqm/lua/luadebug.c
    src/uqm/lua/luadebug.h
    src/uqm/lua/luaevent.c
    src/uqm/lua/luaevent.h
    src/uqm/lua/luainit.c
    src/uqm/lua/luainit.h
    src/uqm/lua/luastate.c
    src/uqm/lua/luastate.h
    src/uqm/planets/generate/genall.h
    src/uqm/planets/generate/genand.c
    src/uqm/planets/generate/genburv.c
    src/uqm/planets/generate/genchmmr.c
    src/uqm/planets/generate/gencol.c
    src/uqm/planets/generate/gendefault.c
    src/uqm/planets/generate/gendefault.h
    src/uqm/planets/generate/gendru.c
    src/uqm/planets/generate/genilw.c
    src/uqm/planets/generate/genmel.c
    src/uqm/planets/generate/genmyc.c
    src/uqm/planets/generate/genorz.c
    src/uqm/planets/generate/genpet.c
    src/uqm/planets/generate/genpku.c
    src/uqm/planets/generate/genrain.c
    src/uqm/planets/generate/gensam.c
    src/uqm/planets/generate/genshof.c
    src/uqm/planets/generate/gensly.c
    src/uqm/planets/generate/gensol.c
    src/uqm/planets/generate/genspa.c
    src/uqm/planets/generate/gensup.c
    src/uqm/planets/generate/gensyr.c
    src/uqm/planets/generate/genthrad.c
    src/uqm/planets/generate/gentrap.c
    src/uqm/planets/generate/genutw.c
    src/uqm/planets/generate/genvault.c
    src/uqm/planets/generate/genvux.c
    src/uqm/planets/generate/genwreck.c
    src/uqm/planets/generate/genyeh.c
    src/uqm/planets/generate/genzfpscout.c
    src/uqm/planets/generate/genzoq.c
    src/uqm/planets/calc.c
    src/uqm/planets/cargo.c
    src/uqm/planets/devices.c
    src/uqm/planets/elemdata.h
    src/uqm/planets/generate.h
    src/uqm/planets/gentopo.c
    src/uqm/planets/lander.c
    src/uqm/planets/lander.h
    src/uqm/planets/lifeform.h
    src/uqm/planets/orbits.c
    src/uqm/planets/oval.c
    src/uqm/planets/pl_stuff.c
    src/uqm/planets/plandata.h
    src/uqm/planets/planets.c
    src/uqm/planets/planets.h
    src/uqm/planets/plangen.c
    src/uqm/planets/pstarmap.c
    src/uqm/planets/report.c
    src/uqm/planets/roster.c
    src/uqm/planets/scan.c
    src/uqm/planets/scan.h
    src/uqm/planets/solarsys.c
    src/uqm/planets/solarsys.h
    src/uqm/planets/sundata.h
    src/uqm/planets/surface.c
    src/uqm/ships/androsyn/androsyn.c
    src/uqm/ships/androsyn/androsyn.h
    src/uqm/ships/androsyn/icode.h
    src/uqm/ships/androsyn/resinst.h
    src/uqm/ships/arilou/arilou.c
    src/uqm/ships/arilou/arilou.h
    src/uqm/ships/arilou/icode.h
    src/uqm/ships/arilou/resinst.h
    src/uqm/ships/blackurq/blackurq.c
    src/uqm/ships/blackurq/blackurq.h
    src/uqm/ships/blackurq/icode.h
    src/uqm/ships/blackurq/resinst.h
    src/uqm/ships/chenjesu/chenjesu.c
    src/uqm/ships/chenjesu/chenjesu.h
    src/uqm/ships/chenjesu/icode.h
    src/uqm/ships/chenjesu/resinst.h
    src/uqm/ships/chmmr/chmmr.c
    src/uqm/ships/chmmr/chmmr.h
    src/uqm/ships/chmmr/icode.h
    src/uqm/ships/chmmr/resinst.h
    src/uqm/ships/druuge/druuge.c
    src/uqm/ships/druuge/druuge.h
    src/uqm/ships/druuge/icode.h
    src/uqm/ships/druuge/resinst.h
    src/uqm/ships/human/human.c
    src/uqm/ships/human/human.h
    src/uqm/ships/human/icode.h
    src/uqm/ships/human/resinst.h
    src/uqm/ships/ilwrath/icode.h
    src/uqm/ships/ilwrath/ilwrath.c
    src/uqm/ships/ilwrath/ilwrath.h
    src/uqm/ships/ilwrath/resinst.h
    src/uqm/ships/lastbat/icode.h
    src/uqm/ships/lastbat/lastbat.c
    src/uqm/ships/lastbat/lastbat.h
    src/uqm/ships/lastbat/resinst.h
    src/uqm/ships/melnorme/icode.h
    src/uqm/ships/melnorme/melnorme.c
    src/uqm/ships/melnorme/melnorme.h
    src/uqm/ships/melnorme/resinst.h
    src/uqm/ships/mmrnmhrm/icode.h
    src/uqm/ships/mmrnmhrm/mmrnmhrm.c
    src/uqm/ships/mmrnmhrm/mmrnmhrm.h
    src/uqm/ships/mmrnmhrm/resinst.h
    src/uqm/ships/mycon/icode.h
    src/uqm/ships/mycon/mycon.c
    src/uqm/ships/mycon/mycon.h
    src/uqm/ships/mycon/resinst.h
    src/uqm/ships/orz/icode.h
    src/uqm/ships/orz/orz.c
    src/uqm/ships/orz/orz.h
    src/uqm/ships/orz/resinst.h
    src/uqm/ships/pkunk/icode.h
    src/uqm/ships/pkunk/pkunk.c
    src/uqm/ships/pkunk/pkunk.h
    src/uqm/ships/pkunk/resinst.h
    src/uqm/ships/probe/icode.h
    src/uqm/ships/probe/probe.c
    src/uqm/ships/probe/probe.h
    src/uqm/ships/probe/resinst.h
    src/uqm/ships/shofixti/icode.h
    src/uqm/ships/shofixti/resinst.h
    src/uqm/ships/shofixti/shofixti.c
    src/uqm/ships/shofixti/shofixti.h
    src/uqm/ships/sis_ship/icode.h
    src/uqm/ships/sis_ship/resinst.h
    src/uqm/ships/sis_ship/sis_ship.c
    src/uqm/ships/sis_ship/sis_ship.h
    src/uqm/ships/slylandr/icode.h
    src/uqm/ships/slylandr/resinst.h
    src/uqm/ships/slylandr/slylandr.c
    src/uqm/ships/slylandr/slylandr.h
    src/uqm/ships/spathi/icode.h
    src/uqm/ships/spathi/resinst.h
    src/uqm/ships/spathi/spathi.c
    src/uqm/ships/spathi/spathi.h
    src/uqm/ships/supox/icode.h
    src/uqm/ships/supox/resinst.h
    src/uqm/ships/supox/supox.c
    src/uqm/ships/supox/supox.h
    src/uqm/ships/syreen/icode.h
    src/uqm/ships/syreen/resinst.h
    src/uqm/ships/syreen/syreen.c
    src/uqm/ships/syreen/syreen.h
    src/uqm/ships/thradd/icode.h
    src/uqm/ships/thradd/resinst.h
    src/uqm/ships/thradd/thradd.c
    src/uqm/ships/thradd/thradd.h
    src/uqm/ships/umgah/icode.h
    src/uqm/ships/umgah/resinst.h
    src/uqm/ships/umgah/umgah.c
    src/uqm/ships/umgah/umgah.h
    src/uqm/ships/urquan/icode.h
    src/uqm/ships/urquan/resinst.h
    src/uqm/ships/urquan/urquan.c
    src/uqm/ships/urquan/urquan.h
    src/uqm/ships/utwig/icode.h
    src/uqm/ships/utwig/resinst.h
    src/uqm/ships/utwig/utwig.c
    src/uqm/ships/utwig/utwig.h
    src/uqm/ships/vux/icode.h
    src/uqm/ships/vux/resinst.h
    src/uqm/ships/vux/vux.c
    src/uqm/ships/vux/vux.h
    src/uqm/ships/yehat/icode.h
    src/uqm/ships/yehat/resinst.h
    src/uqm/ships/yehat/yehat.c
    src/uqm/ships/yehat/yehat.h
    src/uqm/ships/zoqfot/icode.h
    src/uqm/ships/zoqfot/resinst.h
    src/uqm/ships/zoqfot/zoqfot.c
    src/uqm/ships/zoqfot/zoqfot.h
    src/uqm/ships/ship.h
    src/uqm/supermelee/netplay/proto/npconfirm.c
    src/uqm/supermelee/netplay/proto/npconfirm.h
    src/uqm/supermelee/netplay/proto/ready.c
    src/uqm/supermelee/netplay/proto/ready.h
    src/uqm/supermelee/netplay/proto/reset.c
    src/uqm/supermelee/netplay/proto/reset.h
    src/uqm/supermelee/netplay/checkbuf.c
    src/uqm/supermelee/netplay/checkbuf.h
    src/uqm/supermelee/netplay/checksum.c
    src/uqm/supermelee/netplay/checksum.h
    src/uqm/supermelee/netplay/crc.c
    src/uqm/supermelee/netplay/crc.h
    src/uqm/supermelee/netplay/netconnection.c
    src/uqm/supermelee/netplay/netconnection.h
    src/uqm/supermelee/netplay/netinput.c
    src/uqm/supermelee/netplay/netinput.h
    src/uqm/supermelee/netplay/netmelee.c
    src/uqm/supermelee/netplay/netmelee.h
    src/uqm/supermelee/netplay/netmisc.c
    src/uqm/supermelee/netplay/netmisc.h
    src/uqm/supermelee/netplay/netoptions.c
    src/uqm/supermelee/netplay/netoptions.h
    src/uqm/supermelee/netplay/netplay.h
    src/uqm/supermelee/netplay/netrcv.c
    src/uqm/supermelee/netplay/netrcv.h
    src/uqm/supermelee/netplay/netsend.c
    src/uqm/supermelee/netplay/netsend.h
    src/uqm/supermelee/netplay/netstate.c
    src/uqm/supermelee/netplay/netstate.h
    src/uqm/supermelee/netplay/notify.c
    src/uqm/supermelee/netplay/notify.h
    src/uqm/supermelee/netplay/notifyall.c
    src/uqm/supermelee/netplay/notifyall.h
    src/uqm/supermelee/netplay/packet.c
    src/uqm/supermelee/netplay/packet.h
    src/uqm/supermelee/netplay/packethandlers.c
    src/uqm/supermelee/netplay/packethandlers.h
    src/uqm/supermelee/netplay/packetq.c
    src/uqm/supermelee/netplay/packetq.h
    src/uqm/supermelee/netplay/packetsenders.c
    src/uqm/supermelee/netplay/packetsenders.h
    src/uqm/supermelee/buildpick.c
    src/uqm/supermelee/buildpick.h
    src/uqm/supermelee/loadmele.c
    src/uqm/supermelee/loadmele.h
    src/uqm/supermelee/melee.c
    src/uqm/supermelee/melee.h
    src/uqm/supermelee/meleesetup.c
    src/uqm/supermelee/meleesetup.h
    src/uqm/supermelee/meleeship.h
    src/uqm/supermelee/pickmele.c
    src/uqm/supermelee/pickmele.h
    src/uqm/battle.c
    src/uqm/battle.h
    src/uqm/battlecontrols.c
    src/uqm/battlecontrols.h
    src/uqm/border.c
    src/uqm/build.c
    src/uqm/build.h
    src/uqm/cleanup.c
    src/uqm/clock.c
    src/uqm/clock.h
    src/uqm/cnctdlg.c
    src/uqm/cnctdlg.h
    src/uqm/coderes.h
    src/uqm/collide.c
    src/uqm/collide.h
    src/uqm/colors.h
    src/uqm/comm.c
    src/uqm/comm.h
    src/uqm/commanim.c
    src/uqm/commanim.h
    src/uqm/commglue.c
    src/uqm/commglue.h
    src/uqm/confirm.c
    src/uqm/cons_res.c
    src/uqm/cons_res.h
    src/uqm/controls.h
    src/uqm/corecode.h
    src/uqm/credits.c
    src/uqm/credits.h
    src/uqm/cyborg.c
    src/uqm/demo.c
    src/uqm/demo.h
    src/uqm/displist.c
    src/uqm/displist.h
    src/uqm/dummy.c
    src/uqm/dummy.h
    src/uqm/element.h
    src/uqm/encount.c
    src/uqm/encount.h
    src/uqm/flash.c
    src/uqm/flash.h
    src/uqm/fmv.c
    src/uqm/fmv.h
    src/uqm/galaxy.c
    src/uqm/gameev.c
    src/uqm/gameev.h
    src/uqm/gameinp.c
    src/uqm/gameopt.c
    src/uqm/gameopt.h
    src/uqm/gamestr.h
    src/uqm/gendef.c
    src/uqm/gendef.h
    src/uqm/getchar.c
    src/uqm/globdata.c
    src/uqm/globdata.h
    src/uqm/gravity.c
    src/uqm/grpinfo.c
    src/uqm/grpinfo.h
    src/uqm/grpintrn.h
    src/uqm/hyper.c
    src/uqm/hyper.h
    src/uqm/ifontres.h
    src/uqm/igfxres.h
    src/uqm/ikey_con.h
    src/uqm/imusicre.h
    src/uqm/init.c
    src/uqm/init.h
    src/uqm/intel.c
    src/uqm/intel.h
    src/uqm/intro.c
    src/uqm/ipdisp.c
    src/uqm/ipdisp.h
    src/uqm/iscriptres.h
    src/uqm/isndres.h
    src/uqm/istrtab.h
    src/uqm/load.c
    src/uqm/load_legacy.c
    src/uqm/loadship.c
    src/uqm/master.c
    src/uqm/master.h
    src/uqm/menu.c
    src/uqm/menustat.h
    src/uqm/misc.c
    src/uqm/nameref.h
    src/uqm/oscill.c
    src/uqm/oscill.h
    src/uqm/outfit.c
    src/uqm/pickship.c
    src/uqm/pickship.h
    src/uqm/plandata.c
    src/uqm/process.c
    src/uqm/process.h
    src/uqm/races.h
    src/uqm/resinst.h
    src/uqm/restart.c
    src/uqm/restart.h
    src/uqm/save.c
    src/uqm/save.h
    src/uqm/settings.c
    src/uqm/settings.h
    src/uqm/setup.c
    src/uqm/setup.h
    src/uqm/setupmenu.c
    src/uqm/setupmenu.h
    src/uqm/ship.c
    src/uqm/ship.h
    src/uqm/shipcont.h
    src/uqm/shipstat.c
    src/uqm/shipyard.c
    src/uqm/sis.c
    src/uqm/sis.h
    src/uqm/sounds.c
    src/uqm/sounds.h
    src/uqm/starbase.c
    src/uqm/starbase.h
    src/uqm/starcon.c
    src/uqm/starcon.h
    src/uqm/starmap.c
    src/uqm/starmap.h
    src/uqm/state.c
    src/uqm/state.h
    src/uqm/status.c
    src/uqm/status.h
    src/uqm/tactrans.c
    src/uqm/tactrans.h
    src/uqm/trans.c
    src/uqm/units.h
    src/uqm/uqmdebug.c
    src/uqm/uqmdebug.h
    src/uqm/util.c
    src/uqm/util.h
    src/uqm/velocity.c
    src/uqm/velocity.h
    src/uqm/weapon.c
    src/uqm/weapon.h
    src/config.h
    src/config_vc6.h
    src/endian_uqm.h
    src/options.c
    src/options.h
    src/port.c
    src/port.h
    src/types.h
    src/uqm.c
    src/uqmversion.h
    tools/keys/keyjam.c
)

link_directories(
    /usr/lib
)

target_link_libraries(${PROJECT_NAME}
    png m pthread SDL2 vorbisfile lz
)