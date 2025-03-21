#!/bin/bash

#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

#help
if [[ "$1" == "--help" ]]; then
  echo -e "${YELLOW}🧠 Ús del script Script_a.sh${RESET}"
  echo 
  echo "OPCIONS:"
  echo "  -no-upload           No carregar el .hex a l'Arduino (per defecte: si)"
  echo "  -picocom             Obrir el picocom (per defecte: no)"
  echo "  -baud <velocitat>    Baud rate pel picocom (per defecte 9600)"
  echo "  -clean               Neteja els fitxers temporals després de compilar"
  echo "  -port [PORT]         Defineix el port (per defecte: /dev/ttyACM0)"
  echo "  --help               Mostra aquest missatge d'ajuda"
  echo
  echo "EXEMPLE:"
  echo "  ./Script_a.sh -picocom -baud 19200 -clean -port /dev/ttyUSB0 NOM_DEL_FITXER"
  exit 0
fi

#variables per defecte
UPLOAD=false
PICOCOM=false
BAUD=9600
CLEAN=false
PORT="/dev/ttyACM0"
NOM=""
MODE_RAPID=true 

#analitzar flags
while [[ $# -gt 0 ]]; do 
  case $1 in 
    -no-upload)
      UPLOAD=false
      MODE_RAPID=false
      ;;
    -picocom)
      PICOCOM=true
      MODE_RAPID=false
      ;;
    -baud)
      shift
      BAUD=$1
      MODE_RAPID=false
      ;;
    -clean)
      CLEAN=true
      MODE_RAPID=false
      ;;
    -port)
      shift
      PORT=$1 
      MODE_RAPID=false
      ;;
    -*)
      echo -e "${RED}❌ Opció desconeguda: $1${RESET}"
      exit 1 
      ;;
    *)
      NOM=$1 
      MODE_RAPID=false
      ;;
  esac
  shift
done

rm -f log.txt

if [[ -z "$NOM" ]]; then
  echo -e "${YELLOW}📂 Fitxers disponibles (.s):${RESET}"
  lsd *.s 2>/dev/null || echo -e "${RED}❌ No s'ha trobat cap .s al directori actual.${RESET}"
  echo 
  read -p "Nom del fitxer?" NOM
fi 

#comprovació
if [[ ! -f "$NOM.s" ]]; then 
  echo -e "${RED}❌ No s'ha trobat cap fitxer .s al directori actual.${RESET}"
  exit 1 
fi 

#mode ràpid
if $MODE_RAPID; then 
  read -p "Carregar el codi a l'arduino? (Y/n): " res_upload 
  res_upload=$(echo "$res_upload" | tr '[:upper:]' '[:lower:]')
  [[ -z "$res_upload" || "$res_upload" == "y" ]] && UPLOAD=true 

  read -p "Vols obrir picocom? (N/y): " res_pico
  res_pico=$(echo "$res_pico" | tr '[:upper:]' '[:lower:]')
  if [[ "$res_pico" == "y" ]]; then
    PICOCOM=true
  fi 

  read -p "Port? (Per defecte: /dev/ttyACM0):" port_in
  [[ -n "$port_in" ]] && PORT=$port_in
  
  if $PICOCOM; then 
    read -p "Baud rate? (Per defecte: 9600):" baud_in
    [[ -n "$baud_in" ]] && BAUD=$baud_in
  fi 

  read -p "Clean? (N/y): " res_clean
  res_clean=$(echo "$res_clean" | tr '[:upper:]' '[:lower:]')
  if [[ -z "$res_clean" || "$res_clean" == "n" ]]; then 
    CLEAN=true
  fi
fi 

#compilació
echo -e "${YELLOW}🔧 Compilant $NOM.s...${RESET}"
avr-gcc -mmcu=atmega328p -o "$NOM.elf" "$NOM.s" >log.txt 2>&1 
if [[ $? -ne 0 ]]; then
  echo -e "${RED}❌ Error en la compilació${RESET}"
  exit 1 
fi 

#.hex
avr-objcopy -O ihex "$NOM.elf" "$NOM.hex" >> log.txt 2>&1 

echo -e "${GREEN}✅ Compilació correcta: $NOM.hex generat${RESET}"
echo "📜 Sortida desada a log.txt"

#pujar a l'Arduino
if $UPLOAD; then 
  echo -e "${YELLOW}🔌 Carregant a $PORT...${RESET}"
  avrdude -c arduino -P "$PORT" -p m328p -U flash:w:"$NOM.hex":i 
fi 

#picocom
if $PICOCOM; then
  echo -e "${YELLOW}🖧 Obrint picocom a $PORT amb baud $BAUD...${RESET}"
  picocom -b "$BAUD" "$PORT"
fi 

#clean
if $CLEAN; then
  echo -e "${YELLOW}🧽 Netejant fitxers temporals...${RESET}"
  rm -f "$NOM.elf" "$NOM.hex" log.txt 
fi 
