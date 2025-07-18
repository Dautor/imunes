
_himage()
{
	COMP_WORDBREAKS="\"'><=;|&(:	  "
	local cur=${COMP_WORDS[COMP_CWORD]}
	local prev=${COMP_WORDS[COMP_CWORD-1]}
 
	nodes=`himage -ln | tr -d '[],' | \
		awk '    { for(i=2;i<=NF;++i) {eid[$i]=eid[$i]" "$1; ++nexp[$i]}} \
			 END {for (k in eid) {\
					  if (nexp[k] > 1) {\
						  split(eid[k],eids," "); \
						  for (e in eids) printf "%s@%s ",k,eids[e] \
					  } else { printf "%s ", k }\
				 }}'`

	if test $COMP_CWORD -eq 1; then
		case "$prev" in
		 -[hlb]|-ln|-nt)
		   return 0
		   ;;
		esac
	  
		if [[ "$cur" == -* ]]; then
			COMPREPLY=( $(compgen -W "-h -m -v -n -e -j -i -d -l -ln -b -nt" -- $cur))
		else
			COMPREPLY=( $(compgen -W "$nodes" -- $cur))
		fi

		return 0
	fi

	if test $COMP_CWORD -eq 2; then
		case "$prev" in
		 -[hlb]|-ln|-nt)
		   return 0
		   ;;
		esac
	  
		if [[ "$prev" == -* ]]; then
			COMPREPLY=( $(compgen -W "$nodes" -- $cur))
			return 0
		fi
	fi

	local host=${COMP_WORDS[1]}
	[[ ${COMP_WORDS[1]} == "-m" ]] && local host=${COMP_WORDS[2]}

	if [[ $COMP_CWORD -eq 2 || ($COMP_CWORD -eq 3 && ${COMP_WORDS[COMP_CWORD-2]} = "-m") ]]; then
		commands=$(echo compgen -c $cur | himage ${host} bash -s)
		COMPREPLY=( $(compgen -W "$commands" -- $cur))
		return 0
	fi

	COMPREPLY=(${COMPREPLY[@]:-} $(echo compgen -f -- "$cur" | himage ${host} bash -s))
	return 0
}

complete -o filenames -F _himage himage

