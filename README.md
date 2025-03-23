# Scripts de Compilació per C i Assemblador
Aquest repositor conté scripts en Bash destinats a facilitar la compilació i execució de projectes en llenguatge C i Assemblador, tant per compilar al PC com per carregar a microcontroladors basats en AVR, com ara els Arduinos. Aquests scripts estan pensats per agilitzar tasques repetitives i afegir opcions útils de forma ràpida i eficient.

---

## Contingut

- `Script_c.sh` - Script per compilar fitxers `.c` amb suport per  PC i AVR
- `Script_as.sh` - Script per compilar fitxers `.s` amb suport per AVR 
- Scripts antics (`Script_as.old`, `Script_c.old`, `C_interactiu.sh`) - Versions més simples però mantingudes com a referència

---

## Script_c.sh 

Script per compilar codi C per a:
- PC (mitjançant `gcc`)
- AVR/Arduino (mitjançant `avr-gcc` i `avrdude`)

### Opcions

| Opció         | Descripció                                                       |
|---------------|------------------------------------------------------------------|
| `-pc`         | Compila per a PC i executa el programa                           |
| `-avr`        | Compila per a Arduino/AVR                                        |
| `-upload`     | Carrega el `.hex` a l'Arduino                                    |
| `-port [PORT]`| Defineix el port de l'Arduino (`/dev/ttyACM0` per defecte)       |
| `-clean`      | Elimina fitxers temporals després de compilar                    |
| `--help`      | Mostra l'ajuda i exemples                                        |

### Exemple 
```Bash
./Script_c.sh -avr $NOM$ -upload -port /dev/ttyUSB0 -clean 
```

El que ens està indicant aquesta comanda és que es compila el fitxer `$NOM$` per AVR, el carrega a l'arduino a traves del port /dev/ttyUSB0 i neteja els fitxers intermedis.

---

## Script_as.sh 

Scipt per cmpilar fitxers `.s` en assembly per AVR, en el meu cas Arduino. També permet carregar el `.hex` generat i obrir una sessió `picocom` per comunicar-se amb el microcontrolador.

### Opcions

| Opció              | Descripció                                                   |
|--------------------|--------------------------------------------------------------|
| `-no-upload`       | No carregar el `.hex` a l'Arduino (per defecte: sí)          |
| `-picocom`         | Obrir `picocom` després de carregar                          |
| `-baud [velocitat]`| Defineix el baud rate per a `picocom` (per defecte: 9600)    |
| `-clean`           | Elimina els fitxers temporals després de compilar            |
| `-port [PORT]`     | Defineix el port de l'Arduino (`/dev/ttyACM0` per defecte)   |
| `--help`           | Mostra l’ajuda i exemple d’ús                                |

### Exemple 
```Bash
./Script_as.sh -picocom -baud 19200 -clean -port /dev/ttyACM0 $NOM$
```

El que ens està indicant aquesta comanda és que es compila el fitxer `$NOM`, es carrega el fitxer `.hex` a l'Arduino, obre el picocom amb un baud rate de 19200 i neteja els fitxers intermedis.

---

## Scripts antics

Aquest repositòri també inclou una carpeta amb els **scripts antics** que vaig utilitzar inicialment per compilar fitxers `.c` i `.s`. Tot i que actualment estan en desús, els conservo com a referència.

| Script              | Descripció                                                 |
|---------------------|------------------------------------------------------------|
| `Script_c.sh`       | Versió inicial per compilar fitxers `.c` per PC            |
| `Script_as.sh`      | Script senzill per compilar `.s` en assembly AVR           |
| `C_interactiu.sh`   | Script interactiu per compilar fitxers `.c` per a PC i AVR |

Els scripts nous (`Script_as.sh` i `Script_c.sh`) incorporen totes les funcionalitats que tenien els antics, però amb més opcions, manera ràpida de configuració de la compilació i carrega i més robustesa.

## Requisits

Per tal que aquestes scripts funcionin correctament cal tenir instalat a la màquina l seguent:

- `gcc` necessàri per la compilació per PC 
- `avr-gcc` i `avr-objcopy` necessaris per la compilació per AVR
- `avrdude` necessàri per carregar el codi a l'Arduino
- `picocom` és opcional però a la vegada necessàri si es vol tenir una comunicació en sèrie amb l'Arduino
