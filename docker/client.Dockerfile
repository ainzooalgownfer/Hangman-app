# Terminal client (client.py). The tkinter GUI (gui.py) needs a display,
# so it runs outside Docker: python3 gui.py
FROM python:3.13-slim
WORKDIR /app
COPY client.py .
ENTRYPOINT ["python3", "client.py"]
CMD ["server", "5050"]
