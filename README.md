# Pendu en réseau

Server (Go) and client (Python) of the M1 Réseaux mini-project.

| Folder | What |
|---|---|
| `server/` | Go server, submodule of [ainzooalgownfer/Hangman](https://github.com/ainzooalgownfer/Hangman) |
| `client/` | Python client, submodule of [ainzooalgownfer/hangman-client](https://github.com/ainzooalgownfer/hangman-client): `client.py` (terminal), `gui.py` (tkinter) |
| `docker/` | Dockerfile for the terminal client |
| `server-config/` | server settings for this app (port 5050, 6 attempts) |

## Get it

```bash
git clone --recursive <this repo>
```

Without `--recursive`, `server/` and `client/` are empty. Fix with `git submodule update --init`.

## Play

```bash
./play.sh          # graphical client (needs tkinter)
./play.sh cli      # terminal client
```

Starts the server if it isn't running (Docker, or Go if Docker is off), then the client. The server stops when the client closes, unless it was already running. In the GUI, uncheck "Connexion chiffrée (TLS)".

## Run by hand

```bash
docker compose up -d                  # server on port 5050
docker compose run --rm client        # terminal client, in Docker
```

GUI (needs Python with tkinter, outside Docker):

```bash
python3 client/gui.py                 # server 127.0.0.1, port 5050
```

Stop: `docker compose down`

## Update server and client

```bash
git submodule update --remote
git commit -am "Update submodules"
```

Dependabot opens this pull request automatically every day when either repo has new commits.
