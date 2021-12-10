#!/bin/bash

# FFmpeg版本
FFMPEG_VERSION="4.3.3"
if [ ! -n "$FFMPEG_VERSION" ]; then
	$FFMPEG_VERSION="4.3.3"
fi
# 编译平台
# "aarch64 arm"
ARCH=""
# 目标Android版本
API="24"
# 支持的CPU架构
CPU="armv8-a"
# so库输出目录
OUTPUT="FFMpeg-$CPU-Android"
# NDK的路径
NDK="/Users/ilongge/MineCode/android-ndk-r22b"
if [ ! -n "$NDK" ]; then
	echo "请配置NDK路径！！！"
	exit 1
fi

if [ ! $(which yasm) ]; then
	echo 'Yasm not found'
	if [ ! $(which brew) ]; then
		echo 'Homebrew not found. Trying to install...'
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ||
			exit 1
	fi
	echo 'Trying to install Yasm...'
	brew install yasm || exit 1
fi

# 编译工具链路径
TOOLCHAIN="$NDK/toolchains/llvm/prebuilt/darwin-x86_64"
# 编译环境
SYSROOT="$TOOLCHAIN/sysroot"
# 编译参数
CONFIGURE_FLAGS=""
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-cross-compile"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-debug"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-programs"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-doc"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffplay"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffprobe"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-symver"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-ffmpeg"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-avdevice"
# 动态库
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-shared"
# 静态库
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --disable-static"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-pic"
CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-neon"

CROSS_PREFIX_CLANG="$TOOLCHAIN/bin"
EXTRA_CFFLAGS="-fPIC"
CROSS_PREFIX=""
if [ $CPU = "armv8-a" ]; then
	ARCH="aarch64"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-x86asm"
	CROSS_PREFIX="$CROSS_PREFIX_CLANG/$ARCH-linux-android-"
	CROSS_PREFIX_CLANG="$CROSS_PREFIX_CLANG/$ARCH-linux-android$API-"
elif [ $CPU = "armv7-a" ]; then
	ARCH="arm"
	CROSS_PREFIX="$CROSS_PREFIX_CLANG/arm-linux-androideabi-"
	CROSS_PREFIX_CLANG="$CROSS_PREFIX_CLANG/armv7a-linux-androideabi$API-"
	CONFIGURE_FLAGS="$CONFIGURE_FLAGS  --enable-asm"
fi

echo "./configure"
echo "    --prefix=$OUTPUT"
echo "    --target-os=android"
echo "    --arch=$ARCH"
echo "    --cpu=$CPU"
for FLAG in $CONFIGURE_FLAGS; do
	echo "    "$FLAG
done
echo "    --sysroot=$SYSROOT"
echo "    --cross-prefix=$CROSS_PREFIX""clang"
echo "    --cross-prefix-clang=$CROSS_PREFIX_CLANG""clang"
echo "    --extra-cflags=$EXTRA_CFFLAGS"

./configure \
	--prefix=$OUTPUT \
	--target-os=android \
	--arch=$ARCH \
	--cpu=$CPU \
	$CONFIGURE_FLAGS \
	--sysroot=$SYSROOT \
	--cross-prefix=$CROSS_PREFIX \
	--cross-prefix-clang=$CROSS_PREFIX_CLANG \
	--extra-cflags=$EXTRA_CFFLAGS || exit 1
#获取机器CPU核心数 尽可能加快编译
THREAD_COUNT=$(sysctl -n machdep.cpu.thread_count)
echo "make -j $THREAD_COUNT install"
make -j$THREAD_COUNT install || exit 1
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+  Congratulations ! ! !                            +"
echo "+  Build FFMpeg-Android Success ! ! !               +"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "make clean"
make clean
