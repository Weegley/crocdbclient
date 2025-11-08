@echo off

set I=temp.txt

IF [%2] == [] (
	echo.
	echo Incorrect request!
	echo Usage: %0 ^<search_type^> ^<parameter^>
	echo ^<search type^> can be either name or ID
	exit /B
	)

if [%1]==[name] (set QTYPE=search_key) else (set QTYPE=rom_id)

set ID=%2
set ID=%ID:"=%

echo %QTYPE%
echo %ID%

rem curl -s https://api.crocdb.net/search -X POST -d "{\"rom_id\":\"NPEA00275\",\"regions\":[\"eu\"]}" | jq -r ".data.results[] | select(.links[]?.type == \"DLC\") | \"\(.links[].url)\n\tdir=NPEA00275_DLC\\\\"\(.title)\""" > temp.txt

setlocal enabledelayedexpansion

echo getting DLC links for %1: !ID!...

curl -s https://api.crocdb.net/search -X POST -d "{\"!QTYPE!\":\"!ID!\",\"regions\":[\"eu\"]}" | jq -r ".data.results[] | select((.links[]?.type == \"DLC\") or (.title | contains(\"(DLC)\"))) | \"\(.links[].url)###\(.title)\"" > temp.txt


for /D %%i in (temp.txt) do if %%~zi==0 (
echo File is empty!
goto :EOF
)
echo Done. Generating links file for following items:

echo. 2>links.txt


for /F "usebackq delims=" %%i in ("temp.txt") do (
    for /f "tokens=1,2 delims=###" %%a in ("%%i") do (
        echo %%a >> links.txt
        set title=%%b
		set link=%%a
		set ext=!link:~-4!
		if NOT [!ext!]==[.rap] echo !title!
        set "clean_title=!title!"
        set "clean_title=!clean_title:<=!"
        set "clean_title=!clean_title:>=!"
        set "clean_title=!clean_title::=!"
        set "clean_title=!clean_title:"=!"
        set "clean_title=!clean_title:/=!"
        set "clean_title=!clean_title:\=!"
        set "clean_title=!clean_title:|=!"
        set "clean_title=!clean_title:?=!"
        set "clean_title=!clean_title:^*=!"
        echo 	dir=!ID!_DLC\!clean_title! >> links.txt
    )
)

echo.
echo All done. Use "aria2c -j 5 -i links.txt" to download all DLC's

del temp.txt
