## 如何製作動態 gif

1. sudo apt-get install imagemagick mplayer gtk-recordmydesktop
2. mplayer -ao null <video file name> -vo jpeg:outdir=output
3. convert output/* output.gif
4. convert output.gif -fuzz 10% -layers Optimize optimised.gif

若想在螢幕上顯示所輸入的字，可用 [screenkey](https://github.com/wavexx/screenkey)
