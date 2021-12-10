#### 介绍
android-ffmpeg-build-script-ilongge
## 测试环境:

* FFmpeg 4.3.3
* NDK-R21C
* MacOS 11.6.1 (20G221)

## 使用方法
 
配置脚本

```
# 编译平台
# "aarch64 arm"
ARCH=""
# 目标Android版本
API="24"
# 支持的CPU架构
CPU="armv8-a"
# so库输出目录
OUTPUT="../FFMpeg-$CPU-Android"
# NDK的路径
NDK=""
```

进入到当前目录直接执行脚本即可，如遇无法执行，可能是文件权限问题

```
# 进入目录
cd android-ffmpeg-build-script-ilongge
cd ffmpeg-4.3.3
# 赋予脚本可执行权限
chmod +x buidl-ffmpeg-android.sh
# 执行脚本
./buidl-ffmpeg-android.sh  

```


## Thanks
本脚本是摘抄自 [Mac环境下编译ffmpeg生成so库文件-CSDN](https://blog.csdn.net/AliEnCheng/article/details/116699763)

学习后加以改造 

感谢原作者！！！