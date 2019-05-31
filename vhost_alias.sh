#!/bin/bash

unset option menu ERROR      # prevent inheriting values from the shell
declare -a menu              # create an array called $menu
menu[0]=""                   # set and ignore index zero so we can count from 1

/usr/sbin/apache2ctl -S 2>&1 | awk '/namevhost/  {print $4;} ' > /tmp/vhost_arr.txt
#echo "$(/usr/sbin/apache2ctl -S 2>&1 | awk '/namevhost/  {print $4;} )'" > /tmp/vhost_arr.txt

# read menu file line-by-line, save as $line
while IFS= read -r line; do
  menu[${#menu[@]}]="$line"  # push $line onto $menu[]
done < /tmp/vhost_arr.txt

# function to show the menu
menu() {
  echo "Please select an option by typing in the corresponding number"
  echo ""
  for (( i=1; i<${#menu[@]}; i++ )); do
    echo "$i) ${menu[$i]}"
  done
  echo ""
}

# initial menu
menu
read option

# loop until given a number with an associated menu item
while ! [ "$option" -gt 0 ] 2>/dev/null || [ -z "${menu[$option]}" ]; do
  echo "No such option '$option'" >&2  # output this to standard error
  menu
  read option
done

#echo "You said '$option' which is '${menu[$option]}'"
cat /${menu[$option]}
echo -n "Type your new domain name: "; read newdomainname
sed "s/ServerAlias.*/& $newdomainname/" -i /etc/apache2/sites-available/${menu[$option]}.conf
a2dissite ${menu[$option]}
a2ensite ${menu[$option]}
certbot --apache --register-unsafely-without-email;
echo -e $"Complete!\nYou just add new alias  $newdomainname to ${menu[$option]}'s virtual host config"
exit 0;
