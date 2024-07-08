#!/bin/bash

echo_err() {
	>&2 echo -e "\e[31m$1\e[0m"
}

echo_success() {
	echo -e "\e[32m$1\e[0m"
}

echo_warn() {
	echo -e "\e[33m$1\e[0m"
}
__read_property() {
	local PROPERTIES_FILE=$1
	local KEY=$2
	local VALUE
	echo "Reading '$KEY' from '$PROPERTIES_FILE'"
	if [[ -n $PATH && -f "$PROPERTIES_FILE" ]]; then
		VALUE=$(grep "^$KEY=" "$PROPERTIES_FILE" | sed -n "s/^$KEY=\(.*\)$/\1/p" || echo "") 
	else
		echo_warn "$PROPERTIES_FILE not found"
	fi
	printf "result:'%s'\n" "$VALUE"
}

read_property() {
	local DEBUG="${3:=false}"
	if [[ "$DEBUG" = "true" ]]; then
		local RESULT=$(__read_property $1 $2 | tee /dev/tty | sed -n "s/^result:'\([^']*\)'$/\1/p")
	else
		local RESULT=$(__read_property $1 $2 | sed -n "s/^result:'\([^']*\)'$/\1/p")
	fi
	echo "$RESULT"
}

source_if_exists() {
	local TARGET="$1"
	local IGNORE_EMPTY="${2:=false}"
	if [[ -z "$TARGET" ]]; then
		if [[ "false" = "$IGNORE_EMPTY" ]]; then
			echo_err "TARGET must be provided!"
			return 1
		# else
		# 	echo_warn "TARGET is empty"
		fi
	fi
	if [ -e "$TARGET" ]; then
		# echo "Sourcing file: '$TARGET'"
		# shellcheck disable=SC1090 
		source "$TARGET"
	fi
}

create_dir_if_not_exists() {
	local TARGET_DIR="$1"
	if [ -z "$TARGET_DIR" ]; then
		echo_err "TARGET_DIR must be provided!"
		return 1
	fi
	if ! [ -e "$TARGET_DIR" ]; then
		echo "Creating directory: '$TARGET_DIR'..."
		eval "mkdir -p $TARGET_DIR" 2>&1 | sed "s/^/    /"
	fi
}

create_symlink() {
        local SOURCE="$1"
        local TARGET="$2"
        local OVERIDE="$3"
	if [[ -z "$SOURCE" || -z "$TARGET" ]]; then
		echo_err "SOURCE and TARGET args must be provided!"
		return 1
	fi
	if [[ -n "$OVERIDE" && "$OVERIDE" != "--override" && "$OVERIDE" != "-o" ]]; then
		echo_err "Invalid override flag: '$OVERIDE'... It must be either empty or \"-o\"/\"--override\""
		return 1
	fi
	local EXECUTE=true
        create_dir_if_not_exists "$(dirname "$TARGET")"
        if [[ -L "$TARGET" || -f "$TARGET" ]]; then
                echo_warn "A file is already present at $TARGET!"
		if [ -z "$OVERIDE" ] && choice "Do you want to override?"; then
			OVERIDE="-o"
		fi
                if [[ "$OVERIDE"  = "-o" || "$OVERIDE"  = "--override"  ]]; then
                        echo "  Removing file \"$TARGET\"..."
                        rm "$TARGET"
                else
                        EXECUTE=false
                fi
        elif [ -d "$TARGET" ]; then
                echo_warn "A folder is already present at $TARGET!"
                EXECUTE=false
        fi
        if [ "$EXECUTE" = true ]; then
                echo "Creating Symlink at $TARGET for $SOURCE!"
                chmod +x "$SOURCE"
                ln -s "$SOURCE" "$TARGET"
        fi
}

export_input() {
	local VARNAME=$1
	local MSG=$2
	local ANSWER
	read -r ANSWER
	export "$VARNAME=$RESULT"
}

choice() {
	local MSG="${1:=Choose!}"
	while true; do
		echo "$MSG (y/n):"
		local ANSWER
		read -r ANSWER
		case "$ANSWER" in
			[Yy]* ) 
				return 0 ;;
			[Nn]* ) 
				return 1 ;;
			* )
				echo_err "Invalid option '$ANSWER'... Please enter 'y' or 'n'." ;;
		esac
	done

}
install_app_if_not_exists() {
	local APP_NAME=$1
	if [ -z "$APP_NAME" ]; then
		echo_err "APP_NAME must be provided!"
		return 1
	fi
	shift
	if [ "$#" -eq 0 ]; then
		echo_err "At least one command must be provided!"
		return 1
	fi
	if command -v "$APP_NAME" > /dev/null; then
		echo_warn "$APP_NAME is already installed!"
	else
		echo "Installing '$APP_NAME'"
		for INSTALL_CMD in "$@"; do
			echo "  executing '$INSTALL_CMD'..."
				eval "$INSTALL_CMD" 2>&1 | sed "s/^/    /"
		done
	fi
}

