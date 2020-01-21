PROJECT(ffmpeg_lite_static)

CMAKE_MINIMUM_REQUIRED(VERSION 3.2)

set(POSITION_INDEPENDENT_CODE TRUE)

INCLUDE(ExternalProject)

INCLUDE_DIRECTORIES(BEFORE ${CMAKE_BINARY_DIR}/include)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR}/lib)

SET(ENV{PKG_CONFIG_PATH} ${CMAKE_BINARY_DIR}/lib/pkgconfig)

if(APPLE)
    SET(OPENSSL_ARCH "darwin64-x86_64-cc")
else(APPLE)
    SET(OPENSSL_ARCH "linux-x86_64")
endif(APPLE)

EXTERNALPROJECT_ADD(nasm
  URL https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=${CMAKE_BINARY_DIR}
  BUILD_IN_SOURCE 1
)

EXTERNALPROJECT_ADD(gperf
  URL http://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=${CMAKE_BINARY_DIR} --enable-pic
  BUILD_IN_SOURCE 1
)

EXTERNALPROJECT_ADD(zlib
  URL https://github.com/madler/zlib/archive/v1.2.11.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=${CMAKE_BINARY_DIR} --static
  BUILD_IN_SOURCE 1
)

EXTERNALPROJECT_ADD(libxml2
  URL https://gitlab.gnome.org/GNOME/libxml2/-/archive/v2.9.9/libxml2-v2.9.9.tar.gz
  CONFIGURE_COMMAND ./autogen.sh --prefix=${CMAKE_BINARY_DIR} --enable-shared=no
  BUILD_IN_SOURCE 1
)

EXTERNALPROJECT_ADD(libpng
  DEPENDS zlib
  URL https://download.sourceforge.net/libpng/libpng-1.6.37.tar.gz
  CONFIGURE_COMMAND CFLAGS=-I${CMAKE_BINARY_DIR}/include CPPFLAGS=-I${CMAKE_BINARY_DIR}/include LDFLAGS=-L${CMAKE_BINARY_DIR}/lib ./configure --prefix=${CMAKE_BINARY_DIR} --disable-shared --enable-static
  BUILD_IN_SOURCE 1
)

EXTERNALPROJECT_ADD(x264
  DEPENDS nasm
  GIT_REPOSITORY http://git.videolan.org/git/x264.git
  GIT_TAG stable
  GIT_SHALLOW 1
  CONFIGURE_COMMAND ./configure --prefix=${CMAKE_BINARY_DIR} --bit-depth=8 --chroma-format=all --enable-static --enable-pic --enable-strip --disable-cli --disable-gpl --disable-avs --disable-ffms --disable-swscale --disable-gpac --disable-lsmash
  BUILD_COMMAND $(MAKE)
  BUILD_ALWAYS 0
  BUILD_IN_SOURCE 1
)

SET(FFMPEG_COMPONENTS --disable-doc --disable-postproc --disable-debug --disable-indevs --disable-outdevs --disable-sdl2 --disable-lzma --disable-iconv)
LIST(APPEND FFMPEG_COMPONENTS --pkg-config-flags=--static --disable-shared --enable-static --enable-gpl --enable-pic --enable-libx264 --enable-libxml2 --enable-ffmpeg --enable-ffprobe --disable-ffplay --disable-hwaccels --disable-v4l2-m2m --disable-vaapi --disable-vdpau --disable-videotoolbox --disable-audiotoolbox)
LIST(APPEND FFMPEG_COMPONENTS --enable-avcodec --enable-avformat --enable-avfilter --enable-swresample --enable-swscale --enable-avutil)
LIST(APPEND FFMPEG_COMPONENTS --disable-demuxers --enable-demuxer=mov,mpegts,dash,hls,h264,hevc,aac,rawvideo,streamconcat,concat,image2)
LIST(APPEND FFMPEG_COMPONENTS --disable-muxers --enable-muxer=mp4,mov,mpegts,dash,hls,segment,tee,h264,hevc,aac,rawvideo,image2)
LIST(APPEND FFMPEG_COMPONENTS --disable-decoders --enable-decoder=h264,hevc,aac,mjpeg,png,rawvideo)
LIST(APPEND FFMPEG_COMPONENTS --disable-encoders --enable-encoder=libx264,aac,mjpeg,png)
LIST(APPEND FFMPEG_COMPONENTS --disable-filters --enable-filter=scale,copy,concat,split,setpts,bwdif)
LIST(APPEND FFMPEG_COMPONENTS --disable-protocols --enable-protocol=file,pipe,unix,concat,http)
LIST(APPEND FFMPEG_COMPONENTS --extra-cflags=-I${CMAKE_BINARY_DIR}/include --extra-ldflags=-L${CMAKE_BINARY_DIR}/lib --extra-libs=-lpng\ -lz\ -lstdc++\ -lm\ -ldl)

EXTERNALPROJECT_ADD(ffmpeg
  DEPENDS nasm gperf x264 libpng libxml2
  URL http://www.ffmpeg.org/releases/ffmpeg-4.2.1.tar.bz2
  PATCH_COMMAND ${CMAKE_SOURCE_DIR}/../patches/patch.sh ffmpeg
  CONFIGURE_COMMAND PKG_CONFIG_PATH=$ENV{PKG_CONFIG_PATH} ./configure --prefix=${CMAKE_BINARY_DIR} --datadir=${CMAKE_BINARY_DIR}/etc ${FFMPEG_COMPONENTS}
  BUILD_COMMAND $(MAKE)
  BUILD_ALWAYS 0
  BUILD_IN_SOURCE 1
)
