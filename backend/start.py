import subprocess
import sys
import os

print("🚀 Starting MamaSafe Backend Server...")
print("=" * 50)

# Change to api directory
api_dir = os.path.join(os.path.dirname(__file__), "api")
os.chdir(api_dir)

# Use base Python (not virtual environment)
python_exe = r"C:\Users\Djafari\AppData\Local\Programs\Python\Python312\python.exe"

print(f"Using Python: {python_exe}")
print(f"Working directory: {os.getcwd()}")
print("=" * 50)

# Start uvicorn
try:
    subprocess.run([
        python_exe, "-m", "uvicorn", 
        "main:app", 
        "--reload", 
        "--host", "0.0.0.0", 
        "--port", "8000"
    ])
except KeyboardInterrupt:
    print("\n\n✅ Server stopped")
