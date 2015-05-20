Linux NAT 實作
---

本文目的在實作與解說

1. 將外部主機，連線至 NAT server 上 public IP 之流量，完全映射到內部網路中一個 private IP。
2. 使內部網路許多 private IP，透過 NAT server 上之 public IP 對外聯繫。(只可內對外，外無法主動對內。)

網路介面配置

```bash
Linux NAT Server NIC 配置

NICA (public)
	address: 10.3.34.148
	netmask: 255.255.0.0
	Bcast:   10.3.255.255
	gateway: 10.3.34.254

NICB (private)
	address: 192.168.0.254
	netmask: 255.255.255.0
	Bcast:   192.168.0.255

VM NIC 配置

NICC (private)
	address: 192.168.0.1
   	netmask: 255.255.255.0
   	Bcast:   192.168.0.255
  	gateway: 192.168.0.254
```
網路架構圖

```bash
                       +------------+
                       |            |
         +-------------+  Outsider  |
         |             |            |
+--------+---------+   +------------+
| (8)   NICA   (1) |
|                  |
| Linux NAT server |
|                  |
| (7)  Routing (2) |
|                  |
| (6)   NICB   (3) |
+--------+---------+   +------------+
         |             | (4)        |
         |             |            |
         +-------------+ NICC    VM |
                       |            |
                       | (5)        |
                       +------------+
```

實作一：流量完全映射

在 Linux NAT server 上，設定以下兩條 iptables rule，即可達成目標。

```bash
# 開啟封包轉送功能
echo 1 > /proc/sys/net/ipv4/ip_forward

# 在 prerouting chain 中，將目的地是 10.3.34.148 的封包，修改封包目的地為 192.168.0.1
iptables -t nat -A PREROUTING -d 10.3.34.148 -j DNAT --to-destination 192.168.0.1

# 在 postrouting chain 中，將來源是 192.168.0.1 的封包，修改封包來源位置為 10.3.34.148
iptables -t nat -A POSTROUTING -s 192.168.0.1 -j SNAT --to-destination 10.3.34.148
```

封包傳遞解說：

```
Outsider -> Linux NAT server -> VM

(1) prerouting chain 改 dest 為 vm 的 IP。
(2) 透過 routing table 判斷 packet 往 NIC B 上 192.168.0.0/24 送
(3) 封包要出去前 postrouting chain 沒 match 到，所以不做事。透過 CSMACD 將封包送往 NICC。
(4) vm NICC 收到封包

VM -> Linux NAT server -> Outsider

(5) default gw 為 NICB 上的IP，往該處送。
(6) 接到後，prerouting chain 沒 match ，所以不做事。
(7) Destination 是外部 IP，往 default gw 送 (routing table 判斷)
(8) default gw 送出去前，postrouting 將 source 改成 public IP。
```

實作二：多個 private IP 透過單一 public IP 出去

說穿了，其實就是拿上面的第二條 rule 稍做修改，即可達成目標。

```bash
# 開啟封包轉送功能
echo 1 > /proc/sys/net/ipv4/ip_forward

# 在 postrouting chain 中，將來源是 192.168.0.0/24 的封包，修改封包來源位置為 10.3.34.148
iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to-destination 10.3.34.148
```

封包傳遞解說：

```bash

由於這類型 NAT，外部機器是無法主動連線進來內部的。因此，封包傳遞的過程只會有從內到外。換句話說，就是上面的(5)~(8)的流程。

VM -> Linux NAT server -> Outsider

(5) default gw 為 NICB 上的IP，往該處送。
(6) 接到後，prerouting chain 沒 match ，所以不做事。
(7) Destination 是外部 IP，往 default gw 送 (routing table 判斷)
(8) default gw 送出去前，postrouting 將 source 改成 public IP。
```

