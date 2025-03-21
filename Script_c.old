#!/bin/bash

echo "Nom de l'arxiu? "
read -r Nom

executable="program_exec"

if gcc "${Nom}.c" -o "${executable}"

then
  echo "Compilació exitosa, desitja executar el programa [N/y]? "
  read -r c 

  c=$(echo $c | tr '[:upper:]' '[:lower:]')

  if [ -z "$c" ] || [[ "$c" = 'n' ]]; then
    echo "No s'ha executat el programa"

  elif [[ "$c" = 'y' ]]; then
    ./${executable}

  else
    echo "Enrada incorrecte"
  fi 

else
  echo "Hi ha hagut algun error en la compilació"
fi

rm -f program_exec
