## Linux-tips

### 系統管理
1. 情境：計算硬碟上以/dev/開頭之filesystem剩餘空間

	```bash
	指令：df | grep ^/dev/ | awk '{sum += $4} END {print sum " bytes left" }'
	```
	![scenario1](./images/scenario1.gif)

2. 情境：看資料夾結構

	```bash
	指令：tree -d 
	```

	// 只列出資料夾 tree -L 2 只列出最多兩層

	![scenario2](./images/scenario2.gif)

3. 情境：檢查特定service是否執行中

	```bash
	指令：ps aux | grep -v grep | grep service_name
	```

4. 情境：自訂時間戳記 (例如三個月前)

	```bash
	指令：date --date='-3 month' +%Y-%m
	```

	![scenario4](./images/scenario4.gif)

5. 情境：自動將公鑰傳送至遠端機器並寫入相關設定

	```bash
	指令：ssh-copy-id -i ~/.ssh/(identity | id_dsa.pub | id_rsa.pub) username@ip
	```

6. 情境：查看shell環境

	```bash
	指令一：ls -l `which sh`

	指令二：echo $SHELL

	指令三：env

	指令四：ps $$

	指令五：echo "$0"
	```

7. 情境：檢查指令是否執行成功

	```bash
	腳本一：
	
	ping -c 1 8.8.8.8
	
	# check if the ping command was successfully executed. 
	# (0 means yes, 1 means no)
	
	if [ $? -eq 0 ]; then
		echo "successfully executed!" >> report.txt
	fi
	```

	```bash
	腳本二：
		
	# this one is shorter
	
	ping -c 1 8.8.8.8 && echo "successfully executed!" >> report.txt
	```

8. 情境：列出當前目錄所有檔案容量

	```bash
	指令：du -sh
	```

9. 情境：持續觀察磁碟空間變化

	```bash
	指令一：while true; do clear; df -h; sleep 3; done

	指令二：watch -n3 df -h
	```

10. 情境：加入既有ssh private key

	```bash
	指令：cp id* .ssh; eval `ssh-agent -s`; ssh-add
	```

11. 情境：檢查是否以root身份執行

	```bash
	腳本一：

	if [ "$UID" -ne "$ROOT_UID" ];
	then
		echo "執行身份非root"
	fi
	```
	
	```bash
	腳本二：
	
	if [ `whoami` != "root" ];
	then
		echo "I am not root"
	fi
	```

12. 情境：找出 /var 目錄下最大檔案前十名

	```bash
	指令：du -a /var | sort -n -r | head -n 10
	```

13. 情境：列出所有已安裝套件

	```bash
	指令一：dpkg --get-selections > inistalled_packages.txt (for debian)

	指令二：rpm -qa > inistalled_packages.txt (for fedora or centos)
	```

14. 情境：使得某些特定ip透過特定gw出去

	```bash
	腳本：
	
	arr=("ip1" "ip2")
	for i in ${arr[*]}
	do
		route add -host $i gw ip
	done
	```

	```bash
	指令：route add -net x.x.x.x netmask x.x.x.x gw x.x.x.x
	```

15. 情境：ls 列出的檔名需要跳脫(escape)時，自動幫你用引號包起來

	```bash
	指令：ls --quoting-style=shell

	// 結果例如： (可以 man ls 查看更多 style)
	// '!this$file%contain&control(characters)~'  'this file contain whitespace char'  tmp.txt
	```

16. 情境：查看CPU核心數 (連 Intel HT 超執行緒技術所虛擬成兩倍個數也算在內)

	```bash
	指令一：grep -c ^processor /proc/cpuinfo
	
	指令二：grep -Ec '^cpu[0-9]+ ' /proc/stat

	// 常用來搭配 make 指令，寫在 shell script 中使用，以利加速建置。
	```

	```bash
	腳本：

	cpu_cores="$(grep -c ^processor /proc/cpuinfo)"
	make -j$(cpu_cores)
	```

17. 情境：釋出記憶體快取空間

	```bash
	指令：sync; sudo sysctl vm.drop_caches={1, 2, 3, 4}

	// 1 -> pagecache
	// 2 -> slab cache
	// 3 -> pagecache & slab cache
	// 4 -> disable

	// 詳見 https://www.kernel.org/doc/Documentation/sysctl/vm.txt
	```

