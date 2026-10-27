#!/usr/bin/env bash
# Starts the server if it isn't running, then the client.
#
#   ./play.sh        graphical client (tkinter)
#   ./play.sh cli    terminal client
#
# In GUI mode the server logs are shown in this terminal.
#
# The server runs with Docker, or is built with Go if Docker isn't running.
# It is stopped when the client closes, unless it was already running before.

set -euo pipefail
cd "$(dirname "$0")"

MODE=${1:-gui}
HOST=127.0.0.1
PORT=5050
RUN_DIR=.run
started=""
SINCE=$(date -u +%Y-%m-%dT%H:%M:%SZ) # only show logs from this run

port_open() {
	(exec 3<>"/dev/tcp/$HOST/$PORT") 2>/dev/null
}

start_server() {
	if docker info >/dev/null 2>&1; then
		echo "Starting the server with Docker..."
		docker compose --progress quiet up -d --build server
		started=docker
	elif command -v go >/dev/null; then
		echo "Docker isn't running: building the server with Go..."
		mkdir -p "$RUN_DIR"
		(cd server && go build -o "../$RUN_DIR/hangman" ./cmd/server)
		cp server-config/config.yaml server/words.json "$RUN_DIR/"
		(cd "$RUN_DIR" && exec ./hangman >server.log 2>&1) &
		started=$!
	else
		echo "Neither Docker nor Go is available. Start Docker Desktop and try again." >&2
		exit 1
	fi

	for _ in $(seq 30); do
		port_open && return
		sleep 0.5
	done
	echo "The server didn't start on port $PORT." >&2
	exit 1
}

stop_server() {
	case "$started" in
	"") ;;
	docker) docker compose --progress quiet stop server ;;
	*) kill "$started" 2>/dev/null || true ;;
	esac
	[ -n "$started" ] && echo "Server stopped."
}

# follow_logs streams the server's logs in the background (sets $logs_pid).
follow_logs() {
	if docker compose ps -q server 2>/dev/null | grep -q .; then
		docker compose logs -f --no-log-prefix --since "$SINCE" server &
	elif [ -f "$RUN_DIR/server.log" ]; then
		tail -n +1 -f "$RUN_DIR/server.log" &
	else
		return
	fi
	logs_pid=$!
}

# logs_hint prints how to watch the logs from another terminal.
logs_hint() {
	if docker compose ps -q server 2>/dev/null | grep -q .; then
		echo "Server logs, in another terminal: docker compose logs -f server"
	elif [ -f "$RUN_DIR/server.log" ]; then
		echo "Server logs, in another terminal: tail -f $RUN_DIR/server.log"
	fi
}

cleanup() {
	[ -n "$logs_pid" ] && kill "$logs_pid" 2>/dev/null
	stop_server
}
logs_pid=""
trap cleanup EXIT

if [ ! -f server/go.mod ] || [ ! -f client/client.py ]; then
	echo "Fetching the submodules..."
	git submodule update --init
fi

if port_open; then
	echo "Server already running on port $PORT."
else
	start_server
	echo "Server ready on port $PORT."
fi

case "$MODE" in
gui)
	if ! python3 -c 'import tkinter' 2>/dev/null; then
		echo "tkinter is missing. Debian/Ubuntu: sudo apt install python3-tk  ·  Mac: brew install python-tk" >&2
		exit 1
	fi
	echo "Opening the game. Uncheck \"Connexion chiffrée (TLS)\": the server doesn't use TLS yet."
	echo "Server logs:"
	follow_logs
	python3 client/gui.py
	;;
cli)
	logs_hint
	python3 client/client.py "$HOST" "$PORT"
	;;
*)
	echo "Usage: ./play.sh [gui|cli]" >&2
	exit 1
	;;
esac
