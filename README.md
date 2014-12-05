## Linux-tips

### 系統管理
1. 情境：計算硬碟上所有filesystem剩餘之空間。

		指令：df|awk '{sum += $4} END {print sum}'

	[更多關於df](http://man7.org/linux/man-pages/man1/df.1.html)
	
	[更多關於awk](http://linux.vbird.org/linux_basic/0330regularex.php#awk)

2. 情境：看資料夾結構

		指令：tree -d // 只列出資料夾 tree -L 2 只列出最多兩層

	[更多關於tree](http://linux.die.net/man/1/tree)

3. 情境：檢查特定service是否執行中

		指令：ps aux | grep -v grep | grep service_name

	[更多關於ps](http://linux.vbird.org/linux_basic/0440processcontrol.php#ps)
4. 情境：自訂時間戳記(例如三個月前)

		指令：date --date='-3 month' +%Y-%m`

5. 情境：自動將公鑰傳送至遠端機器並寫入相關設定

		指令：ssh-copy-id -i ~/.ssh/(identity|id_dsa.pub|id_rsa.pub) username@ip

6. 情境：查看shell環境

		指令一：ls -l `which sh`
		指令二：echo $SHELL
		指令三：env

7. 情境：檢查指令是否執行成功

		腳本：
		ping 8.8.8.8

		# check if the ping command was successfully executed. 
			# (0 means yes, 1 means no)
			if [ $? -eq 0 ]; then
				echo "successfully executed!" >> report.txt
			fi

8. 情境：列出當前目錄所有檔案容量

		指令：du -sh

9. 情境：持續觀察磁碟空間變化

		指令：while true; do clear; df -h; sleep 3; done
		指令：watch -n3 df -h

10. 情境：加入既有ssh private key

		指令：cp id* .ssh; ssh-add

11. 情境：檢查是否以root身份執行

		腳本：
		if [ "$UID" -ne "$ROOT_UID" ]
		then
			echo "執行身份非root"
		fi

12. 情境：找出 /var 目錄下最大檔案前十名

		指令：du -a /var | sort -n -r | head -n 10

13. 情境：列出所有已安裝套件 (Debian)

		指令：dpkg --get-selections > inistalled_packages.txt

14. 情境：使得某些特定ip透過特定gw出去

		arr=("ip1" "ip2")

		for i in ${arr[*]}
		do
			route add -host $i gw ip
		done

### 文字編輯
1. 情境：去除檔案中惱人的^M符號。(注意，^M要打ctrl+v及ctrl+m才會出現。)

		指令一：sed -i -e 's/^M//g' file
		指令二：dos2unix file // 這個符號多半是因為Windows上面編輯的檔案移到Unix系統上在編輯的時候會遇到，使用 dos2unix 可以直接轉換。
		指令三：perl -p -i -e 's/\r\n$/\n/g' my_file.txt

2. 情境：字串結合、調整

		指令：echo {{1,2,3}1,2,3}

3. 情境：字串結合、調整

		指令：echo fi{one,two,red,blue}sh

4. 情境：在檔案第一行插入字串（例如csv檔要加表格名稱）

		指令：(echo -n '<added text>\n'; cat test) > new_test

5. 情境：大量改檔案編碼(big5 -> utf-8)

		指令：遞迴改（不是真改）
		convmv -r -f <from> -t <to> dir/

		指令：遞迴改（真改）
		convmv -r -f --notest -f <from> -t <to> dir/

### 檔案處理
1. 情境：大量改檔案名稱，並且遞增檔案id

		指令：ls | awk '{print "mv "$1" "NR".txt"}' |sh

2. 情境：大量改檔案名稱，取代檔案名稱中的某些字串(例如拿掉副檔名)

		指令：rename 's/\.bak$//' *.bak

3. 情境：大量改檔案名稱，大寫換小寫

		指令：rename 'y/A-Z/a-z/' *
	[更多關於rename](http://www.computerhope.com/unix/rename.htm)

4. 情境：將目錄中所有檔案逐一處理（檔案名稱無規則性）

		腳本：上面這個方法萬一資料夾裡面還有資料夾，可能就不符合預期行為。
		for file in $(ls folder)
		do 
			python utils/submit.py folder/$file 
		done

		指令：find folder -type f -maxdepth=1 -exec CMD ‘{}’ \;

5. 情境：大檔案切割，切成多個小檔案

		指令：split --bytes=1024m bigfile.iso file_prefix_

6. 情境：結合小檔案變成大檔案

		指令：cat small_file_* > joined_file.iso
