#! /usr/bin/env sh
#================================================================
# VPS INFO & LOGS
#
# AUTHOR      : Ricardo S.
# GITHUB      : https://github.com/ricjcs/vps-info-logs
# DESCRIPTION : Script to view information and logs from a VPS.
#================================================================

prgname="VPS INFO & LOGS"
version="1.0"

#################################################################
#   FUNCTIONS                                    ################
#################################################################

check_root()
{
    if [[ ! $(whoami) = "root" ]]; then 
        echo "OOPS! YOU HAVE TO RUN THE SCRIPT AS ROOT."
        exit 1
    fi
}

###############
### SYSTEM ###
###############

sys_info()
{
    clear
    # Chamada da bibliotaca de variáveis para
    # saber as informações do sistema.
    . /etc/os-release

    totalPackages=$(dpkg-query -f '${binary:Package}\n' -W | wc -l)

    echo "---------------------------------------------------"
    echo "  SYSTEM INFORMATION"
    echo "---------------------------------------------------"
    echo "  Distribution : $NAME"
    echo "  Version : $VERSION_ID"
    echo "  Codename : $VERSION_CODENAME"
    echo "  Kernel : $(uname -r)"
    echo "  Uptime : $(uptime -p)"
    echo "  Total Package : $totalPackages packages"
    printf "  Date and Time : "
    date
}

who_is_online() 
{
    clear
    echo "---------------------------------------------------"
    echo "  Who is online?"
    echo "---------------------------------------------------"
    who -H
}

last_logged_users()
{
    clear
    echo "---------------------------------------------------"
    echo "  List of last logged users!"
    echo "---------------------------------------------------"
    last
}

