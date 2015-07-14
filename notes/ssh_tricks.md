## SSH TCP Port Forwarding (SSH tunneling)

許多情況下，我們可能會因防火牆阻擋，導致無法與遠端主機的某個 port 連接。以下，將介紹幾種利用 SSH TCP Port Forwarding 方式建立通道，將連線，透過該通道傳送到 targets。

```
SSH 參數說明

-L: Local Port Forwarding.  本地機器連到遠端機器。
-N: 不執行 ssh command, 加了這個參數後，
    畫面就不會進入 tty(Terminal) 模式，
    tty 模式是指登入 ssh server，並且可以輸入 linux 指令。
    若我們沒有進入 tty, 畫面就會卡在程式執行中的狀態，
    如此只要按 ctrl +c 就可以執行中斷程式。
-f: 在背景執行。
-R: Remote Port Forwarding. 遠端機器連回本地機器。

備註：完全引用 Puritys 之說明。
```


## 情境一：與遠端主機建立 SSH 通道
```
情境：從 Local Server A 連線到 Remote Server 的 80 port。
問題：中間有防火牆組擋 80 port 連線。SSH 無阻擋。
```
TCP Forwarding 示意圖

```
                                         Firewall

                                            +-+
           Local Server A                   | |                  Remote Server
+-----------------------------------+       | |      +-----------------------------------+
|                                   |       | |      |                                   |
|                                   |       | |      |                                   |
+-------+------+-----+------+-------+       | |      +-------+------+-----+------+-------+
        |p:8080|     |p:3333+------------------------------> |p:22  |     |p:80  |
        +---+--+     +--+---+               | |              +---+--+     +--+---+
            |           ^                   | |                  |           ^
            |           |                   | |                  |           |
            +-----------+                   | |                  +-----------+
                                            | |
                                            +-+

                 Lets assume any connection targets port 80 will be dropped.
```

解決：透過 SSH TCP Forwadring 轉送。

```bash
# 建立 TCP Forwarding 通道
# 當使用者連線到 Local Server 8080 port 時，requests 就會被自動導到 Remote Server 80 port。

root@localserverA $ ssh -L 8080:localhost:80 root@remote_server
```

參數說明

```
-L:	Local Port Forwarding.  本地機器連到遠端機器。

8080 port:
  	開在 Local Server A 上。
	會將連至該 port 之連線，透過 3333 port 轉送給 Remote Server 的 22 port。
	ps. 3333 port 為此案例中舉例，真實 port 數字是由 openssh 選定。

localhost: 就是 Remote Server 本身。

80 port:
	開在 Remote Server 上。
	會將 22 port 接收到的封包，轉送給本機端 80 port。
```





## 情境二：以遠端主機為跳板建立 SSH 通道
```
情境：從 Local Server A 連線到 Remote Server B 的 80 port。
問題：中間有防火牆組擋 80 port 連線。SSH 無阻擋。
```

TCP Forwarding 示意圖

```
                                         Firewall

                                            +-+
           Local Server A                   | |                  Remote Server A
+-----------------------------------+       | |      +-----------------------------------+
|                                   |       | |      |                                   |
|                                   |       | |      |                                   |
+-------+------+-----+------+-------+       | |      +-------+------+--------------------+
        |p:8080|     |p:3333+------------------------------> |p:22  |
        +---+--+     +--+---+               | |              +---+--+
            |           ^                   | |                  |
            |           |                   | |                  |
            +-----------+                   | |                  v
                                            | |              +------+
                                            +-+              |p:80  |
                                                     +-------+------+--------------------+
                                                     |                                   |
                                                     |                                   |
                                                     +-----------------------------------+
															     Remote Server B
```


解決：透過 SSH TCP Forwadring 轉送。

```bash
# 建立 TCP Forwarding 通道
# 當使用者連線到 Local Server 8080 port 時，
# 中間會透過 Remote Server A 將 requests 自動導到 Remote Server B 的 80 port。

root@localserverA $ ssh -L 8080:remote_serverB:80 root@remote_serverA
```
參數說明

```
-L:	Local Port Forwarding.  本地機器連到遠端機器。

8080 port:
	開在 Local Server A 上。
	會將連至該 port 之連線，透過 3333 port 轉送給 Remote Server 的 22 port。
	ps. 3333 port 為此案例中舉例，真實 port 數字是由 openssh 選定。

80 port:
	開在 Remote Server B 上。
	會將 Remote Server A 22 port 接收到的封包，轉送給 Remote Server B 的80 port。
```


