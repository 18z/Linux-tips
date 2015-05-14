Routing Tables 簡介：
---

一般來說，Linux 系統預設保留的路由表有 local, main, default 及 unspec。下列將依據針對不同路由表講解

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

3. Default Routing Table

	*  閱讀相關資料 [3] 後，擷取相關內文如下，但尚未理解其中奧義。

		* The default table is empty. It is reserved for some post-processing if no previous default rules selected the packet.

4. Unspec Routing Table

	* 閱讀相關資料 [1] 後，擷取相關內文如下，但尚未理解其中奧義。

		* Operating on the unspec routing table appears to operate on all routing tables simultaneously. Is this true!? What does that imply?.
---

Routing Tables 號碼：

預設有 255 個 table 表。
換句話說，Linux 可以設定 255 組靜態路由 (static routing)，
扣掉 localhost ，可使 254個實體或虛擬網卡介面，進行靜態路由。

其中

```
table 254 號別名為 main
table 255 號別名為 local
table 253 號別名為 default
table 0   號別名為 unspec

可查看 /etc/iproute2/rt_tables
```
參考資料：

1. http://linux-ip.net/html/routing-tables.html
2. http://phorum.vbird.org/viewtopic.php?t=23934
3. http://www.lartc.org/manpages/ip.txt
