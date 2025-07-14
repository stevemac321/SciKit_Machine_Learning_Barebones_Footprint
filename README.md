
# ⚡ Scikit Embedded Machine Learning on STM32 (Barebones Footprint)

## Real-Time ML Inference on STM32 (Bare-Metal)

This project demonstrates real-time anomaly detection on STM32 using:

- **scikit-learn SVM**
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
> The Makefile setup also integrates flashing and debugging via `OpenOCD`, `st-flash`, and GDB server — useful for streamlined automation and lean deployments.
>
> I’ll be releasing a video walkthrough soon — there are quite a few setup steps, and visual guidance will help pull it all together.

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

   * Use `LOG_ONLY` mode to log live data via UART
   * Capture output with TEXaS reader or PuTTY (Windows) or `screen` (Linux)
3. **Training**:

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

* Import the project `.ioc` or use zipped IDE files
* Builds to `Debug/` directory
* Works as-is

### ✅ Makefile Build (Much Smaller ELF)

* **Windows**:

  * Install [ARM GNU Toolchain (14.3.rel1 MinGW)](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
  * Open Git Bash
  * `make`

* **Linux**:

  * Requires `arm-none-eabi-gcc`, `make`
  * `make`

* **Note**: Makefile builds output directly to the project root, not `Debug/`

---

## ▶️ Running and Capturing Output

### Option 1: UART Logging Mode

1. Define macro `LOG_ONLY` (in `main.c`)
2. Flash the board (more on that below if not using IDE).
3. Use serial terminal to capture output:

   * **Windows**: TEXaS, PuTTY
   * **Linux**: `screen /dev/ttyACM0 115200`
4. Save log as `live.txt` to use with `test_live.py` or training scripts

### Option 2: Automated Run with GDB/OpenOCD

* Run:

  ```bash
  python bfr_local.py
  ```
* This will:

  * Start `openocd`
  * Launch `gdb-multiarch` with `gdbscript` (or arm-none-eabi-gdb for windows).
  * Flash and start the board automatically
Absolutely — here’s a README snippet that wraps up everything you just wrangled, clean and ready to drop into your repo:

```markdown
## Flashing and Debugging STM32 on Windows

This project supports firmware flashing and live debugging of STM32F4 devices using either `st-flash` or `OpenOCD`. Here's how the setup works:

### ✅ Toolchain Overview
- `st-flash`: A lightweight STM32 flasher. Installed to `C:\Program Files (x86)\stlink\bin\st-flash.exe`.
- `OpenOCD`: Full-featured debugger and flasher, used for GDB sessions and direct flashing.
- `STM32_Programmer_CLI`: Optional — bundled with STM32CubeIDE for flashing via ST-Link if other tools fail.

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

---

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

## 📈 Future Improvements

* Add onboard threshold tuning via UART or pin inputs
* Optionally support micro-TensorFlow Lite if memory allows
* Add CLI interface to training/inference pipeline

---

License GPL v.2