18. 情境：使用ls列出最新的檔名列在最下面

	```bash
	指令：ls -sort
	```

19. 切換該terminal的訊息顯示語言為英文 (非永久變更，僅限該登入session)

	```bash
	指令：export LC_ALL=C;LANG=C;LANGUAGE=en_US

	// 輸入locale進行確認：
	
	$ locale
	LANG=C
	LANGUAGE=en_US
	LC_CTYPE="C"
	LC_NUMERIC="C"
	LC_TIME="C"
	LC_COLLATE="C"
	LC_MONETARY="C"
	LC_MESSAGES="C"
	LC_PAPER="C"
	LC_NAME="C"
	LC_ADDRESS="C"
	LC_TELEPHONE="C"
	LC_MEASUREMENT="C"
	LC_IDENTIFICATION="C"
	LC_ALL=C
	```

20. 情境：用sudo執行上一個指令

	```bash
	指令：sudo !!
	```

21. 情境：檢查 iptables log 是否有持續收錄

	```bash
	腳本：

	NO_LOG=0
	NOWLOGS=$(grep iptables /var/log/messages| wc -l)
	PASTLOGS=$(cat n_of_log)

	if [ $NOWLOGS == $NO_LOG ]; then
		echo "no business today"
		
	elif [ $NOWLOGS -eq $PASTLOGS ]; then
		echo "no business during checking points"
		
	elif [ $NOWLOGS -gt $PASTLOGS ]; then
		echo "New logs logged"
		echo "$NOWLOGS" > n_of_log
		
	else
		echo "refresh n_of_log"
		echo "$NOWLOGS" > n_of_log
	
	fi
	```

22. 情境：檔案若使用git進行版本控制，檔案進行修改後，可使用指令產生patch，後續可在其他的git repositary 加入patch檔的修正

	```bash
	指令：git diff commit1 commit 2 > foo.patch
	```

   	![scenario22](./images/scenario22.gif)      

23. 情境：以SSH登入時出現「WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!」

	```bash
	指令：ssh-keygen -R 伺服器端的IP或網址
	```

24. 情境：用 date 轉換 unix time

	```bash
	指令：date -d @timestamp
	```

### 文字編輯
1. 情境：去除檔案中惱人的^M符號。(注意，^M要打ctrl+v及ctrl+m才會出現。)

	```bash
	指令一：sed -i -e 's/^M//g' file
	
	指令二：dos2unix file  
	
	// 這個符號多半是因為Windows上面編輯的檔案移到Unix系統上在編輯的時候會遇到，使用 dos2unix 可以直接轉換。
	
	指令三：perl -p -i -e 's/\r\n$/\n/g' my_file.txt

	指令四：若已經用 vim 開啟的話，可執行下列指令於 vim 裡：
	
	// 參考 [File format - Vim Tips Wiki](http://vim.wikia.com/wiki/File_format)

	:update            # 存儲任何修改。
	:e ++ff=dos        # 強制以 DOS 檔案格式，重新編輯檔案。
	:setlocal ff=unix  # 設定此 buffer 將只會以 LF 換行字元 (UNIX 檔案格式) 來寫入檔案。
	:w                 # 以 UNIX 檔案格式將  buffer 寫入檔案。
	```

2. 情境：字串結合、調整

	```bash
	指令：echo {{1,2,3}1,2,3}
	```

3. 情境：字串結合、調整

	```bash
	指令：echo fi{one,two,red,blue}sh
	```

4. 情境：在檔案第一行插入字串（例如csv檔要加表格名稱）

	```bash
	指令：(echo -n '<added text>\n'; cat test) > new_test
	```

5. 情境：大量改檔案編碼(big5 -> utf-8)

	```bash
	指令：convmv -r -f <from> -t <to> dir/
	
	// 遞迴改（不是真改）

	指令：convmv -r -f --notest -f <from> -t <to> dir/
	
	// 遞迴改（真改）
	```

6. 情境：一次用grep查詢2個以上關鍵字

	```bash
	指令：grep -E '(foo|bar)'
	```

7. 情境：字串全部自動改成大(小)寫

	```bash
	指令一：echo TeSt | awk '{ print toupper($_) }'
	
	// 全改大寫

	指令二：echo TeSt | awk '{ print tolower($_) }'

	// 全改小寫
	```

