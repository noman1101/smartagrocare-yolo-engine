# 1. Lock to the highly stable Debian 'Bookworm' OS
FROM python:3.11-slim-bookworm

# 2. Set the working directory
WORKDIR /app

# 3. Use the updated Linux package names (libgl1 instead of mesa)
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy your requirements file
COPY requirements.txt .

# 5. Install the Python libraries
RUN pip install --no-cache-dir -r requirements.txt

# 6. Destroy the broken OpenCV and force the headless version
RUN pip uninstall -y opencv-python opencv-python-headless
RUN pip install opencv-python-headless

# 7. Copy the rest of your app's code
COPY . .

# 8. Start the FastAPI server using Railway's dynamic port
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
