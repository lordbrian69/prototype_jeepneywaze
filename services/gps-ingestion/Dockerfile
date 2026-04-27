FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o gps-ingestion .

FROM scratch
COPY --from=builder /app/gps-ingestion /gps-ingestion
EXPOSE 8080
ENTRYPOINT ["/gps-ingestion"]