install_package_if_not_exists() {
	local PKG_NAME=$1
	if [ -z "$PKG_NAME" ]; then
		echo_err "PKG_NAME must be provided!"
		return 1
	fi
	local PKG_OK=$(dpkg-query -W --showformat='${Status}\n' "$PKG_NAME" 2>/dev/null | grep "install ok installed" || echo "" )
	if [ "" = "$PKG_OK" ]; then
		echo "Installing '$PKG_NAME'"
		sudo apt-get install "$PKG_NAME"
	else
		echo_warn "$PKG_NAME is already installed!"
	fi
}

__append_unique_line_to_file() {
	local TARGET_FILE="$1"
	local LINE="$2"
	if ! grep -Fxq "$LINE" "$TARGET_FILE"; then
		echo "Appending \"$LINE\" to \"$TARGET_FILE\"..."
		echo "$LINE" >> "$TARGET_FILE"
	# else 
	# 	echo "Line \"$LINE\" already present in  \"$TARGET_FILE\"..."
	fi
}
replace_or_append_property() {
	local PROPERTIES_FILE=$1
	local PROPERTY_KEY=$2
	local PROPERTY_VALUE=$3
	if [[ -n $PATH ]]; then
		touch "$PROPERTIES_FILE"
		local OLD_VALUE
		OLD_VALUE=$(grep "^$PROPERTY_KEY=" "$PROPERTIES_FILE" | sed -n "s/^$PROPERTY_KEY=\(.*\)$/\1/p" || echo "")
		local NEW_CONTENT="$PROPERTY_KEY=$PROPERTY_VALUE"
		if  [[ -n "$OLD_VALUE" ]]; then
			echo "Replacing value '$OLD_VALUE' with '$PROPERTY_VALUE' for key $PROPERTY_KEY..."
			sed -i "s|^$PROPERTY_KEY=.*|$NEW_CONTENT|" "$PROPERTIES_FILE"
		else
			echo "Appending \"$NEW_CONTENT\" to \"$PROPERTIES_FILE\"..."
			echo "$NEW_CONTENT" >> "$PROPERTIES_FILE"
		fi
	else
		echo_warn "$PROPERTIES_FILE not found"
	fi
}

append_source_to_target() {
	local SOURCE_FILE="$1"
	local TARGET_FILE="$2"
	if [[ -z "$SOURCE_FILE" || -z "$TARGET_FILE" ]]; then
		echo_err "SOURCE_FILE and TARGET_FILE args must be provided!"
		return 1
	fi
	if [ ! -e "$TARGET_FILE" ]; then
		create_dir_if_not_exists "$(dirname "$TARGET_FILE")"
		touch "$TARGET_FILE"
	fi
	while IFS= read -r LINE
	do
		__append_unique_line_to_file "$TARGET_FILE" "$LINE"
	done < "$SOURCE_FILE"
}

append_unique_lines_to_file() {
	local TARGET_FILE="$1"
	shift
	if [ -z "$TARGET_FILE" ]; then
		echo_err "TARGET_FILE args must be provided!"
		return 1
	fi
	if [ ! -e "$TARGET_FILE" ]; then
		create_dir_if_not_exists "$(dirname "$TARGET_FILE")"
		touch "$TARGET_FILE"
	fi
	for LINE in "$@"; do
		__append_unique_line_to_file "$TARGET_FILE" "$LINE"
	done
}

nvim_at() {
	set -e
        local CURRENT_DIR="$PWD"
        local TARGET_DIR="${1:-.}"
	local CREATE_DIR_IF_NOT_EXISTS="$2"
	if [[ -n "$CREATE_DIR_IF_NOT_EXISTS" && "$CREATE_DIR_IF_NOT_EXISTS" != "--create-dir" && "$CREATE_DIR_IF_NOT_EXISTS" != "-cd" ]]; then
		echo_err "Invalid second argument: '$CREATE_DIR_IF_NOT_EXISTS'... It must be either empty or \"-cd\"/\"--create-dir\""
		return 
	elif [ -e "$TARGET_DIR" ] || ( [ -n "$CREATE_DIR_IF_NOT_EXISTS" ] || choice "Directory does not exist at $TARGET_DIR. Do you want to create it?"); then
		create_dir_if_not_exists "$TARGET_DIR"

	fi
        if [[ -e "$TARGET_DIR" && "$CURRENT_DIR" != "$TARGET_DIR" ]]; then
		if cd "$TARGET_DIR"; then
			nvim
			cd "$CURRENT_DIR" || echo "cant cd to $TARGET_DIR..."
		else
			echo "Cannot cd to $CURRENT_DIR..."
		fi
        fi
}
