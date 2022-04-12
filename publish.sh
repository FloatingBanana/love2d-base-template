#!/usr/bin/bash

VERSION=$1
NAME='ld50'
USER='floatingbanana'

function print_info() {
    echo -e "\e[34m$1\e[0m"
}

function print_success() {
    echo -e "\e[32m$1\e[0m"
}

function print_error() {
    echo -e "\e[31m$1\e[0m"
}

function push_build() {
    print_info "Publishing to $2"

    if butler push "_build/$1" "$USER/$NAME:$2" --userversion "$VERSION"; then
        print_success "Build successfully published"
    else
        print_error "Failed to publish build"
    fi
}

if [ -z "$VERSION" ]; then
    print_error "ERROR: Missing version information"
    exit 1
fi

push_build 'windows' 'windows'
push_build 'web' 'web'
push_build "$NAME.love" 'love-project'
