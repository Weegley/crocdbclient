@echo off
setlocal enabledelayedexpansion
set I=temp.txt
set ID=%~1

rem curl -s https://api.crocdb.net/search -X POST -d "{\"rom_id\":\"NPEA00275\",\"regions\":[\"eu\"]}" | jq -r ".data.results[] | select(.links[]?.type == \"DLC\") | \"\(.links[].url)\n\tdir=NPEA00275_DLC\\\\"\(.title)\""" > temp.txt


echo getting DLC links for !ID!...
curl -s https://api.crocdb.net/search -X POST -d "{\"rom_id\":\"!ID!\",\"regions\":[\"eu\"]}" | jq -r ".data.results[] | select(.links[]?.type == \"DLC\") | \"\(.links[].url)###\(.title)\"" > temp.txt

for /D %%i in (temp.txt) do if %%~zi==0 (
echo File is empty!
goto :EOF
)
echo Done. Generating links file...

echo. 2>links.txt


for /F "usebackq delims=" %%i in ("temp.txt") do (
    for /f "tokens=1,2 delims=###" %%a in ("%%i") do (
        echo %%a >> links.txt
        set title=%%b
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

del temp.txt
