
# ⚡ Scikit Embedded Machine Learning on STM32 (Barebones Footprint)

This project demonstrates real-time anomaly detection on STM32 using **scikit-learn SVM**, **live voltage sampling**, and **TensorFlow autoencoder validation**, all running on a **bare-metal STM32F4** (no HAL, no stdlib) with a **minimal binary footprint**.

It includes:

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
2. Flash the board
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
  * Launch `gdb-multiarch` with `gdbscript`
  * Flash and start the board automatically

---

## 🧪 Python Scripts

| File                | Purpose                                              |
| ------------------- | ---------------------------------------------------- |
| `train_keras.py`    | Train autoencoder on live data + known anomalies     |
| `test_live.py`      | Run inference on captured data using `voltage.keras` |
| `bfr_local.py`      | Automates OpenOCD and GDB flashing/debug             |
| `voltage.keras`     | Keras autoencoder model (for validation)             |
| `voltage_stats.npz` | Mean/std for normalization (used by `test_live.py`)  |
| `ecg.csv`           | Optional anomaly data to mix in with training        |

---

## 📦 Project Structure

```
├── Makefile
├── main.c                 # Core app logic
├── bfr_local.py           # Automated debug/flash
├── gdbscript              # GDB commands
├── ecg.csv                # Anomaly data
├── live.txt               # Captured UART output
├── test_live.py           # Python inference with TensorFlow
├── train_keras.py         # Model trainer
├── voltage.keras          # Trained autoencoder model
├── voltage_stats.npz      # Normalization stats
├── STM32CubeIDE_project/  # Zipped project files
```

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
