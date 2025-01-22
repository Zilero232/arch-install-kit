# --- Основные настройки вывода ---
print_info() {
    info title            # Показывает имя пользователя@хост
    info underline        # Разделительная линия
    
    # Основная информация
    info "OS" distro      # Название дистрибутива
    info "Host" model     # Модель компьютера
    info "Kernel" kernel  # Версия ядра
    info "Uptime" uptime  # Время работы системы
    info "Packages" packages  # Количество установленных пакетов
    info "Shell" shell    # Используемая оболочка
    info "Resolution" resolution  # Разрешение экрана
    info "DE" de         # Окружение рабочего стола
    info "WM" wm         # Оконный менеджер
    info "WM Theme" wm_theme  # Тема оконного менеджера
    info "Theme" theme    # Тема GTK
    info "Icons" icons   # Набор иконок
    info "Terminal" term # Используемый терминал
    info "CPU" cpu       # Процессор
    info "GPU" gpu       # Видеокарта
    info "Memory" memory # Использование памяти

    # Дополнительная информация
    # info "GPU Driver" gpu_driver  # Драйвер GPU
    # info "CPU Usage" cpu_usage    # Использование CPU
    # info "Disk" disk              # Использование диска
    # info "Battery" battery        # Состояние батареи
    # info "Font" font              # Шрифт
    # info "Song" song              # Текущий трек (требует плеера)
    # info "Local IP" local_ip      # Локальный IP
    # info "Public IP" public_ip    # Публичный IP
    # info "Users" users            # Пользователи в системе
}

# --- Настройки внешнего вида ---

# Цвета (0-15)
colors=(4 6 1 8 8 6)

# Жирный текст (on/off)
bold="on"

# Подчеркнутый текст (on/off)
underline_enabled="on"

# Подчеркивание символом
underline_char="-"

# Выравнивание информации
# Возможные значения: 'auto', 'left', 'center', 'right'
alignment="auto"

# Отступ для значений
gap=3

# Символ разделитель
separator=":"

# --- Настройки ASCII art ---
# Источник ASCII art
# Возможные значения: 'auto', 'distro', 'custom'
ascii_distro="auto"

# ASCII art файл для custom
# ascii_file="/path/to/ascii_file"

# Цвета ASCII art
ascii_colors=(distro)

# Жирный ASCII art
ascii_bold="on"

# --- Настройки изображения ---
# Включить показ изображения
image_enabled="on"

# Источник изображения
# Возможные значения: 'auto', 'ascii', 'wallpaper', '/path/to/img'
image_source="auto"

# Размер изображения
# Возможные значения: 'auto', '00px', '00%'
image_size="auto"

# Отступ изображения
gap=3

# --- Настройки производительности ---
# Отключение различных проверок для ускорения
# Возможные значения: 'on', 'off'
memory_percent="on"
package_managers="on"
shell_path="on"
shell_version="on"
speed_type="bios_limit"
speed_shorthand="on"
cpu_brand="on"
cpu_speed="on"
cpu_cores="on"
cpu_temp="off"
gpu_brand="on"
gpu_type="all"
refresh_rate="on"
gtk_shorthand="on"
gtk2="on"
gtk3="on"
public_ip_host="http://ident.me"
public_ip_timeout=2