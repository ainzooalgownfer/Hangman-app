# Pendu en réseau

Hangman over TCP for the M1 Réseaux mini-project: a Go server and a Python client, one JSON message per line.

This repo only links the two projects together and holds the settings to run them.

| Path | What |
|---|---|
| `server/` | Go server, submodule of [ainzooalgownfer/Hangman](https://github.com/ainzooalgownfer/Hangman) |
| `client/` | Python client, submodule of [ainzooalgownfer/hangman-client](https://github.com/ainzooalgownfer/hangman-client): `gui.py` (tkinter), `client.py` (terminal) |
| `play.sh` | starts the server if needed, then the client |
| `compose.yaml` | server and terminal client in Docker |
| `server-config/config.yaml` | server settings for this app: port 5050, 6 attempts |
| `docker/client.Dockerfile` | image of the terminal client |

## Requirements

- Docker (or Go 1.27 to build the server without Docker)
- Python 3 with tkinter for the GUI: `sudo apt install python3-tk` (Debian/Ubuntu), `brew install python-tk` (Mac)

## Get it

```bash
git clone --recursive https://github.com/ainzooalgownfer/Hangman-app.git
cd Hangman-app
```

Without `--recursive`, `server/` and `client/` are empty: run `git submodule update --init`.

## Play

```bash
./play.sh          # GUI
./play.sh cli      # terminal client
```

The script starts the server if it isn't running (Docker, or Go if Docker is off), then opens the client. The server stops when the client closes, unless it was already running.

In the GUI, uncheck "Connexion chiffrée (TLS)": the server doesn't use TLS yet.

## Run by hand

```bash
docker compose up -d                 # server on port 5050
docker compose run --rm client       # terminal client
python3 client/gui.py                # GUI, outside Docker
docker compose down                  # stop
```

## Updates

Dependabot opens a pull request every day when the server or the client has new commits. To update by hand:

```bash
git submodule update --remote
git commit -am "Update submodules"
```

## CI

On every push and pull request, GitHub Actions builds both images, starts the server and plays a game with the real client.
