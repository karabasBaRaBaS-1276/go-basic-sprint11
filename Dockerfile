# 1. Шаг сборки
# Базовый образ golang версии 1.22.0
FROM golang:1.22.0 AS builder
# Рабочая дирректория относительно которой будет все операции будут выполняться
WORKDIR /opt/go-app/src
# Копируем все файлы нужные для сборки
COPY go.mod go.sum *.go tracker.db ./
# Скачать зависимости в соответствии с go.mod
# Cобрать приложение go для запуска
# Удалить исходники
RUN go mod download \
    && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /opt/go-app/go-basic-sprint11 \
    && rm -f go.mod go.sum *.go
# Создать системную (--system) группу gouser
# Создать системного (--system) пользователя gouser в группе (--ingroup gouser),
#         без возможности входа через оболочку (--shell /bin/false), 
#         без пароля (--disabled-password) и домашней дирректории (--no-create-home)
# Меняем владельца рекурсивно с отчетом
RUN addgroup --system gouser \
    && adduser --system --ingroup gouser --shell /bin/false --no-create-home --disabled-password gouser \
    && chown -v -R gouser:gouser /opt/go-app

# 2. Шаг релиза образа
FROM scratch
WORKDIR /opt/go-app/src
# Копируем из builder БД приложение с правами
COPY --from=builder /opt/go-app /opt/go-app
# Копируем из builder пользователей и группы
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Приложение будет запускаться под пользователем gouser
USER gouser
# Запустить приложение
CMD ["/opt/go-app/go-basic-sprint11"]