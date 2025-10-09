#!/bin/bash

service vsftpd start

if ! id "${FTP_USR}" &>/dev/null; then
    adduser $FTP_USR --disabled-password
    echo "$FTP_USR:$FTP_PWD" | /usr/sbin/chpasswd
    echo "$FTP_USR" | tee -a /etc/vsftpd.userlist
    mkdir -p /var/www/html/
    chown -R $FTP_USR:$FTP_USR /var/www/html/
    chmod 755 /var/www/html/
fi

sed -i -r "s/listen=NO/listen=YES/1"   /etc/vsftpd.conf
sed -i -r "s/listen_ipv6=YES/listen_ipv6=NO/1"   /etc/vsftpd.conf
sed -i -r "s/#write_enable=YES/write_enable=YES/1"   /etc/vsftpd.conf
sed -i -r "s/#chroot_local_user=YES/chroot_local_user=YES/1"   /etc/vsftpd.conf
echo "
local_enable=YES
listen_port=21
allow_writeable_chroot=YES
pasv_enable=YES
local_root=/var/www/html/
pasv_min_port=21100
pasv_max_port=21110
userlist_file=/etc/vsftpd.userlist" >> /etc/vsftpd.conf

vsftpd /etc/vsftpd.conf

service vsftpd stop


exec "$@"