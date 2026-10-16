# 1. Backup before reinstalling

> Do this **on your old system**. Anything that isn't in the backup or in git is gone after formatting.

Installing Arch for the first time? Skip this step and head to [USB stick and BIOS](./02-usb-and-bios.md).

## 1.1. Push your live configs to the repo

Your configs in `~/.config` may have drifted ahead of the repo. Check the diff:

```bash
cd ~/arch-install-kit
git pull

diff -rq dotfiles/.config ~/.config | grep -v "Only in /home"
diff -rq dotfiles/bin ~/bin
```

Copy the changes you want to keep into `dotfiles/`, then commit and push.

> If you installed with `--link`, your configs are already symlinks to the repo — `git status` is all you need.

## 1.2. Save your installed package list

```bash
mkdir -p ~/reinstall-backup
pacman -Qqen > ~/reinstall-backup/pkglist.txt   # from the official repos
pacman -Qqem > ~/reinstall-backup/aurlist.txt   # from the AUR
```

Handy for comparing against [packages/](https://github.com/Zilero232/arch-install-kit/tree/master/packages) and adding anything you installed by hand.

## 1.3. Save whatever isn't in the repo

```bash
cd ~/reinstall-backup

cp -a ~/.ssh ssh                         # keys — the most important part
cp -a ~/.gnupg gnupg 2>/dev/null
cp ~/.gitconfig gitconfig 2>/dev/null
cp ~/.local/share/fish/fish_history . 2>/dev/null
cp -a ~/Images images                    # your own wallpapers
```

Check these by hand:

| What                     | How to save it                                                            |
| ------------------------ | ------------------------------------------------------------------------- |
| Projects in `~/Projects` | `git status` in each → everything committed and pushed                    |
| `.env` and other secrets | `find ~/Projects -name ".env*" -not -path "*/node_modules/*"` → copy them |
| PostgreSQL               | `sudo -u postgres pg_dumpall > pg_dump.sql`                               |
| Docker volumes           | `docker volume ls`, export the ones you need to an archive                |
| Browsers                 | turn on sync or copy `~/.config/google-chrome`, `~/.mozilla`              |
| IDE                      | Settings Sync / export your settings                                      |
| Documents                | `~/Documents`, `~/Downloads`, `~/Videos`, `~/Music`                       |

## 1.4. Get the backup off the disk

```bash
tar czf ~/reinstall-backup.tar.gz -C ~ reinstall-backup
cp ~/reinstall-backup.tar.gz /run/media/$USER/<usb-stick>/
```

> **A separate `/home` partition** can be left unformatted during install, so your home folder survives the reinstall intact. Make the backup anyway: one partitioning mistake and the partition is wiped.

---

**Next:** [2. USB stick and BIOS →](./02-usb-and-bios.md)
