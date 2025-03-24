#!/bin/bash

#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

INPUT="$1"
BASENAME=$(basename "$INPUT" .doc)
BASENAME=$(basename "$BASENAME" .docx)
OUTPUT="${BASENAME}.pdf"

if [ ! -f "$INPUT" ]; then
  echo -e "${RED}Error: no s'ha trobat el fitxer '$INPUT'${RESET}"
  exit 1
fi 

if command -v soffice >/dev/null 2>&1; then
  echo "${YELLOW}Convertitn a pdf mitjançant LibreOffice${RESET}"
  soffice --headless --convert-to pdf "$INPUT"
else
  echo "${RED}Libreoffice no ha sigut capaç de convertir el fitxer a pdf. Altres eines per fer-ho poden ser: unoconv o pandoc${RESET}"
  exit 1
fi 

echo "${GREEN}Fitxer en PDF:${RESET} ${OUTPUT}"

