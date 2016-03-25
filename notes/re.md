## Regular Expression 筆記

1.  GooglePlay Android Application 頁面

    ```bash
    目的：將該頁面中所有的 Application 的 id 爬出來 (該頁面以 g.html 為檔名存擋)
    $ grep -Po '(?<=\?id=)[^"]*' g.html |sort|uniq|grep -P "\."|grep -v "\+"
    am.sunrise.android.calendar
    com.alfred.parkinglot
    com.apple.android.music
    com.asus.livewallpaper.asusdayscene
    com.balysv.loop
    com.bbs.reader
    com.djages.taipeifoodblogs
    com.ea.game.simcitymobile_row
    com.esri.arcgis.android.idt.EPA.HL
    ...
    ```


