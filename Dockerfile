# 1. Use the official, stable Python 3.11 Linux image
FROM python:3.11-slim

# 2. Set the working directory inside the cloud server
WORKDIR /app

# 3. Force the exact C++ graphical libraries to install flawlessly
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libxcb1 \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy your requirements file
COPY requirements.txt .

# 5. Install the Python libraries (PyTorch, FastAPI, etc.)
RUN pip install --no-cache-dir -r requirements.txt

# 6. SURGICAL FIX: Destroy the broken OpenCV and force the headless version
RUN pip uninstall -y opencv-python opencv-python-headless
RUN pip install opencv-python-headless

# 7. Copy the rest of your app's code (main.py, best.pt)
COPY . .

# 8. Start the FastAPI server using Railway's dynamic port
CMD uvicorn main:app --host 0.0.0.0 --port $PORT
