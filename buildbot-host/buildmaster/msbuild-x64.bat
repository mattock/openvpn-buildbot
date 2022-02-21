rem Building x64 binaries
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
msbuild /m /p:Configuration=Release /p:Platform="x64" .
