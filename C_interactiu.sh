#!/bin/bash 

read -p "Nom de l'arxiu?" NOM

executable="program_exec"

if [[ ! -f "$NOM.c" ]]; then
  echo "❌ El fitxer $NOM.c no existeix."
  exit 1
fi 

#detectar si hi ha un makefile
if [[ -f "Makefile" || -f "makefile" ]]; then 
  usa_makefile=true
else 
  usa_makefile=false
fi 

read -p "Vols compilar per AVR/Arduino? (Y/n): " es_avr 
es_avr=$(echo $es_avr | tr '[:upper:]' '[:lower:]')

if [ "-z" $es_avr ] || [[ "$es_avr" = "y" ]]; then 
  #compilacio per AVR
  if $usa_makefile; then
    echo "🛠️ Makefile detectat! Compilant amb make..."
    make 
  else 
    MCU="atmega328p"
    F_CPU="16000000UL"
    echo "🔧 Compilant per AVR ($MCU)..."

    avr-gcc -mmcu=$MCU -DF_CPU=$F_CPU -Wall -Os "$NOM.elf" "$NOM.c"
  
    if [[ $? -ne 0 ]]; then
      echo "❌ Error de compilació AVR."
      exit 1 
    fi 

    avr-objcopy -O ihex -R .eeprom "$NOM.elf" "$NOM.hex"
    echo "✅ Compilació correcta! Fitxer .hex generat: $NOM.hex"
  fi 

  #demanar carrega a l'Arduino
  read -p "Vols carregar el .hex a l'Arduino (Y/n): " load
  load=$(echo $load | tr '[:upper:]' '[:lower:]')

  if [ "-z" $load ] || [[ "$load" = "y" ]]; then 
    read -p "Introdueix el port de l'Arduno. (Per defecte-->/dev/ttyACM0): " port 
    port=${port:~/dev/ttyACM0}
    echo "🔌 Carregant a $port..."
    avrdude -v -patmega328p -carduino -P"$port" -b115200 -D -Uflash:w:"$NOM.hex":i 
  fi 

else 
  if $usa_makefile; then 
    echo "🛠️ Makefile detectat! Compilant amb make..."
    make 
  else 
    echo "🔧 Compilant per PC..."
    gcc "${Nom}.c" -o "${executable}"
    if [[ $? -ne 0 ]]; then 
      echo "❌ Error de compilació."
      exit 1 
    fi 
    echo "✅ Executant..."
    ./"$NOM"
  fi 
fi 

#neteja?
read -p "Make clean (Y/n): " clean
clean=$(echo $clean | tr '[:upper:]' '[:lower:]')

if [ "-z" $clean ] || [[ "$clean" = "y" ]]; then
  if $usa_makefile; then 
    echo "🧹 Fent make clean..."
    make clean 
  else 
    echo "🧹 Eliminant fitxers temporals (manualment)..."
    rm -f *.elf *.hex *.o *.out program_exec 
    echo "✅ Neteja completada."
  fi 
fi 