8. 情境：遞迴搜尋資料夾，但是忽略符合格式的檔案(例如 `*.pyc`)

	```bash
	指令：grep -r keyword --exclude '*.pyc' target_folder/

	// 範例：grep -r "import os" --exclude '*.pyc' my_project/
	```

9. 情境：迅速撈出檔案中的特定行數

	例如：迅速撈出第 16 行內容

	```bash
	指令一：nl index.html | grep "^\s*16" | head -n 1
	指令二：sed -n 16p index.html
	```

### 檔案處理
1. 情境：大量改檔案名稱，並且遞增檔案id

	```bash
	指令：ls | awk '{print "mv "$1" "NR".txt"}' | sh
	```

2. 情境：大量改檔案名稱，取代檔案名稱中的某些字串(例如拿掉副檔名)

	```bash
	指令：rename 's/\.bak$//' *.bak
	```

3. 情境：大量改檔案名稱，大寫換小寫

	```bash
	指令：rename 'y/A-Z/a-z/' *
	```

4. 情境：將目錄中所有檔案逐一處理（檔案名稱無規則性）

	```bash
	腳本：上面這個方法萬一資料夾裡面還有資料夾，可能就不符合預期行為。
	
	for file in $(ls folder)
	do 
		python utils/submit.py folder/$file 
	done
	```

	```bash
	指令：find folder -type f -maxdepth=1 -exec CMD ‘{}’ \;
	```

5. 情境：大檔案切割，切成多個小檔案

	```bash
	指令：split --bytes=1024m bigfile.iso file_prefix_
	```

6. 情境：結合小檔案變成大檔案

	```bash
	指令：cat small_file_* > joined_file.iso
	```

7. 情境：顯示目錄底下資料夾大小並排序

	```bash
	指令：du -B K /dir --max-depth=1 | sort -g	//KB為單位
	
	指令：du -B M /dir --max-depth=1 | sort -g	//MB為單位
	
	指令：du -B G /dir --max-depth=1 | sort -g	//GB為單位
	```

8. 情境： 將目錄下所有的檔案製作MD5(遞迴走訪)

	```bash
	指令：find . -type f -exec md5sum {} \;
	```

9. 情境：創建1M的空白檔案(內容全部填0)

	```bash
	指令：dd if=/dev/zero of=test.img bs=1M count=1

	// 檢查
	     
	$ hexdump -C test.img 
	00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
	*
	00100000
	```

10. 情境：將1.png ~ 10.png 更名為001.png ~ 010.png

	```bash
	指令：$ for i in `seq 1 10`; do mv $i.png `printf "%03d" $i`.png; done 
	```

11. 情境：將檔案名稱中空白部分以底線取代

	```bash
	指令：rename 'y/ /_/' *
	```

12. 情境：將 MySQL 資料庫內容輸出至 csv 檔

	```bash
	指令：mysql -u username -p -B -e "show columns from table;" | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g" >> test.csv
	```

13. 情境：快速備份檔案

	```bash
	腳本：請直接加在 .bashrc 中，並執行 source ~/.bashrc。
	
	function backup()
	{
		cp $1 $1.bak
	}

	# 使用方法：$ backup file.sh
	# 執行結果：產出 file.sh.bak 檔

	```

14. 情境：懶人解壓縮法

	```bash
	腳本：請直接加在 .bashrc 中，並執行 source ~/.bashrc。
	
	function extract()      # Handy Extract Program
	{
		if [ -f $1 ] ; then
			case $1 in
				*.tar.bz2)   tar xvjf $1     ;;  
				*.tar.gz)    tar xvzf $1     ;;  
				*.bz2)       bunzip2 $1      ;;  
				*.rar)       unrar x $1      ;;  
				*.gz)        gunzip $1       ;;  
				*.tar)       tar xvf $1      ;;  
				*.tbz2)      tar xvjf $1     ;;  
				*.tgz)       tar xvzf $1     ;;  
				*.zip)       unzip $1        ;;  
				*.Z)         uncompress $1   ;;  
				*.7z)        7z x $1         ;;  
				*)           echo "'$1' cannot be extracted via >extract<" ;;
			esac
		else
			echo "'$1' is not a valid file!"
		fi
	}

	# 使用方法：$ extract file.壓縮檔副檔名

	```
