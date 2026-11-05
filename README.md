# mintupdate-systemd

Автозапуск Linux Mint Update Manager (трей) через systemd user unit
вместо XDG-автозапуска. Убирает «чёрный экран» после пароля.

> ВАЖНО: создано спомощью ии DeepSeek. Проверено только
> на одной машине. На другой системе может не работать.

## Структура

- systemd-user/mintupdate-autostart.service — systemd user unit
- autostart/mintupdate.desktop — XDG-заглушка (Hidden=true)
- install.sh — установщик

## Установка (для других людей)

Через `.deb` — он чинит для всей системы. В Linux Mint можно просто дважды кликнуть по файлу `mintupdate-systemd-fix_1.1_all.deb`, либо установить через терминал:

    sudo dpkg -i mintupdate-systemd-fix_1.1_all.deb

Либо `./install.sh` — только для пользователя и не рекомендуется (неудобная установка):

    ./install.sh

После ребута подождать ~30 секунд:

    systemctl --user status mintupdate-autostart.service --no-pager
    pgrep -afi mintupdate

Ожидаемо: юнит `inactive (dead)` + `status=0/SUCCESS` (launcher форкнулся), `mintUpdate` в `pgrep` — иконка в трее.

## Как это работает

1. XDG-заглушка (Hidden=true) отключает стандартный автозапуск.
2. systemd unit запускает mintupdate-launcher параллельно сессии, Cinnamon его не ждёт.
3. KillMode=process — обязателен: launcher форкается, родитель выходит с кодом 0, и без KillMode=process systemd убивает дочерний mintUpdate.py вместе с cgroup.
4. Restart=on-failure + RestartSec=15 — перезапуск при сбое.

## Настройки

- ExecStartPre=/bin/sleep 25 — задержка, можно 15-20
- Environment=LANG=ru_RU.UTF-8 — своя локаль
- Environment=DISPLAY=:0 — проверить echo $DISPLAY
- %h и %t — specifiers: %h=$HOME, %t=/run/user/UID

## Проверка, что трей поднял именно юнит

    for p in $(pgrep -f mintupdate); do
      echo "PID $p:"
      cat /proc/$p/cgroup
    done

В cgroup должен быть путь с mintupdate-autostart.service.

## Тестирование

- ОС: Linux Mint (Cinnamon, X11)
- Железо: Huawei MateBook D 15 (BOD-WXX9), Intel
- Дата: 2026-11-04
- Результат: install.sh + sudo reboot -> mintUpdate поднимается сам, иконка в трее, чёрного экрана нет.

Не проверено: другие версии Mint/Cinnamon/systemd, Wayland, GNOME/KDE/XFCE, другие дистрибутивы, другие локали, другие версии mintupdate.

## Удаление

    systemctl --user disable --now mintupdate-autostart.service
    rm -f ~/.config/systemd/user/mintupdate-autostart.service
    rm -f ~/.config/autostart/mintupdate.desktop
    systemctl --user daemon-reload

## Лицензия

As is, без гарантий. Автор — марк и искусственный интеллект DeepSeek — не несёт ответственности за последствия использования.
Создано в ноябре 2026.