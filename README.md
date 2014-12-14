## Linux-tips

### 系統管理
1. 情境：計算硬碟上以/dev/開頭之filesystem剩餘空間。

	>bash 指令：df | grep ^/dev/ | awk '{sum += $4} END {print sum " bytes left" }'

2. 情境：看資料夾結構

	>指令：tree -d // 只列出資料夾 tree -L 2 只列出最多兩層

3. 情境：檢查特定service是否執行中

	>指令：ps aux | grep -v grep | grep service_name

4. 情境：自訂時間戳記(例如三個月前)

	>指令：date --date='-3 month' +%Y-%m`

5. 情境：自動將公鑰傳送至遠端機器並寫入相關設定

	>指令：ssh-copy-id -i ~/.ssh/(identity | id_dsa.pub | id_rsa.pub) username@ip

6. 情境：查看shell環境

	>指令一：ls -l \`which sh\`
	
	>指令二：echo $SHELL
	
	>指令三：env

7. 情境：檢查指令是否執行成功

	>腳本1：
		
		ping 8.8.8.8
		
		# check if the ping command was successfully executed. 
		# (0 means yes, 1 means no)
		if [ $? -eq 0 ]; then
			echo "successfully executed!" >> report.txt
		fi

	>腳本2：
		
		# this one is shorter
		ping 8.8.8.8 && echo "successfully executed!" >> report.txt

8. 情境：列出當前目錄所有檔案容量

	>指令：du -sh

9. 情境：持續觀察磁碟空間變化

	>指令：while true; do clear; df -h; sleep 3; done
	
	>指令：watch -n3 df -h

10. 情境：加入既有ssh private key

	>指令：cp id* .ssh; ssh-add

11. 情境：檢查是否以root身份執行

	>腳本 1：

		if [ "$UID" -ne "$ROOT_UID" ]
		then
			echo "執行身份非root"
		fi
	>腳本2：
	
		if [ `whoami` != "root" ];
		then
			echo "I am not root"
		fi

12. 情境：找出 /var 目錄下最大檔案前十名

	>指令：du -a /var | sort -n -r | head -n 10

13. 情境：列出所有已安裝套件 (Debian)

	>指令：dpkg --get-selections > inistalled_packages.txt

14. 情境：使得某些特定ip透過特定gw出去

	>腳本：
	
		arr=("ip1" "ip2")
		for i in ${arr[*]}
		do
			route add -host $i gw ip
		done

15. 情境：ls 列出的檔名需要跳脫(escape)時，自動幫你用引號包起來

	>指令：ls --quoting-style=shell

		# 結果例如： (可以 man ls 查看更多 style)
		'!this$file%contain&control(characters)~'  'this file contain whitespace char'  tmp.txt

16. 情境：查看CPU核心數 (連 Intel HT 超執行緒技術所虛擬成兩倍個數也算在內)

	>指令一：grep -c ^processor /proc/cpuinfo
	>指令二：grep -Ec '^cpu[0-9]+ ' /proc/stat

	// 常用來搭配 make 指令，寫在 shell script 中使用，以利加速建置。
	
	>腳本：

		cpu_cores="$(grep -c ^processor /proc/cpuinfo)"
		make -j$(cpu_cores)


17. 情境：釋出記憶體快取空間

	>指令一：sync; sudo sysctl vm.drop_caches={1, 2, 3, 4}

    	> 1 -> pagecache
    	> 2 -> slab cache
    	> 3 -> pagecache & slab cache
    	> 4 -> disable

    	詳見 https://www.kernel.org/doc/Documentation/sysctl/vm.txt

18. 情境: 使用ls列出最新的檔名列在最下面

    	>指令：ls -sort
	
19. 切換該terminal的訊息顯示語言為英文 (非永久變更，僅限該登入session)

	>指令： $ export LC_ALL=C;LANG=C;LANGUAGE=en_US

     	> 輸入locale進行確認：

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

20. 用sudo執行上一個指令
    
	>指令： $ sudo !!

### 文字編輯
1. 情境：去除檔案中惱人的^M符號。(注意，^M要打ctrl+v及ctrl+m才會出現。)

	>指令一：sed -i -e 's/^M//g' file
	
	>指令二：dos2unix file  
	
	// 這個符號多半是因為Windows上面編輯的檔案移到Unix系統上在編輯的時候會遇到，使用 dos2unix 可以直接轉換。
	
	>指令三：perl -p -i -e 's/\r\n$/\n/g' my_file.txt

	>指令四：若已經用 vim 開啟的話，可執行下列指令於 vim 裡：
	// 參考 [File format - Vim Tips Wiki](http://vim.wikia.com/wiki/File_format)

		:update            # 存儲任何修改。
		:e ++ff=dos        # 強制以 DOS 檔案格式，重新編輯檔案。
		:setlocal ff=unix  # 設定此 buffer 將只會以 LF 換行字元 (UNIX 檔案格式) 來寫入檔案。
		:w                 # 以 UNIX 檔案格式將  buffer 寫入檔案。


2. 情境：字串結合、調整

	>指令：echo {{1,2,3}1,2,3}

3. 情境：字串結合、調整

	>指令：echo fi{one,two,red,blue}sh

4. 情境：在檔案第一行插入字串（例如csv檔要加表格名稱）

	>指令：(echo -n '<added text>\n'; cat test) > new_test

5. 情境：大量改檔案編碼(big5 -> utf-8)

	>指令：遞迴改（不是真改）
	>convmv -r -f <from> -t <to> dir/

	>指令：遞迴改（真改）
	>convmv -r -f --notest -f <from> -t <to> dir/
	
6. 情境：一次用grep查詢2個以上關鍵字

	>指令: grep -E '(foo|bar)'

7. 情境: 字串全部自動改成大(小)寫

	>大寫 

	    $ echo TeSt | awk '{ print toupper($_) }'

	>小寫

	    $ echo TeSt | awk '{ print tolower($_) }'

### 檔案處理
1. 情境：大量改檔案名稱，並且遞增檔案id

	>指令：ls | awk '{print "mv "$1" "NR".txt"}' | sh

2. 情境：大量改檔案名稱，取代檔案名稱中的某些字串(例如拿掉副檔名)

	>指令：rename 's/\.bak$//' *.bak

3. 情境：大量改檔案名稱，大寫換小寫

	>指令：[rename](http://www.computerhope.com/unix/rename.htm) 'y/A-Z/a-z/' *

4. 情境：將目錄中所有檔案逐一處理（檔案名稱無規則性）

	>腳本：上面這個方法萬一資料夾裡面還有資料夾，可能就不符合預期行為。
	
		for file in $(ls folder)
		do 
			python utils/submit.py folder/$file 
		done
	
	>指令：find folder -type f -maxdepth=1 -exec CMD ‘{}’ \;

5. 情境：大檔案切割，切成多個小檔案

	>指令：split --bytes=1024m bigfile.iso file_prefix_

6. 情境：結合小檔案變成大檔案

	>指令：cat small_file_* > joined_file.iso

7. 情境：顯示目錄底下資料夾大小並排序

	>指令： du -B K /dir --max-depth=1 | sort -g	//KB為單位
	
	>指令： du -B M /dir --max-depth=1 | sort -g	//MB為單位
	
	>指令： du -B G /dir --max-depth=1 | sort -g	//GB為單位
	
8. 情境: 將目錄下所有的檔案製作MD5(遞迴走訪)

	>指令: find . -type f -exec md5sum {} \;

9. 情境: 創建1M的空白檔案(內容全部填0)

	>指令: dd if=/dev/zero of=test.img bs=1M count=1

	>檢查
	     
		$ hexdump -C test.img 
		00000000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
		*
		00100000
10. 情境: 將1.png ~ 10.png 更名為001.png ~ 010.png

	>指令: $ for i in \`seq 1 10\`; do mv $i.png \`printf "%03d" $i\`.png; done 
