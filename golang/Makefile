all: build

build:
	CGO_ENABLED=0 go build -o sloview-server -ldflags '-w -extldflags "-static"' .