#!/bin/bash 

SECONDS=0

#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

#help
if [[ "$1" == "--help" ]]; then
  echo -e "${YELLOW}🧠 Ús del script Script_c.sh${RESET}"
  echo
  echo "OPCIONS:"
  echo "  -pc            Compila per a PC (executa directament)"
  echo "  -avr           Compila per Arduino (AVR)"
  echo "  -upload        Carrega el fitxer .hex a l'Arduino"
  echo "  -port [PORT]   Defineix el port (per defecte: /dev/ttyACM0)"
  echo "  -clean         Neteja fitxers temporals després de compilar"
  echo "  --help         Mostra aquest missatge d'ajuda"
  echo
  echo "EXEMPLES:"
  echo "  ./Script_c.sh -pc hola"
  echo "  ./Script_c.sh -avr semafor -upload -port /dev/ttyUSB0 -clean"
  exit 0
fi

#variables per defecte
usa_makefile=false
mode_rapid=false
upload=false
clean=false
port="/dev/ttyACM0"
compilar_per=""
NOM=""

#analitzar flags
while [[ $# -gt 0 ]]; do 
  case $1 in 
    -avr)
      compilar_per="avr"
      mode_rapid=true
      shift
      NOM=$1 
      ;;
    -pc)
      compilar_per="pc"
      mode_rapid=true
      shift
      NOM=$1 
      ;;
    -upload)
      upload=true
      mode_rapid=true
      ;;
    -clean)
      clean=true
      mode_rapid=true
      ;;
    -port)
      shift
      port=$1;;
    -*)
      echo -e "${RED}❌ Opció desconeguda: $1${RESET}"
      exit 1 
      ;;
    *)
      shift
      ;;
  esac
  shift
done

if ! $mode_rapid; then
  read -p "Nom del fitxer?" NOM
  if [[ ! -f "$NOM.c" ]]; then
    echo -e "${RED}❌ El fitxer $NOM.c no existeix.${RESET}"
    exit 1 
  fi 
  #compilació
  read -p "Vols compilar per AVR/Arduino? (Y/n): " es_avr 
  es_avr=$(echo $es_avr | tr '[:upper:]' '[:lower:]')

  if [ "-z" $es_avr ] || [[ "$es_avr" = "y" ]]; then 
    compilar_per="avr"
  else 
    compilar_per="pc"
  fi 
  #càrrega
  read -p "Vols carregar el .hex a l'Arduino (Y/n): " load
  load=$(echo $load | tr '[:upper:]' '[:lower:]')

  if [ "-z" $load ] || [[ "$load" = "y" ]]; then
    upload=true
    read -p "Port? (Per defecte: /dev/ttyACM0): " port_in 
    port=${port_in:-/dev/ttyACM0}
  fi 
  #neteja
  read -p "Make clean (Y/n): " clean
  clean=$(echo $clean | tr '[:upper:]' '[:lower:]')

  if [ "-z" $clean ] || [[ "$clean" = "y" ]]; then
    clean=true
  fi 
fi 

#comprovació de si existeix el fitxer
if [[ ! -f "$NOM.c" ]]; then 
  echo -e "${RED}❌ El fitxer $NOM.c no existeix.${RESET}"
  exit 1 
fi 

#comprovar si hi ha makefile 
if [[ -f "Makefile" || -f "makefile" ]]; then
  usa_makefile=true
fi 

#eliminar log anterior
rm -f log.txt

