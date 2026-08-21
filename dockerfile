FROM python:3.11

WORKDIR /app

COPY . .

Run pip install --no-cache-dir -r requirments.txt

EXPOSE 5000

CMD [ "python" , "app.py"]