## 情境三：情境一之反向 SSH 通道
```
情境：從 Remote Server 連線到 Local Server 的 80 port。
問題：中間有防火牆組擋 80 port 連線。SSH 無阻擋。
```
TCP Forwarding 示意圖

```
                                         Firewall

                                            +-+
           Local Server A                   | |                  Remote Server
+-----------------------------------+       | |      +-----------------------------------+
|                                   |       | |      |                                   |
|                                   |       | |      |                                   |
+-------+------+-----+------+-------+       | |      +-------+------+-----+------+-------+
        |p:80  |     |p:22  | <------------------------------+p:3333|     |p:8080|
        +---+--+     +--+---+               | |              +---+--+     +--+---+
            ^           |                   | |                  ^           |
            |           |                   | |                  |           |
            +-----------+                   | |                  +-----------+
                                            | |
                                            +-+
```

解決：透過 SSH TCP Forwadring 轉送。

```bash
# 建立 TCP Forwarding 通道
# 當使用者連線到 Remote Server 8080 port 時，requests 就會被自動導到 Local Server 80 port。

root@localserverA $ ssh -NfR 8080:localhost:80 root@remote_server
```

參數說明

```
-N: 不執行 ssh command, 加了這個參數後，
    畫面就不會進入 tty(Terminal) 模式，
    tty 模式是指登入 ssh server，並且可以輸入 linux 指令。
    若我們沒有進入 tty, 畫面就會卡在程式執行中的狀態，
    如此只要按 ctrl +c 就可以執行中斷程式。

-f: 在背景執行。

-R: Remote Port Forwarding. 遠端機器連回本地機器。

8080 port:
	開在 Remote Server 上。
	會將連至該 port 之連線，透過 3333 port 轉送給 Remote Server 的 22 port。
	ps. 3333 port 為此案例中舉例，真實 port 數字是由 openssh 選定。

localhost: 就是 Local Server A 本身。

80 port:
	開在 Local Server 上。
	會將 22 port 接收到的封包，轉送給本機端 80 port。
```

## 情境四：情境二之反向 SSH 通道

```
情境：從 Remote Server A 連線到 Local Server B 的 80 port。
問題：中間有防火牆組擋 80 port 連線。SSH 無阻擋。
```
TCP Forwarding 示意圖

```
                                         Firewall

                                            +-+
           Local Server A                   | |                  Remote Server A
+-----------------------------------+       | |      +-----------------------------------+
|                                   |       | |      |                                   |
|                                   |       | |      |                                   |
+--------------------+------+-------+       | |      +-------+------+-----+------+-------+
                     |p:22  + <------------------------------|p:3333|     |p:8080|
                     +--+---+               | |              +---+--+     +--+---+
                        |                   | |                  ^           |
                        |                   | |                  |           |
                        |                   | |                  +-----------+
                        v                   | |
                     +------+               +-+
                     |p:80  |
 +-------------------+------+--------+
 |                                   |
 |                                   |
 +-----------------------------------+
           Local Server B
```
解決：透過 SSH TCP Forwadring 轉送。

```bash
# 建立 TCP Forwarding 通道
# 當使用者連線到 Remote Server 8080 port 時，
# 中間會透過 Local Server A 將 requests 自動導到 Local Server B 的 80 port。

root@localserverA $ ssh -NfR 8080:local_serverB:80 root@remote_serverA
```
參數說明

```
-N: 不執行 ssh command, 加了這個參數後，
    畫面就不會進入 tty(Terminal) 模式，
    tty 模式是指登入 ssh server，並且可以輸入 linux 指令。
    若我們沒有進入 tty, 畫面就會卡在程式執行中的狀態，
    如此只要按 ctrl +c 就可以執行中斷程式。

-f: 在背景執行。

-R: Remote Port Forwarding. 遠端機器連回本地機器。

8080 port:
	開在 Remote Server A 上。
	會將連至該 port 之連線，透過 3333 port 轉送給 Local Server 的 22 port。
	ps. 3333 port 為此案例中舉例，真實 port 數字是由 openssh 選定。

80 port:
	開在 Local Server B 上。
	會將 Local Server A 22 port 接收到的封包，轉送給 Local Server B 的80 port。
```


參考文獻：

	1. http://portable.easylife.tw/2043
	2. http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man1/slogin.1?query=ssh&sec=1
	3. http://fred-zone.blogspot.tw/2011/09/ssh-tunnel-vpn.html
	4. http://www.puritys.me/docs-blog/article-186-SSH-Tunnel.html

TODO：

- X FORWARDING
- SSH TUNNEL VPN
