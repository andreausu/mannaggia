#!/bin/sh
############################################################
# Mannaggiatore automatico per VUA depressi
# idea originale by Alexiobash dallo script incazzatore.sh
# ampliata, riscritta e mantenuta da Pietro "Legolas" Suffritti
# convertita in mannaggia.sh rel 0.2
# patcher e contributors:
# Marco Placidi, Maurizio "Tannoiser" Lemmo, Matteo Panella
# Mattia Munari
# thanks to : Veteran Unix Admins group on Facebook
# released under GNU-GPLv3
############################################################
# parametri da command line:
# --audio : attiva mplayer per fargli pronunciare i santi
# --spm <n> : numero di santi per minuto
# --wall : invia l'output a tutte le console : attenzione , se non siete root o sudoers disattivare il flag -n
# --nds <n> : numero di santi da invocare (di default continua all'infinito)
# --random : recupera un santo random

audioflag=false
spm=1
spmflag=false
nds=-1
pot=-1
ndsflag=false
wallflag=false
DELSTRING1="</FONT>"
DELSTRING2="</b>"
DEFPLAYER="mplayer -really-quiet -ao alsa"
PLAYER="${PLAYER:-$DEFPLAYER}"
random=false

# lettura parametri da riga comando
for parm in "$@"
	do
	# leggi dai parametri se c'e' l'audio
	if [ "$parm" = "--audio" ]
		then
		# non facciamo stronzate
		which "$(echo "$PLAYER" | awk '{print $1}')" >/dev/null 2>&1 || {
			echo "Ok, vuoi l'audio, ma il player dove sta?" >&2
			exit 255
		}
		audioflag=true
	fi

	# leggi dai parametri se c'e' da mandare i commenti su wall
	if [ "$parm" = "--wall" ]
		then
		wallflag=true
	fi

	# se spmflag
	# imposta i santi per minuto e resetta il flag
	if [ "$spmflag" = true ]
		then
		if [ "$parm" -lt 1 ]
			then
			spm=1
			spmflag=false
			else
			spm=$((60 / parm))
			spmflag=false
		fi
	fi

	# se parm = --spm
	# setta il flag spmflag
	if [ "$parm" = "--spm" ]
		then
		spmflag=true
	fi

	# se ndsflag
	# imposta il numero di santi da ciclare
	if [ "$ndsflag" = true ]
		then
		nds="$parm"
		ndsflag=false
	fi

	# se parm = --nds
	# setta il flag ndsflag
	if [ "$parm" = "--nds" ]
		then
		ndsflag=true
	fi

	if [ "$parm" = "--random" ]
		then
		random=true
	fi
done

while [ "$nds" != 0 ]
	do
	# shellcheck disable=SC2019
	if [ "$random" = true ]
		then
		MANNAGGIA="Mannaggia $(curl -s api.diostron.zone/random | jq '.summary')"
	else
		MANNAGGIA="Mannaggia $(curl -s api.diostron.zone/today | jq '.[0].summary')"
	fi

  case "$(uname -s)" in
    Darwin)
      say -v Alice "$MANNAGGIA"
    ;;

    Linux)
      MANNAGGIAURL="http://www.ispeech.org/p/generic/getaudio?text=$MANNAGGIA%2C&voice=euritalianmale&speed=0&action=convert"
		;;

    *)
      echo 'OS non supportato'
      exit 1
    ;;
  esac

	if [ "$wallflag" = true ]
		then
		pot=$(( nds % 50 ))
		if [ "$pot" = 0 ]
			then
			echo "systemd merda, poettering vanaglorioso fonte di danni, ti strafulmini santa cunegonda bipalluta protrettice dei VUA"
			else
			# attenzione: se non siete root o sudoers dovete togliere dalla riga successiva "sudo" e "-n"
			echo "$MANNAGGIA" | sudo wall -n
		fi
		else
		echo "$MANNAGGIA" > /dev/stdout
	fi

	if [ "$audioflag" = true ]
		then
		$PLAYER "$MANNAGGIAURL" 2>/dev/null
	fi

	sleep "$spm"
	nds=$((nds - 1))
done
