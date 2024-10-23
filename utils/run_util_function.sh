#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/utils.sh"
FUNCTION=$1
shift
if [[ "$FUNCTION" == "source_if_exists" ]]; then
	source_if_exists "$@"
elif [[ "$FUNCTION" == "create_dir_if_not_exists" ]]; then
	create_dir_if_not_exists "$@"
elif [[ "$FUNCTION" == "create_symlink" ]]; then
	create_symlink "$@"
elif [[ "$FUNCTION" == "install_app_if_not_exists" ]]; then
	install_app_if_not_exists "$@"
elif [[ "$FUNCTION" == "install_package_if_not_exists" ]]; then
	install_package_if_not_exists "$@"
elif [[ "$FUNCTION" == "append_source_to_target" ]]; then
	append_source_to_target "$@"
elif [[ "$FUNCTION" == "append_unique_lines_to_file" ]]; then
	append_unique_lines_to_file "$@"
elif [[ "$FUNCTION" == "choice" ]]; then
	choice "$@"
fi
