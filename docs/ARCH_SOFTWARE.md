# Системное программное обеспечение Arch Linux

## 1. Системные компоненты

### Графическая система
- `xorg-server` - X Window System сервер
- `xorg-xinit` - Инициализация X-сервера
- `xorg-xbacklight` - Управление яркостью
- `picom` - Композитный менеджер

### Дисплейный менеджер
- `plymouth` - Загрузочный экран
- `plymouth-theme-deus-ex-git` - Тема Plymouth [AUR]

- `sddm` - Менеджер входа
- `sddm-astronaut-theme` - Тема SDDM [AUR]

### Оконный менеджер
- `bspwm` - Тайловый менеджер окон
- `sxhkd` - Обработчик горячих клавиш
- `polybar` - Статус-бар
- `dunst` - Система уведомлений
- `i3lock-color` - Блокировка экрана
- `wlogout` - Меню выхода [AUR]

### Аудио система
- `pulseaudio` - Звуковой сервер
- `pulseaudio-alsa` - ALSA интеграция
- `pulseaudio-bluetooth` - Bluetooth аудио
- `alsa-plugins` - Плагины ALSA
- `alsa-tools` - Инструменты ALSA
- `alsa-utils` - Утилиты ALSA
- `pavucontrol` - Звуковой микшер
- `pamixer` - CLI управление звуком
- `sound-theme-freedesktop` - Стандартные системные звуки

### Сетевая система
- `networkmanager` - Управление сетью
- `network-manager-applet` - GUI для сети
- `dhcpcd` - DHCP клиент
- `iwd` - WiFi демон
- `openssh` - SSH сервер/клиент
- `wireshark-qt` - Анализ сети

### Bluetooth
- `bluez` - Bluetooth стек
- `bluez-utils` - Утилиты Bluetooth
- `blueman` - GUI менеджер
- `bluez-hid2hci` - HID поддержка

## 2. Управление системой

### Системные утилиты
- `xfce4-settings` - Настройки системы
- `timeshift` - Бэкапы системы
- `bleachbit` - Очистка системы
- `gnome-disk-utility` - Управление дисками
- `reflector` - Управление зеркалами
- `pacman-contrib` - Утилиты pacman

### Мониторинг системы
- `htop` - Просмотр процессов
- `btop` - Мониторинг ресурсов

### Управление питанием
- `brightnessctl` - Управление яркостью
- `upower` - Управление питанием
- `tlp` - Энергосбережение
- `tlp-rdw` - Радио устройства

## 3. Пользовательское окружение

### Терминалы
- `xterm` - Базовый терминал
- `alacritty` - Современный терминал

### Командная строка
- `fish` - Командная оболочка
- `tmux` - Мультиплексор
- `lsd` - Улучшенный ls
- `bat` - Улучшенный cat

### Файловые менеджеры
- `thunar` - GUI менеджер
- `ranger` - CLI менеджер
- `tree` - Просмотр каталогов
- `ueberzug` - Превью изображений
- `xclip` - Буфер обмена

### Запуск приложений
- `rofi` - Лаунчер
- `rofi-calc` - Калькулятор
- `rofi-emoji` - Эмодзи

### Рабочий стол
- `nitrogen` - Обои
- `flameshot` - Скриншоты
- `peek` - Запись GIF
- `redshift` - Цветовая температура
- `gpick` - Пипетка
- `cheese` - Веб-камера
- `touche` - Тачпад
- `gnome-calculator` - Калькулятор
- `gnome-clocks` - Часы
- `obs-studio` - Запись экрана

## 4. Разработка

### Редакторы
- `code` - VS Code
- `neovim` - Vim редактор
- `cursor-bin` - AI IDE [AUR]
- `phpstorm` - PHP IDE [AUR]

### Инструменты разработки
- `git` - Контроль версий
- `docker` - Контейнеры
- `docker-compose` - Управление контейнерами
- `postman-bin` - API тестирование [AUR]
- `shellcheck` - Проверка скриптов
- `cloc` - Подсчёт кода
- `fakeroot` - Root симуляция
- `filezilla` - FTP клиент
- `jq` - JSON утилита
- `meson` - Сборка
- `composer` - PHP зависимости

### Языки программирования
- Python:
  - `python` - Интерпретатор
  - `python-pip` - Пакетный менеджер
  - `bpython` - REPL
  - `ipython` - Оболочка
- Node.js:
  - `node` - Среда выполнения
  - `npm` - Пакетный менеджер
  - `nvm` - Версионирование [AUR]

## 5. Приложения

### Интернет
- `firefox` - Браузер
- `chromium` - Браузер

### Коммуникация
- `telegram-desktop` - Telegram
- `discord` - Discord
- `slack-desktop` - Slack [AUR]
- `zoom` - Платформа для видеоконференций [AUR]

### Мультимедиа
- Видео/Аудио:
  - `vlc` - Медиаплеер
	- `mpv` - Легковесный медиаплеер в дополнение к VLC
  - `mpd` - Музыкальный сервер
  - `ncmpcpp` - MPD клиент
  - `spotify` - Spotify [AUR]
  - `cava` - Визуализатор [AUR]
- Графика:
  - `pinta` - Редактор
  - `gthumb` - Просмотрщик
  - `figma-linux` - Figma [AUR]

### Офис
- `libreoffice-fresh` - Офисный пакет
- `evince` - PDF просмотрщик
- `zathura` - PDF просмотрщик
- `obsidian` - Заметки [AUR]

### Утилиты
- Архивация:
  - `xarchiver` - GUI архиватор
  - `zip`, `unzip` - ZIP архивы
  - `p7zip` - 7z архивы
  - `tar`, `gzip`, `bzip2` - Базовые архиваторы
- Загрузки:
  - `transmission-gtk` - Торрент-клиент

### Безопасность
- `keepassxc` - Пароли
- `gufw` - Файервол
- `veracrypt` - Шифрование

## 6. Оформление

### Темы
- `dracula-gtk-theme` - GTK тема [AUR]
- `dracula-icons-git` - Иконки [AUR]
- `dracula-cursors-git` - Курсоры [AUR]

### Шрифты
- `ttf-jetbrains-mono` - JetBrains Mono
- `ttf-jetbrains-mono-nerd` - С иконками
- `ttf-fira-code` - Fira Code
- `ttf-iosevka-nerd` - Iosevka
- `noto-fonts` - Noto