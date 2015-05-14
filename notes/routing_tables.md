Routing Tables 簡介：
---

1. Local Routing Table

	* Local routing table 由 kernel 進行維護。一般而言，使用者可檢視其內容，但不建議進行人為修改。

	* Local routing table 中，主要有三種類型路由 (local, nat, broadcast)，其中常見兩種用途為：
		* 第一種為規範 braodcast address，使 link layers 能進行廣播。
		* 第二種為指向主機上所有IP (假設一台機器上有多IP) 的路由。使進入主機的封包知道要往哪個介面、IP 走。

2. Main Routing Table

	* Main routing table 為一般使用者所認知的 linux routing table。
		* route 指令所修改的路由內容，就是修改 main routing table 中的內容。
	* 若未使用 ip route 指令指定該使用哪張路由表時，則 kernel 就會使用 main routing table。
	* 與 local routing table 相似，main routing table 也是由 kernel 自動產生。

---

Routing Tables 號碼：

預設有 255 個 table 表。
換句話說，Linux 可以設定 255 組靜態路由 (static routing)，
扣掉 localhost ，可使 254個實體或虛擬網卡介面，進行靜態路由。

其中 table 254 號被別名為 main，
table 0 號別名為 local。

參考資料：

1. http://linux-ip.net/html/routing-tables.html
2. http://phorum.vbird.org/viewtopic.php?t=23934