#compilació
if [[ "$compilar_per" == "avr" ]]; then 
  if $usa_makefile; then 
    echo -e "${YELLOW}🛠️ Makefile detectat. Executant make...${RESET}"
    make > log.txt 2>&1 
  else 
    MCU="atmega328p"
    F_CPU="16000000UL"
    echo -e "${YELLOW}🔧 Compilant per AVR ($MCU)...${RESET}"

    avr-gcc -mmcu=$MCU -DF_CPU=$F_CPU -Wall -Os -o "$NOM.elf" "$NOM.c" > log.txt 2>&1
  
    if [[ $? -ne 0 ]]; then
      echo -e "${RED}❌ Error de compilació AVR.${RESET}"
      exit 1 
    fi 

    avr-objcopy -O ihex -R .eeprom "$NOM.elf" "$NOM.hex" >> log.txt 2>&1
    echo -e "${GREEN}✅ Compilació correcte. Fitxer .hex generat: $NOM.hex${RESET}"
    echo "📜 Sortida desada a log.txt"

    #generar informe
    temps_total=$SECONDS
    INFORME="informe_${NOM}.txt"
    echo >> "$INFORME"
    echo "📄 Fitxer: $NOM.c" >> "$INFORME"
    echo "📦 Tipus: Compilació per $compilar_per" >> "$INFORME"
    echo "📅 Hora de la compilació: $(date '+%Y-%m-%d %H:%M:%S')" >> "$INFORME"
    echo "Temps de compilació: $(temps_total)s" >> "$INFORME"
    echo >> "$INFORME"
    echo "✅ Compilació correcte" >> "$INFORME"
    echo "📂 Fitxers generats:" >> "$INFORME"
    [[ -f "$NOM.elf" ]] && echo " - $NOM.elf" >> "$INFORME"
    [[ -f "$NOM.hex" ]] && echo " - $NOM.hex" >> "$INFORME"
    [[ -f "log.txt" ]] && echo " - log.txt" >> "$INFORME"
    echo >> "$INFORME"
    echo "🧑‍💻 Usuari: $(whoami)@$(hostname)" >> "$INFORME"
    echo >> "$INFORME"
    echo "🛠️ Versió de avr-gcc:" >> "$INFORME"
    avr-gcc --version | head -n 1 >> "$INFORME"
    echo >> "$INFORME"
    echo -e "${GREEN} Informe generat: $INFORME${RESET}"
  fi 

  if $upload; then 
    echo -e "${YELLOW}🔌 Carregant a $port...${RESET}"
    avrdude -v -patmega328p -carduino -P"$port" -b115200 -D -Uflash:w:"$NOM.hex":i
  fi 

elif [[ "$compilar_per" == "pc" ]]; then
  if $usa_makefile; then 
    echo -e "${YELLOW}🛠️ Makefile detectat. Executant make...${RESET}"
    make > log.txt 2>&1 
  else 
    echo -e "${YELLOW}🔧 Compilant per PC...${RESET}"
    gcc -Wall -o "$NOM" "$NOM.c" > log.txt 2>&1
    if [[ $? -ne 0 ]]; then 
      echo -e "${RED}❌ Error de compilació. Consulta el log.txt${RESET}"
      exit 1 
    fi 
    echo -e "${GREEN}✅ Executant...${RESET}"
    echo "📜 Sortida desada a log.txt"
    echo -e "${YELLOW}Executant $NOM...${RESET}"
    ./"$NOM"
    #generar informe
    temps_total=$SECONDS
    INFORME="informe_${NOM}.txt"
    echo >> "$INFORME"
    echo "📄 Fitxer: $NOM.c" >> "$INFORME"
    echo "📦 Tipus: Compilació per $compilar_per" >> "$INFORME"
    echo "📅 Hora de la compilació: $(date '+%Y-%m-%d %H:%M:%S')" >> "$INFORME"
    echo "Temps de compilació: $(temps_total)s" >> "$INFORME"
    echo >> "$INFORME"
    echo "✅ Compilació correcte" >> "$INFORME"
    echo "📂 Fitxers generats:" >> "$INFORME"
    [[ -f "$NOM.elf" ]] && echo " - $NOM.elf" >> "$INFORME"
    [[ -f "$NOM.hex" ]] && echo " - $NOM.hex" >> "$INFORME"
    [[ -f "log.txt" ]] && echo " - log.txt" >> "$INFORME"
    echo >> "$INFORME"
    echo "🧑‍💻 Usuari: $(whoami)@$(hostname)" >> "$INFORME"
    echo >> "$INFORME"
    echo "🛠️ Versió de gcc:" >> "$INFORME"
    gcc --version | head -n 1 >> "$INFORME"
    echo >> "$INFORME"
    echo -e "${GREEN} Informe generat: $INFORME${RESET}"

  fi 
else
  echo -e "${RED}❌ No s'ha especificat si és compilació per PC o AVR.${RESET}"
  exit 1 
fi 

#neteja
if $clean; then 
  if $usa_makefile; then 
    echo -e "${YELLOW}🧽 Fent make clean...${RESET}"
    make clean
  else 
    echo -e "${YELLOW}🧽 Esborrant fitxers brossa...${RESET}"
    rm -f *.elf *.hex *.o *.out log.txt
  fi 
fi
