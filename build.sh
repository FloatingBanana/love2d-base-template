#!/usr/bin/bash

PLATFORM=${1:-all}
NAME='ld50'
LOVEFILE='_build/'$NAME'.love'

function print_info() {
    echo -e -n "\e[34m$1\e[0m"
}

function print_success() {
    echo -e "\e[32m$1\e[0m"
}

function print_error() {
    echo -e "\e[31m$1\e[0m"
}

function build_lovefile() {
    print_info "Building love project file: "

    rm -f $LOVEFILE

    if zip -9 -r $LOVEFILE 'src' > /dev/null; then
        print_success "Done"
    else
        print_error "Failed"
		exit 1
    fi
}

function build_windows() {
    print_info "Building for Windows: "

    rm -rf '_build/windows' && \
    mkdir '_build/windows' && \
	cat 'bin/love-windows/love.exe' $LOVEFILE > '_build/windows/'$NAME'.exe' && \
	cp 'bin/love-windows/'*.dll '_build/windows/' && \
	cp 'bin/love-windows/license.txt' '_build/windows/license.txt'

    if [[ $? -eq 0 ]]; then
        print_success "Done"
    else
        print_error "Failed"
    fi
}

function build_linux() {
	print_info "Building for Linux: "

	rm -rf '_build/linux' && \
	cp -R 'bin/love-appimage' '_build/linux' && \
	cat '_build/linux/bin/love' $LOVEFILE > '_build/linux/bin/game' && \
	chmod +x '_build/linux/bin/game' && \
	chmod +x '_build/linux/rungame' && \
	mv '_build/linux/rungame' '_build/linux/'$NAME &&\

    if [[ $? -eq 0 ]]; then
        print_success "Done"
    else
        print_error "Failed"
    fi
}

function build_web() {
    print_info "Building for web browser: "

    rm -rf '_build/web/'
    if npx love.js -t $NAME -m 62914560 $LOVEFILE '_build/web'; then
        print_success "Done"
    else
        print_error "Failed"
    fi
}

mkdir -p _build

build_lovefile
case $PLATFORM in
    'windows')
        build_windows
        ;;
	'linux')
		build_linux
		;;
    'web')
        build_web
        ;;
    'all')
        print_info "Building for all platforms\n"
        build_windows
		build_linux
        build_web
        ;;
    'lovefile')
        ;;
esac
