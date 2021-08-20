chdir "F:\Program Files (x86)\pyz80"
xcopy "F:\Dropbox\Wombles\Game conversions\Bubble-Ghost-music\Full version" "F:\Program Files (x86)\pyz80\test" /E /C /Q /R /Y
pyz80.py -I test/samdos2 -D DEBUG --exportfile=test/symbol.txt --mapfile=test/auto.map test/auto.asm
move /Y "F:\Program Files (x86)\pyz80\test\auto.dsk" "F:\Dropbox\Wombles\Game conversions\Bubble-Ghost-music\Full version\auto.dsk"
move /Y "F:\Program Files (x86)\pyz80\test\symbol.txt" "F:\Dropbox\Wombles\Game conversions\Bubble-Ghost-music\Full version\symbol.txt"
move /Y "F:\Program Files (x86)\pyz80\test\auto.map" "F:\Dropbox\Wombles\Game conversions\Bubble-Ghost-music\Full version\auto.map"
del /Q "F:\Program Files (x86)\pyz80\test\*.*"
"F:\Dropbox\Wombles\Game conversions\Bubble-Ghost-music\Full version\auto.dsk"