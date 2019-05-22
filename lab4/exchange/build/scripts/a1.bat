@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  a1 startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Add default JVM options here. You can also use JAVA_OPTS and A1_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto init

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto init

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:init
@rem Get command-line arguments, handling Windows variants

if not "%OS%" == "Windows_NT" goto win9xME_args

:win9xME_args
@rem Slurp the command line arguments.
set CMD_LINE_ARGS=
set _SKIP=2

:win9xME_args_slurp
if "x%~1" == "x" goto execute

set CMD_LINE_ARGS=%*

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\a1-1.0-SNAPSHOT.jar;%APP_HOME%\lib\grpc-netty-shaded-1.20.0.jar;%APP_HOME%\lib\grpc-protobuf-1.20.0.jar;%APP_HOME%\lib\grpc-stub-1.20.0.jar;%APP_HOME%\lib\protobuf-gradle-plugin-0.8.8.jar;%APP_HOME%\lib\grpc-protobuf-lite-1.20.0.jar;%APP_HOME%\lib\grpc-core-1.20.0.jar;%APP_HOME%\lib\protobuf-java-3.7.1.jar;%APP_HOME%\lib\osdetector-gradle-plugin-1.4.0.jar;%APP_HOME%\lib\os-maven-plugin-1.4.0.Final.jar;%APP_HOME%\lib\maven-plugin-api-3.2.1.jar;%APP_HOME%\lib\org.eclipse.sisu.plexus-0.0.0.M5.jar;%APP_HOME%\lib\guava-26.0-android.jar;%APP_HOME%\lib\proto-google-common-protos-1.12.0.jar;%APP_HOME%\lib\commons-lang-2.6.jar;%APP_HOME%\lib\grpc-context-1.20.0.jar;%APP_HOME%\lib\gson-2.7.jar;%APP_HOME%\lib\error_prone_annotations-2.3.2.jar;%APP_HOME%\lib\jsr305-3.0.2.jar;%APP_HOME%\lib\annotations-4.1.1.4.jar;%APP_HOME%\lib\animal-sniffer-annotations-1.17.jar;%APP_HOME%\lib\opencensus-contrib-grpc-metrics-0.19.2.jar;%APP_HOME%\lib\opencensus-api-0.19.2.jar;%APP_HOME%\lib\checker-compat-qual-2.5.2.jar;%APP_HOME%\lib\j2objc-annotations-1.1.jar;%APP_HOME%\lib\maven-model-3.2.1.jar;%APP_HOME%\lib\maven-artifact-3.2.1.jar;%APP_HOME%\lib\plexus-utils-3.0.17.jar;%APP_HOME%\lib\cdi-api-1.0.jar;%APP_HOME%\lib\sisu-guice-3.1.0-no_aop.jar;%APP_HOME%\lib\org.eclipse.sisu.inject-0.0.0.M5.jar;%APP_HOME%\lib\plexus-component-annotations-1.5.5.jar;%APP_HOME%\lib\plexus-classworlds-2.4.jar;%APP_HOME%\lib\jsr250-api-1.0.jar;%APP_HOME%\lib\javax.inject-1.jar;%APP_HOME%\lib\aopalliance-1.0.jar

@rem Execute a1
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %A1_OPTS%  -classpath "%CLASSPATH%" Main %CMD_LINE_ARGS%

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable A1_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%A1_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
