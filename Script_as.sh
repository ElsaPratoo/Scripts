#!/bin/bash 

echo "Nom de l'arxiu? "
read -r Nom

if avr-gcc -mmcu=atmega328p -o "${Nom}.elf" "${Nom}.s" && avr-objcopy --output-target=ihex "${Nom}.elf" "${Nom}.hex" && avrdude -c arduino -P /dev/ttyAMC0 -p m328p -U flash:w:"${Nom}.hex":i

then
  echo 'Picocom [N/y]?'
  read -r c 

  c=$(echo "$c" | tr '[:upper:]' '[:lower:]')

  if [ -z "$c" ] || [[ "$c" = 'n' ]]; then
    echo "No s'ha obert Picocom"

  elif [[ "$c" = 'y' ]]; then
    picocom -b9600 /dev/ttyAMC0

  else 
    echo "Entrada incorrecte"
  fi 

else
  echo "Hi ha hagut un error en el procés"
fi 
