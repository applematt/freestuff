# 💾 AI IM (AIIM) Client Installation Guide

Follow these steps to set up and run your retro-styled offline AI assistant and its text-scraping utilities.

---

### 📋 Prerequisites

Before starting, ensure you have the following installed on your system:
* 🐍 **Python 3.8+**
* 🦙 **Ollama** (Running locally)

---

### 🚀 Step-by-Step Installation

#### 1. Download Required Models 📥
Open your terminal and pull the mandatory models used by the client for processing data and chatting:
```bash
ollama pull llama3.1
ollama pull nomic-embed-text
```

#### 2. Install Python Dependencies ⚙️
Install the combined libraries required for UI formatting, document loading, audio effects, web scraping, and text PDF compilation:
```bash
pip install requests playsound langchain-text-splitters langchain-ollama langchain-community chroma-db bs4 pypdf textual rich fpdf2
```

#### 3. Setup Sound Effects (SFX) 🔊
The application looks for theme sounds in a hidden local directory.
```bash
# Create the sound effects folder structure
mkdir -p ~/.aiim/sfx

# Move your downloaded .wav audio assets into the folder.
# Ensure filenames exactly match:
* mixkit-creaky-door-open-195.wav
* mixkit-creaky-closing-wood-door-189.wav
* mixkit-software-interface-start-2574.wav
* mixkit-software-interface-back-2575.wav
* mixkit-retro-game-notification-212.wav
* mixkit-computer-digital-lock-2859.wav
* mixkit-alert-bells-echo-765.wav
* mixkit-police-short-whistle-615.wav
```

#### 4. Place Your Scripts 📄
Save your provided Python scripts locally on your system:
* Main messenger app: `aiim-assistant.py`
* Stand-alone Web-to-PDF scraping utility: `tools/w2pdf.py`

#### 5. Run the Application 🎮
Launch the application wrapper directly from your terminal:
```bash
python3 aiim-assistant.py
```

---

### 🛠️ Operational Notes

* 🔒 **Secure Connection:** Upon launching `aiim-assistant.py`, the chat log will confirm a secure local connection.
* 🎛️ **Data Indexing:** Use the `Action Menu` dropdown at the top to ingest public websites, standalone `.pdf`/`.txt` files, or multi-line manifest lists into your local database.
* 💬 **Chatting:** Type your query into the input bar at the bottom and hit `Enter` to query your local AI offline.
