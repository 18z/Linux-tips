## Linux 雙網卡流量分割之實作、疑問與證明

### 前言

筆者從馬里蘭大學一份技術文件[1]上，學習雙網卡流量分割之原理與實作。然而，閱讀時，對部分內容產生疑惑。因此，筆者設計了相關實驗來觀察運作原理是否如該文所述。

以下段落安排為 1. 技術文件原文。2. 接著筆者將指出針對此文之疑問處。3. 最後以實驗方式將疑問處進行證明，並試圖將運作原理作更詳細解釋。

---

### 1. 技術文件原文與網路架構圖

The situation: A single box has multiple NICs in it, each connected to a different subnet (and therefore with distinct IP addresses). For specificity in the following, let us assume it has two NICs, one NICA having an IP address IPaddrA on the subnetA subnet. The other, NICB, has IP address IPaddrB on the subnetB subnet.

The symptoms: All machines on subnetA can see the box using IPaddrA. Similarly, boxes on subnetB can see the box using IPaddrB. I believe you should also be able to see either address ( IPaddrA or IPaddrB ) if on the other subnet ( subnetB or subnetA, respectively), but won't guarrantee it. The problem is that outside hosts, not on either local subnet (neither subnetA nor subnetB ) can only see the machine using one of the two addresses, and get no response from the other one.

Specifics: Observed with Glued Red Hat Enterprise Edition v3 for x86 based processors. Mainly seen on one box, a Dell PowerEdge 1650 with dual onboard Intel 82544EI NICs.

My analysis: Let us assume that it is IPaddrA which is visible from the outside world, and IPaddrB that is blocked. What appears to be happening is that both NICs function properly with respect to traffic on their own subnet. IPaddrA functions properly even for stuff not on subnetA; when a machine on some other net tries to contact, the subnetA gateway sends the packets to NICA, and the response goes out on NICA back to the gateway, with a source address of IPaddrA and the foreign machines IP address.

When a machine not on subnetB tries to talk to IPaddrB, things start the same. The subnetB gateway sends the packets to NICB, the linux box decides how to respond, and a response is sent out. However, the response goes out on NICA but with the IPaddrB source address. If the machine trying to be reached is on subnetA, the packets seem to get to the destination and no one complains. But if the packets are for another subnet, the router drops the packets because the source address is illegal for subnetA (as it is IPaddrB which is a subnetB address).

For example, if the two subnets are 172.70.12.0/23 and 172.80.24.0/23 on and, respectively, with 172.70.12.1 and 172.80.24.1 as the gateways you can do something like

```bash
#Set up the first subnet's routing table (we'll name it 70)
ip route flush table 70
ip route add table 70 to 172.70.12.0/23 dev eth0
ip route add table 70 to default via 172.70.12.1 dev eth0

#Set up the second subnet's routing table (we'll call it 80)
ip route flush table 80
ip route add table 80 to 172.80.24.0/23 dev eth1
ip route add table 80 to default via 172.80.24.1 dev eth1

#Create the rules to choose what table to use. Choose based on source IP
#We need to give the rules different priorities; for convenience name priority
#after the table
ip rule add from 172.70.12.0/23 table 70 priority 70
ip rule add from 172.80.24.0/23 table 80 priority 80

#Flush the cache to make effective
ip route flush cache
```

網路架構圖

```
                                            ________
                     +------------+        /
                     |            |       |
       +-------------+  subnetA   +-------
       |             |            |     /
+------+-------+     +------------+    |
|     NICA     |                      /
|              |                      |
+ Linux router |                      |     Internet
|              |                      |
|     NICB     |                      \
+------+-------+     +------------+    |
       |             |            |     \
       +-------------+  subnetB   +-------
                     |            |       |
                     +------------+        \________
```

---

### 2. 疑問集

#### 原文提到：“However, the response goes out on NICA but with the IPaddrB source address.”。

```bash
疑問一：果真回應的封包上，Source IP 是 IPaddrB？
```

#### 原文提到：“The router drops the packets because the source address is illegal for subnetA (as it is IPaddrB which is a subnetB address).”

```bash
疑問二：router drops the packets。
	   這裏的 router 指的是 Linux 本機？還是傳送出去後其他的 router？
```

---

### 3. 實驗、證明與說明

以下，將針對上面兩個疑問做實驗，證明是否為真。

證明一：回應時，封包的 src IP 位置是 IpaddrB。

```bash
假定

table 70 is for subnetA 172.70.12.0/23
table 80 is for subnetB 172.80.24.0/23

$ ip rule add from 172.70.12.0/23 table 70 priority 70

上述指令表示，新增一條路由規則。
該規則為，若封包來源位置屬於 172.70.12.0/23 (subnetA) 網段，
則選取路由表 70 之路由表項來決定如何派送封包。

$ ip rule add from 172.80.24.0/23 table 80 priority 80

同理，若封包來源位置屬於 172.80.24.0/23 (subnetB) 網段，
則選取路由表 80 之路由表項來決定如何派送封包。

上述規則建立後，實驗結果顯示 IpaddrB 的回應可順利傳送出去。

表示，table 80 被選取為封包派送的指南。
間接證明回應封包的 src IP 位置是 IpaddrB。(# 得證 1)
```

證明二：封包被 drop 是 Linux 本機幹的，而非外部 router。

```bash

假定我們已建立 table 70 與 80 兩張路由表，其表項內容分別為：

70 : 表項內容為 src Ipaddr 屬於 subnetA 就往 subnet A gw 送
80 : 表項內容為 src Ipaddr 屬於 subnetB 就往 subnet B gw 送

但 main routing table 卻沒設定 default gw

在上述路由環境下，
此時，若想從本機往外 ping 出去，是無法成功的。
(以 tcpdump 在 NICA NICB 上聽，都沒聽到任何封包)。

然而，若透過 ping -I 分別指定 IpaddrA 與 IpaddrB 為 src Ipaddr 後，
即可順利往外部發送 ICMP。

這代表兩張 table 還是有發揮效用的。

換句話說，一開始無法往外 ping 之原因，
就是往外傳送之封包內容，
其 src Ipaddr 沒有符合使用 table 70 或 table 80 之條件。
因此，封包就沒有往正確的 gw 送。(# 得證 2)

接著，我們將上面的路由環境做一點小小的變更。
我們在 main routing table 上指定 default gw (subnetA 或 subnetB 的都可)。

此時，往外 ping 就能成功。

因此，我們做如下推論：

若在 main routing table 上指定 default gw，
則系統會以 NIC 上與 default gw 同一 subnet 的 IP 為 src Ipaddr。(# 得證 3)

接著，我們再對路由環境做一些調整。

我們將 table 70 與 table 80 刪除。
且 main routing table 上的 default gw 是 subnet A 上的那一個。

此時，若有外部 IP 嘗試與 IpaddrB 溝通，
則主機回應的封包就會以 IpaddrB 當作封包的 src Ipaddr (詳見 # 得證 1)，
然後送給 default gw A (subnet A)。(若送給 default gw B 就會通了)

又因，
透過 subnet A 的 gw 出去，
Linux 主機會以 subnetA 上面的 IP 作 src Ipaddr。(詳見 # 得證 3)

但回應的封包 src Ipaddr 是 IpaddrB，

因此推測，或許真如技術文件所說，檢查完發現是 illegal Ipaddr 後就 drop 掉。
也就是說，Drop 掉封包的 router 指的就是 Linux 本機，而非外部的 router。
(得證 #4)
```

### 參考文獻：

[1] http://www.physics.umd.edu/pnce/pcs-docs/Glue/linux-route-hack.html#dual-subnets
