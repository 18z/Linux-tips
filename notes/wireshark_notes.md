## 網路封包分析筆記

### 封包分析前置作業：

1. 安裝 wireshark
	
	細節可參考 [wireshark 官網](https://www.wireshark.org/download.html)

2. 調整 wireshark 封包顯示欄位

*  欄位調整細節

```
預設顯示欄位為：
	No., Time, Src, Dst, Protocol, Info

筆者參考 Malware-Traffic-Analysis.net 文件後，
發現將欄位作如下調整，確實能提升分析效率：

	1. 移除 No., Protocol 兩個欄位。
	2. 新增 Src Port, Dst Port, Host (https), Host (http) 四個欄位。

新欄位如下：
	Time, Src, Src Port, Dst, Dst Port, Host (https), Host (http), Info

```

* 欄位設定

```
可編輯 ~/.wireshark/preferences 檔案，進行欄位調整：

找到第 198 行，將 No. 及 Protocol 兩欄位隱藏起來。
gui.column.hidden: %m,%p

找到第 202 行，新增四個欄位。
gui.column.format: 
    "No.", "%m",
    "Time", "%t",
    "Source", "%s",
    "Src Port", "%uS",
    "Destination", "%d",
    "Dst Port", "%uD",
    "Protocol", "%p",
    "Host (https)", "%Cus:ssl.handshake.extensions_server_name:0:R",
    "Host (http)", "%Cus:http.host:0:R",
    "Info", "%i" 
    
修改完成後，存擋。

重新開啟 wireshark，即可看到新欄位設定。

```

### 好用 filter

1. 查看 http request
	
	`filter: http.request`

2. 查看 https 連線 host name

	`filter: ssl.handshake.extensions_server_name`

3. 查看區網中主機的 host name

	`filter: nbns`

	`filter: udp.port eq 67`

4. 匯出封包中，透過 http 連線所傳輸的檔案

	`File -> export object -> HTTP`

5. 藉由 IDS 或 VT 查找封包中有無惡意活動

	`以 snort 或 Suricata 掃描`

	`上傳至 virus total 掃描`

--
備註：本文內容絕大部份參考 Malware-Traffic-Analysis.net