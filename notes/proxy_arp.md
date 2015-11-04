## Proxy ARP 研究

經文獻閱讀與整理，初步發現 Proxy ARP 有下列三種情境，以下將針對個情境 Proxy ARP 運作過程逐一列出：

### 鳥哥 - 路由器兩邊界面是同一個 IP 網段

```
1. PC1 ping PC2
2. 經子網路遮罩計算，判定為同一子網路下。因此發送 ARP request 封包，以取得 PC2 的 MAC Address。
3. Router 聽到 ARP request 後，便會跟 PC1 說：「我是 PC2，PC2 是我」，並回傳 Router eth0 的 MAC Address 給 PC1。
4. PC1 接到 Router 回應之 ARP reply 後，更新 PC1 中 ARP table。將 PC2 的 MAC 內容實際填寫 Router 的 MAC。
5. PC1 透過 MAC Address 發送 icmp 給 PC2。
6. icmp 實際上是先送給 Router，再由 Router 轉送給 PC2。
```
 [細節請參考文獻] [1]

### CISCO - B CLASS to C CLASS

```
1. Host A ping Host D
2. 經子網路遮罩計算，判定為同一子網路下。因此發送 ARP request 封包，以取得 PC2 的 MAC Address。
3. Router 聽到 ARP request 後，便會跟 Host A 說：「我是 Host D，Host D是我」，並回傳 Router e0 的 MAC Address 給 Host A。
4. Host A 接到 Router 回應之 ARP reply 後，更新 Host A 中 ARP table。將 Host D 的 MAC 內容實際填寫 Router 的 MAC。
5. Host A 透過 MAC Address 發送 icmp 給 Host D。
6. icmp 實際上是先送給 Router，再由 Router 轉送給 Host D。
```

```
1. Host D ping Host A
2. 經子網路遮罩計算，判定為不同子網路下。因此，Host D 將會查看 Routing table，看須使用哪一條 rule 才能抵達目的地。
3. Host D 發送 ARP request 詢問 default gw 的 MAC Address。
4. default gw 回傳 MAC Address 給 Host D。
5. Host D 將 icmp 透過 default gw 轉送給 Host A。
```

 [細節請參考文獻] [2]

### GNS3 - 2 different subnets

```
1. R1 ping R3
2. 因中間流程文件上沒有探討，所以目前尚不知道細節。
3. icmp 實際上是先送給 Router，再由 Router 轉送給 R3。
```

 [細節請參考文獻] [3]


### 實驗 - 期望實作出 GNS3 - 2 different subnets 情境

#### 網路設定 - Host Machine
```
# 注意到 vboxnet0 的 MAC Address 是 0a:00:27:00:00:00

$ ifconfig
eth0      Link encap:Ethernet  HWaddr 00:0f:fe:e1:73:25
          inet addr:10.3.34.148  Bcast:10.3.255.255  Mask:255.255.0.0
          inet6 addr: fe80::20f:feff:fee1:7325/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:179846 errors:0 dropped:20 overruns:0 frame:0
          TX packets:39032 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:43903246 (43.9 MB)  TX bytes:5967752 (5.9 MB)
          Interrupt:19 Memory:f0000000-f0020000

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:145 errors:0 dropped:0 overruns:0 frame:0
          TX packets:145 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:10225 (10.2 KB)  TX bytes:10225 (10.2 KB)

vboxnet0  Link encap:Ethernet  HWaddr 0a:00:27:00:00:00
          inet addr:10.254.254.1  Bcast:10.254.254.255  Mask:255.255.255.0
          inet6 addr: fe80::800:27ff:fe00:0/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:233 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:33215 (33.2 KB)


# 打開封包轉送功能，並設定讓 vboxnet0 介面收到的流量，通通轉給 eth0 介面，由 eth0 代理對外溝通。

$ echo 1 > /proc/sys/net/ipv4/ip_forward
$ iptables -A FORWARD -i vboxnet0 -o eth0 -j ACCEPT
$ iptables -A FORWARD -i vboxnet0 -o eth0 -m state --state $ ESTABLISHED,RELATED -j ACCEPT
$ iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

#### 網路設定 - Guest Machine

```
# 請注意 Guest Machine 的 default gateway 就是自己。

$ ifconfig
eth0      Link encap:Ethernet  HWaddr 08:00:27:88:0c:a6
          inet addr:10.254.254.101  Bcast:10.254.254.255  Mask:255.255.255.0
          inet6 addr: fe80::a00:27ff:fe88:ca6/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:112 errors:0 dropped:0 overruns:0 frame:0
          TX packets:309 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:19299 (19.2 KB)  TX bytes:29857 (29.8 KB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:1245 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1245 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:101252 (101.2 KB)  TX bytes:101252 (101.2 KB)


$ route -n
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         10.254.254.101  0.0.0.0         UG    100    0        0 eth0
10.254.254.0    0.0.0.0         255.255.255.0   U     0      0        0 eth0
```

#### Host Machine 設定畫面
![host_settings.png](./images/host_settings.png)


#### 在 Guest Machine 上 ping 8.8.8.8
![guest_ping_g.png](./images/guest_ping_g.png)

#### Wireshark 聽到的結果
仔細看，Host Machine vboxnet0 (0a:00:27:00:00:00) 回應 Guest Machine (CadmusCo_88:0c:a6) 說：「8.8.8.8 就是我拉。」

![wireshark_arp.png](./images/wireshark_arp.png)

#### 依據實驗結果，推測 ping 流程
```
1. Guest Machine ping 8.8.8.8
2. 中間應該還有一段流程，但目前尚未理解透徹。
3. Guest Machine 發出 ARP request 詢問 8.8.8.8 的 MAC Address。
4. Host Machine 回應 ARP reply 告知 Guest Machine 它就是 8.8.8.8，並回傳 Host Machine vboxnet0 MAC Address 給 Guest Machine。
5. icmp 實際上是先送給 Host Machine，再由 Host Machine 轉送給 8.8.8.8。
```

[1]: http://linux.vbird.org/linux_server/0230router.php#arp_proxy
[2]: http://www.cisco.com/c/en/us/support/docs/ip/dynamic-address-allocation-resolution/13718-5.html
[3]: https://ccieblog.co.uk/arp/proxy-arp
[4]: http://www.sjdjweis.com/linux/proxyarp/
