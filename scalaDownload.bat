@rem scalaDownload.bat
@rem uses C:\shared as Scala directory (libDIR)

@rem https://www.scala-lang.org/download/scala2.html


@rem Check Scala-version!

@rem uses wget, 
@rem download with MSYS2 from: https://www.msys2.org/


@echo off

cd %~dp0

set ScalaFullVersion=2.13.6

C:\msys64\usr\bin\wget.exe -nc https://downloads.lightbend.com/scala/%ScalaFullVersion%/scala-%ScalaFullVersion%.zip

set libDIR=C:\shared\

IF not exist %libDIR% (mkdir %libDIR%)

copy /Y scala-%ScalaFullVersion%.zip %libDIR%scala-%ScalaFullVersion%.zip

cd %libDIR%

tar -xf scala-%ScalaFullVersion%.zip

cd %~dp0

del scala-%ScalaFullVersion%.zip


pause