log_size()
{
    clear
    echo "---------------------------------------------------"
    echo "  Sizes of: /var/log/"
    echo "---------------------------------------------------"
    du -h /var/log/* | sort -h
    echo "---------------------------------------------------"
    echo "  TOP 10"
    echo "---------------------------------------------------"
    du -h /var/log/* | sort -rh | head -n 10
    echo "---------------------------------------------------"
    printf " TOTAL: "
    du -hs /var/log/
    echo "---------------------------------------------------"
}

services_status()
{
    clear
    echo "---------------------------------------------------"
    printf "\e[37;45m SSH STATUS              \e[m\n"          
    echo "---------------------------------------------------"
    systemctl status ssh                   
    echo "---------------------------------------------------"
    printf "\e[37;45m APACHE STATUS           \e[m\n"
    echo "---------------------------------------------------"
    systemctl status apache2 --no-pager
    echo "---------------------------------------------------"
    printf "\e[37;45m MARIADB STATUS          \e[m\n"
    echo "---------------------------------------------------"
    systemctl status mariadb
    echo "---------------------------------------------------"
    printf "\e[37;45m RSYSLOG STATUS          \e[m\n"
    echo "---------------------------------------------------"
    systemctl status rsyslog --no-pager
    echo "---------------------------------------------------"
    printf "\e[37;45m FAIL2BAN STATUS         \e[m\n"
    echo "---------------------------------------------------"
    systemctl status fail2ban
    echo "---------------------------------------------------"
    printf "\e[37;45m UFW SATATUS             \e[m\n"
    echo "---------------------------------------------------"
    ufw status
    echo "---------------------------------------------------"
}

disk_space()
{
    clear
    echo "---------------------------------------------------"
    echo "  Disk Space"
    echo "---------------------------------------------------"
    df -h
}

update_system()
{
    clear
    echo "---------------------------------------------------"
    echo "  Update System"
    echo "---------------------------------------------------"
    apt update
    apt upgrade
}

clear_system()
{
    clear
    echo "---------------------------------------------------"
    echo "  Clear System"
    echo "---------------------------------------------------"
    apt clean
    apt autoremove
}

#################
### SECURITY ###
#################

open_ports()
{
    clear
    echo "---------------------------------------------------"
    echo "  Open Ports"
    echo "---------------------------------------------------"
    netstat -tulpn | grep LISTEN
}

ufw_active_rules()
{
    clear
    echo "---------------------------------------------------"
    echo "  Active rules in UFW"
    echo "---------------------------------------------------"
    ufw status
}

#################
### VIEW LOGS ###
#################

unattended_upgrades_log()
{
    clear
    echo "---------------------------------------------------"
    echo "  Unattended Upgrades Log"
    echo "---------------------------------------------------"
    cat /var/log/unattended-upgrades/unattended-upgrades.log   
}

system_authentication_log()
{
    clear
    echo "---------------------------------------------------"
    echo "  System Authentication Log"
    echo "---------------------------------------------------"
    cat /var/log/auth.log
}

fail2ban_log()
{
    clear
    echo "---------------------------------------------------"
    echo "  Fail2ban Log"
    echo "---------------------------------------------------"
    echo "  Select Option:"
    echo "  1. General log"
    echo "  2. Filter by date"
    printf "  Choise: "
    read fb_op
    case $fb_op in
        1) 
            echo "---------------------------------------------------"
            cat /var/log/fail2ban.log ;;
        2)
            echo "  What date do you want to filter? (Formar: ^yyyy-mm-dd)"
            printf "  "
            read fb_filter_date
            echo "---------------------------------------------------"
            grep $fb_filter_date /var/log/fail2ban.log
    esac  
}

apache_access_log()
{
    clear
    echo "---------------------------------------------------"
    echo "  Apache Access Log"
    echo "---------------------------------------------------"
    cat /var/log/apache2/access.log
}

logwatch_report()
{
    clear
    echo "---------------------------------------------------"
    echo "  Send Logwatch Report"
    echo "---------------------------------------------------"
    echo "  What is your local mail?"
    printf "  "
    read localmail
    logwatch --detail Hight --mailto $localmail --range today
    echo "  Report sent to $localmail"

}

live_traffic()
{
    clear
    echo "---------------------------------------------------"
    echo "  Live Traffic"
    echo "---------------------------------------------------"
    
    #echo "[Apache Acess]"
    #tail -f /var/log/apache2/access.log
    
    echo "[Fail2ban]"
    tail -f /var/log/fail2ban.log    
}

# # #
pause()
{
    printf "\e[1;91m\n  <ENTER TO CONTINUE> \e[m\n"
    read go
}

#################################################################
#   START / MENU                               #################
#################################################################
check_root
while true; do
    clear
    echo "---------------------------------------------------"
    printf "\e[37;44m $prgname - $version \e[m\n"
    echo "---------------------------------------------------"
    printf "\e[1;96m SYSTEM \e[m\n"
    echo " 1. Operating System info"
    echo " 2. Who is online?"
    echo " 3. Last Logged in users"
    echo " 4. Sizes (/var/log)"
    echo " 5. Services Status"
    echo " 6. Disk Space"
    echo " 7. Update System"
    echo " 8. Clear System"
    printf "\e[1;96m SECURITY \e[m\n"
    echo " 9. Show open ports"
    echo " 10. Active rules in UFW"
    printf "\e[1;96m VIEW LOGS \e[m\n"
    echo " 11. Unattended Upgrades Log"
    echo " 12. System Authentication Log"
    echo " 13. Fail2ban Log"
    echo " 14. Apache Access Log"
    echo " 15. Send Logwatch Report"
    echo " 16. Live Traffic"
    echo "---------------------------------------------------"
    printf "\e[1;91m E. Exit    \e[1;93m A. About \e[m\n"
    echo "---------------------------------------------------"
    printf " Choise: "
    read menuOP

    case $menuOP in
        # System
        1) sys_info ;;
        2) who_is_online ;;
        3) last_logged_users ;;
        4) log_size ;;
        5) services_status ;;
        6) disk_space ;;
        7) update_system ;;
        8) clear_system ;;
        # Security
        9) open_ports ;;
        10) ufw_active_rules ;;
        # View Logs
        11) unattended_upgrades_log ;;
        12) system_authentication_log ;;
        13) fail2ban_log ;;
        14) apache_access_log ;;
        15) logwatch_report ;;
        16) live_traffic ;;
        ###
        E|e) echo; echo " See you later!"; echo; exit 0 ;;
        A|a) echo "
        Script to view information and logs from a VPS.
        GITHUB: https://github.com/ricjcs/vps-info-logs
        AUTHOR: Ricardo S.
        " ;;
        *) echo " Oops! You didn't type it correctly." ;;
    esac
    pause
done
