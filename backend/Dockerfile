FROM python:3.12-slim

WORKDIR /app

# Install system dependencies (e.g., for audio processing if needed)
RUN apt-get update && apt-get install -y \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Expose port
EXPOSE 8000

# Run command
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
