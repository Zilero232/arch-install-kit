# Установка Arch Linux

Данный файл содержит последовательность команд для установки Arch Linux.

## Подготовка к установке

### 1. Подключение к Wi-Fi

```bash
# Запуск менеджера Wi-Fi
iwctl

# Просмотр устройств
device list

# Сканирование и подключение
station устройство scan
station устройство get-networks
station устройство connect SSID

# Выход из сервиса
exit

# Проверка подключения
ping google.org
```

### 2. Разметка диска (UEFI/GPT)

```bash
# Просмотр текущих разделов
lsblk

# Запуск cfdisk
cfdisk /dev/sda

# В интерактивном меню создаем разделы:
1. Выбираем GPT
2. Создаем разделы:
- /dev/sda1 - 100G, Linux filesystem (root)
- /dev/sda2 - 700g, Linux filesystem (home)
- /dev/sda3 - 1G, EFI System
- /dev/sda4 - remaining, Linux swap
3. Write (записать изменения)
4. Quit (выход)
```
### 3. Форматирование разделов

```bash
# Root раздел
mkfs.ext4 /dev/sda1

# Home раздел
mkfs.ext4 /dev/sda2

# EFI раздел
mkfs.fat -F32 /dev/sda3

# Swap раздел
mkswap /dev/sda4
```
### 4. Активация swap

```bash
swapon /dev/sda4
```

### 5. Монтирование разделов

```bash
mount /dev/sda1 /mnt

mkdir -p /mnt/{boot/EFI,home}

mount /dev/sda2 /mnt/home
mount /dev/sda3 /mnt/boot/EFI
```

### 6. Сборка ядра и базовых софтов

```bash
# Устанавливаем базовые софты
pacstrap -K /mnt base base-devel linux linux-firmware iwd dhcpcd networkmanager vim

# Генерируем fstab
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# Настройка системы
arch-chroot /mnt

# Нужно раскомментировать ru_RU и en_US в этом файле
vim /etc/locale.gen

locale-gen

# Создание locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Настройка времени
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# Настройка сети
echo "archlinux" > /etc/hostname

# Настройка hosts
vim /etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.1.1 archlinux.localdomain archlinux

# Включение сервисов
systemctl enable NetworkManager

# Пользователи
passwd # пароль root

useradd -m -G wheel,users,video,audio,optical,storage,power,network -s /bin/bash zilero
passwd zilero

# Выдаем права на sudo
sudo EDITOR=vim visudo
# После открытия раскомментируйте %wheel ALL=(ALL:ALL) ALL
```

### 7. Установка загрузчика

```bash 
# Установка необходимых пакетов
pacman -S grub efibootmgr os-prober ntfs-3g

# Включение поиска других ОС
vim /etc/default/grub
# После открытия раскомментируйте GRUB_DISABLE_OS_PROBER=false

# Установка GRUB (указываем именно диск, а не раздел!)
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck /dev/sda

# Настройка параметров GRUB
vim /etc/default/grub

# Рекомендуемые настройки:
GRUB_TIMEOUT=5
GRUB_DISABLE_OS_PROBER=false
GRUB_DISABLE_SUBMENU=y

# Создание конфигурации GRUB
os-prober # поиск других ОС
grub-mkconfig -o /boot/grub/grub.cfg

# Проверяем, что Windows найдена в выводе команды
cat /boot/grub/grub.cfg | grep Windows

# Выход из chroot
exit

umount -R /mnt

# Перезагрузка
reboot
```