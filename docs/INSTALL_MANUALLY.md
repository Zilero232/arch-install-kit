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
# Внимание: /dev/sda используется как пример!
# У вас может быть другое название диска (например, /dev/nvme0n1, /dev/vda или /dev/sdb)
# Используйте команду lsblk для определения правильного имени вашего диска
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
### 4. Активация swap и монтирование разделов
```bash
# Активация swap
swapon /dev/sda4

# Монтирование разделов
mount /dev/sda1 /mnt

mkdir -p /mnt/{boot/EFI,home}

mount /dev/sda2 /mnt/home
mount /dev/sda3 /mnt/boot/EFI
```

### 5. Установка базовой системы
```bash
# Устанавливаем базовые софты
pacstrap -K /mnt base base-devel linux linux-firmware iwd dhcpcd networkmanager vim

# Генерируем fstab
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

# Переход в новую систему
arch-chroot /mnt
```

### 5. Настройка пользователей
```bash
# Установка пароля root
passwd

# Создание пользователя
useradd -m -G wheel,users,video,audio,optical,storage,power,network -s /bin/bash zilero
passwd zilero

# Настройка sudo
EDITOR=vim visudo
# Раскомментировать %wheel ALL=(ALL:ALL) ALL
```

### 7. Настройка системы

```bash
# Редактирование locale.gen
vim /etc/locale.gen
# Раскомментировать ru_RU.UTF-8 и en_US.UTF-8

# Сгенерировать локали
locale-gen

# Выбрать язык по дефолту
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Настройка времени
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# Настройка сети
vim /etc/hostname

# Настройка hosts
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 archlinux.localdomain archlinux" >> /etc/hosts
```

### 8. Установка загрузчика

```bash
# Установка необходимых пакетов
pacman -S grub efibootmgr os-prober

# Редактирование grub
vim /etc/default/grub
# Раскомментировать "GRUB_DISABLE_OS_PROBER=false"

# Установка GRUB
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --efi-directory=/boot/EFI --recheck

# Создание конфига
grub-mkconfig -o /boot/grub/grub.cfg

# Выход и перезагрузка
exit
umount -R /mnt
reboot
```

## Настройка системы после первой загрузки

```bash
# Включение и запуск NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager

# Подключение к Wi-Fi через NetworkManager
nmcli device wifi list
nmcli device wifi connect SSID password PASSWORD

# Установка Xorg и необходимых компонентов
pacman -S xorg xorg-xinit xterm bspwm

# Установка видеодрайверов (выберите соответствующий вашей видеокарте)

# Для Intel:
pacman -S xf86-video-intel
# Для NVIDIA:
pacman -S nvidia nvidia-utils
# Для AMD:
pacman -S xf86-video-amdgpu

# Создание конфигурационного файла xinit
cp /etc/X11/xinit/xinitrc ~/.xinitrc

# Проверка работоспособности X сервера
startx
```

## Дополнительная информация
Подробное руководство по настройке системы после установки можно найти в файле SYSTEM_SETTINGS.md[#SYSTEM_SETTINGS.md]