# Базовый образ golang версии 1.22.0
FROM golang:1.22.0
# Обновляем локальную базу данных о доступных пакетах и их версиях из репозиториев и ставим sqlite3
RUN apt update && apt install -y sqlite3
# Рабочая дирректория относительно которой будет все операции выполняться
WORKDIR /opt/go-app/src
# Копируем все файлы нужные для сборки
COPY go.mod go.sum *.go ./
# Скачать зависимости в соответствии с go.mod
# Cобрать приложение go для запуска
# Удалить исходники
# Создать системную (--system) группу gouser
# Создать системного (--system) пользователя gouser в группе (--ingroup gouser),
#         без возможности входа через оболочку (--shell /bin/false), 
#         без пароля (--disabled-password) и домашней дирректории (--no-create-home)
# Меняем владельца рекурсивно с отчетом
RUN go mod download \
    && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /opt/go-app/go-basic-sprint11 \
    && rm -rf /opt/go-app/src \
    && addgroup --system gouser \
    && adduser --system --ingroup gouser --shell /bin/false --no-create-home --disabled-password gouser \
    && chown -v -R gouser:gouser /opt/go-app
# Копируем файл БД и делаем еe собственником gouser
COPY --chown=gouser:gouser tracker.db ./
# Приложение будет запускаться под пользователем gouser
USER gouser
# Запустить приложение
CMD ["/opt/go-app/go-basic-sprint11"]