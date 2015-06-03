## SSH tricks

讓遠端機器視窗的資料透過 ssh 通道來傳送

```
# /etc/ssh/sshd_config 設定 X11Forwarding 為 yes
X11Forwarding yes

# 讓遠端機器視窗的資料透過 ssh 通道來傳送
$ ssh -X username@remote_server

# 登入後，輸入 firefox，即可使用遠端機器的 firefox 來瀏覽網頁
$ firefox

# 透過跳板傳送遠端機器視窗資料
$ ssh -L [localPort]:target_server:22 root@stepping_stone
$ ssh -X -p [localPort] root@127.0.0.1
```

透過 SSH Proxy 瀏覽網頁

```
# 將遠端機器當作 Proxy。
# request 送到 localhost 1080 port，即會透過 remote_server 出去。
$ ssh -D 1080 username@remote_server

# iceweasel 設定
Preferences > Advanced > Network > Settings > SOCKS Host v5, Remote DNS
about:config > network.proxy.socks_remote_dns true
```
SSH VPN Tunnel

```
# local tun: remote tun
serverA $ ssh -w 0:0 serverB

# on serverB
PermitRootLogin yes
PermitTunnel yes

# on serverA & B
ip addr show tun0

# on serverA
ip link set tun0 up
ip addr add 192.168.0.1/24 peer 192.168.0.2 dev tun0

# on serverB
ip link set tun0 up
ip addr add 192.168.0.2/24 peer 192.168.0.1 dev tun0
```
