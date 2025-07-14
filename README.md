
# ⚡ Scikit Embedded Machine Learning on STM32 (Barebones Footprint)

## Real-Time ML Inference on STM32 (Bare-Metal)

This project demonstrates real-time anomaly detection on STM32 using:

- **scikit-learn SVM** (Overview from ARM: https://developer.arm.com/documentation/102052/0100/Train-an-SVM-classifier-with-scikit-learn).
- **Live voltage sampling**
- **TensorFlow autoencoder validation**

All of this runs on a **bare-metal STM32F4** — no HAL, no stdlib — with an emphasis on keeping the **binary footprint minimal**.

---

> **NOTE**: There are four main ways to approach this:
>
> 1. **STM32CubeIDE (Windows or Linux)** — The easiest way to get started, especially for evaluating ML workflows quickly.
> 2. **Makefile-based builds (Linux)** — Best on systems like Ubuntu; setup is simple with `sudo apt install`.
> 3. **Makefile-based builds (Windows)** — Requires manual steps like installing DLLs locally and setting environment variables.
> 4. **Hybrid workflow** — The Makefile build lives alongside the IDE project, allowing for cleaner binaries and finer control over the toolchain.
>
> ** RECOMMENDATION:** if you have Linux, follow the LINUX: Step-by-step Install for STM32 Development Environment (Ubuntu ) below.
> 
> The Makefile setup also integrates flashing and debugging via `OpenOCD`, `st-flash`, and GDB server — useful for streamlined automation and lean deployments.
>
> **I’ll be releasing a video walkthrough soon for the Linux scenario** — there are quite a few setup steps, and visual guidance will help pull it all together.

* Embedded machine learning inference with hand-coded SVM support (trained via `scikit-learn`)
* Optional verification using a trained Keras autoencoder (`voltage.keras`)
* Real-time UART logging for data capture
* Dual support: STM32CubeIDE *and* Makefile builds on Linux and Windows (Git Bash + MinGW)
* Automated GDB/OpenOCD workflow for debugging and reflashing

---

## 🔧 Project Features

* **Platform**: STM32F4 series MCU (tested on STM32F401)
* **Toolchains**:

  * `STM32CubeIDE` on Windows and Linux (Debug mode)
  * `Makefile` build with `arm-none-eabi-gcc` for a much smaller `.elf` (\~5–10× smaller)
* **No HAL, No stdlib**: Uses CMSIS and DSP directly
* **ML Engine**: SVM inference from `scikit-learn` trained model
* **Keras Validation**: TensorFlow autoencoder anomaly detection in Python (`test_live.py`)
* **UART Output**: Raw voltage data, for offline model training or real-time validation

---

## 🧠 Machine Learning Pipeline

1. **Live voltage sampling** on the STM32 (ADC to buffer)
2. **Training data collection**:
   * see https://developer.arm.com/documentation/102052/0100/Train-an-SVM-classifier-with-scikit-learn for using scikit-learn, but I have a training SVM model included in the project to see demo the ML.
   * Use `LOG_ONLY` mode to log live data via UART
   * Capture output with TEXaS reader or PuTTY (Windows) or `screen` (Linux) there are several.
3. **Training**:
   * 
   * `train_keras.py`: Trains a Keras autoencoder on live + known-anomaly data
   * Includes ECG anomaly data from TensorFlow's official tutorial (`ecg.csv`)
   * Saves model as `voltage.keras` + normalization stats
4. **Validation**:

   * `test_live.py`: Runs TensorFlow inference on captured data to verify embedded SVM
5. **Embedded Inference**:

   * SVM runs on STM32 using raw voltage samples in real-time

---

## 🔨 Building

### ✅ STM32CubeIDE (Windows/Linux)

* use zipped ProjectFiles files
* Builds to `Debug/` directory
* Works as-is

### ✅ Makefile Build (Much Smaller binaries)

* **Windows**:

  * Install [ARM GNU Toolchain (14.3.rel1 MinGW)](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
  * Get OpenOCD and ST-Link for Windows (On windows I prefer ST-Util for debug session, st-flash for the Makefile flash)
  * https://gnutoolchains.com/arm-eabi/openocd/
  * https://www.st.com/en/development-tools/stsw-link004.html
  * https://github.com/libusb/libusb/wiki/Windows
  * Open Git Bash (install git for windows)
  * `make`
## Flashing and Debugging STM32 on Windows

This project supports firmware flashing and live debugging of STM32F4 devices using either `st-flash` or `OpenOCD`. Here's how the setup works:

### ✅ Toolchain Overview
- `st-flash`: A lightweight STM32 flasher. Installed to `C:\Program Files (x86)\stlink\bin\st-flash.exe`.
- `OpenOCD`: Full-featured debugger and flasher, used for GDB sessions and direct flashing.


### 🛠️ Setting Up `st-flash` on Windows
If using `st-flash`, ensure these dependencies are in place:

1. **Install `st-flash.exe`**  
   Install to:  
   ```
   C:\Program Files (x86)\stlink\
   ```

2. **Patch missing config directory**  
   Create:
   ```
   C:\Program Files (x86)\stlink\config\chips\
   ```
   And place `.chip` definitions inside (e.g. `F411xC_xE.chip`) if not already present.

3. **Install `libusb-1.0.dll`**  
   Download from [libusb.info](https://libusb.info)  
   → Extract `libusb-1.0.dll` from:
   ```
   libusb-1.0.29\MinGW64\dll\
   ```
   → Place next to `st-flash.exe` or in a PATH directory.

4. **Troubleshooting ST-Link detection**
   - Use USB 2.0 port if ST-Link isn’t recognized
   - Check Device Manager for proper driver (install [STSW-LINK009](https://www.st.com/en/development-tools/stsw-link009.html) if needed)

### 🔁 Flashing with OpenOCD

To flash from console:

```bash
openocd -s /c/tools/OpenOCD/share/openocd/scripts \
        -f interface/stlink.cfg \
        -f target/stm32f4x.cfg \
        -c "program BareBones.bin 0x08000000 verify reset exit"
```

To start GDB server:

```bash
openocd -s /c/tools/OpenOCD/share/openocd/scripts \
        -f interface/stlink.cfg \
        -f target/stm32f4x.cfg
```

Then attach from GDB with:
```bash
arm-none-eabi-gdb BareBones.elf
(gdb) target remote localhost:3333
```

# 🛠️ LINUX: Step-by-step Install for STM32 Development Environment (Ubuntu )

# 1. Update Package Lists
sudo apt update

# 2. Install Core Build Tools
sudo apt install build-essential make

# 3. Install Python Tools
sudo apt install python3-pip python3-venv

# 4. Install USB and Device Libraries
sudo apt install libusb-1.0-0-dev libhidapi-dev libudev-dev

# 5. Install ARM Cross Compiler
sudo apt install gcc-arm-none-eabi

# 6. Install ST-Link Tools
sudo apt install stlink-tools

# 7. Install OpenOCD (GDB server & debugger)
sudo apt install openocd

# 8. Install GDB with Multi-Arch Support
sudo apt install gdb-multiarch

# 9. Install a com port reader that you can copy or save to log, I am using: 
sudo apt install cutecom
It does require xwindows, I use ssh with MobaxTerm and x11 forwarding, works great

# ✅ Optional: Install STM32CubeIDE (Graphical IDE from STMicroelectronics)

# Download CubeIDE .deb package (adjust version as needed)
wget https://www.st.com/content/ccc/resource/technical/software/sw_development_suite/group0/77/50/78/29/a4/5e/4c/f7/stm32cubeide_latest/files/stm32cubeide_1.14.0_amd64.deb.zip

# Unzip the package
unzip stm32cubeide_1.14.0_amd64.deb.zip

# Install using dpkg (may take a few minutes)
sudo dpkg -i stm32cubeide_1.14.0_amd64.deb

# Resolve any missing dependencies
sudo apt --fix-broken install
* **Note**: Makefile builds output directly to the project root, not `Debug/`

---

## ▶️ Running and Capturing Output

### Option 1: UART Logging Mode

1. Define macro `LOG_ONLY` (in `main.c`)
2. Flash the board (more on that below if not using IDE).
3. Use serial terminal to capture output:

   * **Windows**: TEXaS, PuTTY
   * **Linux**: `screen /dev/ttyACM0 115200`
4. Save log if you want to run the TensorFlow Inference (see instructions below)

### Option 2: Automated Run with GDB/OpenOCD or ST-Util

* Run:

  ```bash
  python bfr_local.py
  ```
* This will:

  * Start `openocd`
  * Launch `gdb-multiarch` with `gdbscript` (or arm-none-eabi-gdb for windows, I use st-util, gdbscript_windows).
  * Flash and start the board automatically

```markdown


This setup keeps runtime lean and avoids GUI dependencies. OpenOCD handles debug sessions, while flashing is optional — either tool works, depending on your workflow.
```
---
Project Structure:
Core/ – C source code for STM32 firmware.

Drivers.zip – Official STM32 device drivers (optional if using CubeIDE).

Keras.zip – Python tools:

train_keras.py, test_live.py for Keras model

Training data (live voltage + anomaly samples)

Saved model (voltage.keras)

Supporting Makefile, linker scripts, and flash utilities

ProjectFiles/ – STM32CubeIDE project files (optional; for GUI users)

---

## 💡 Notes

* Use `LOG_ONLY` to print 128-sample voltage windows (whitespace-separated) for training
* You can retrain your own Keras model using those logs
* The embedded SVM is fixed-point friendly and very lightweight
* You can tweak SVM threshold from training output if needed

---
Absolutely, Stephen — here's a clear and concise **“Running Inference”** section tailored to your Keras setup:

---

## 🧪 Compare SciKit-Learn results with TensorFlow Keras Model  

Once your model (`voltage.keras` is already trained) is trained, you can evaluate new data through the inference script `test_live.py`. This script loads `live.txt`, which contains raw voltage data captured from your COM port reader.

### 🔍 Step-by-Step Inference Flow
1. **Prepare Input**  
   The sample `live.txt` cam be refreshed by running the embedded ap in LOG_ONLY mode which prints new voltage samples to the com port reader.  (See above Running and Capturing Output). Save that to 'live.txt'.

2. **Run the Script**  
   Execute the test script from within the Keras project directory:
   ```bash
   python3 test_live.py
   ```

3. **Model Loading**  
   Inside `test_live.py`, the trained model `voltage.keras` is automatically loaded. You can verify this in the script using:
   ```python
   model = keras.models.load_model("voltage.keras")
   ```

4. **Prediction**  
   The input is processed and passed through the model to generate predictions. These may indicate normal vs anomaly based on thresholds established during training.

5. **Interpret Output**  
   The script should print or log inference results — e.g., classification labels, confidence scores, or anomaly flags. If you want to visualize or post-process them, consider extending the script with matplotlib or saving outputs to a file.

---

Let me know if you'd like to refine how the output is presented or make it stream live from the COM port for real-time evaluation. I can help tweak your script to support that next.



---

License GPL v.2
