#!/bin/bash

log_file=""
error_file=""

# Проверка доступность пути для запись
function check_path_writable() {
    if [ -e "$1" ]; then
        if [ ! -w "$1" ]; then
            echo "Ошибка: Нет прав на запись в файл '$1'." >&2
            exit 1
        fi
    else
        touch "$1" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Ошибка: Не удалось создать файл '$1'." >&2
            exit 1
        fi
    fi
}

# Функция для вывода списка процессов, отсортированных по PID
function show_processes() {
    ps -e --sort=pid
}

# Функция для вывода списка пользователей и их домашних директорий
function show_users() {
    getent passwd | awk -F: '{ print $1 ": " $6 }' | sort
}

# Cправки
function show_help() {
    echo "Использование: $0 [опции]"
    echo "Опции:"
    echo "  -h, --help          Показать справку"
    echo "  -u, --users         Показать список пользователей и их домашних директорий"
    echo "  -p, --processes     Показать список запущенных процессов, отсортированных по PID"
    echo "  -l PATH, --log PATH Перенаправить стандартный вывод в файл по пути PATH"
    echo "  -e PATH, --errors PATH Перенаправить вывод ошибок в файл по пути PATH"
}

# Обработка опций
while [[ "$1" != "" ]]; do
    case "$1" in
        -h | --help)
            show_help
            exit 0
            ;;
        -u | --users)
            output=$(show_users)
            ;;
        -p | --processes)
            output=$(show_processes)
            ;;
        -l | --log)
            shift
            log_file="$1"
            check_path_writable "$log_file"
            ;;
        -e | --errors)
            shift
            error_file="$1"
            check_path_writable "$error_file"
            ;;
        *)
            echo "Неверная опция: $1" >&2
            show_help
            exit 1
            ;;
    esac
    shift
done

# Если не было передано ни одного аргумента
if [ -z "$output" ] && [ -z "$log_file" ] && [ -z "$error_file" ]; then
    echo "Не передано аргументов. Используйте -h или --help для справки."
    exit 1
fi

# Если установлен файл логов, то выводим его
if [ -n "$log_file" ]; then
    exec 1>>"$log_file"
fi

# Если установлен файл для ошибок, то выводим его
if [ -n "$error_file" ]; then
    exec 2>>"$error_file"
fi

# Выводим результат, если он есть
if [ -n "$output" ]; then
    echo "$output"
fi
