# STM32F407 ARM Assembly Course

**Board:** GlobalLogic GL-SK-BSP (STM32F407VGT6)  
**Toolchain:** VS Code + GNU ARM Toolchain + OpenOCD  
**ISA:** ARM Thumb-2 Assembly (Cortex-M4)

---

## Repository Structure

```text
stm32f407-asm-course/
├── core/
│   ├── startup.s           ← vector table + reset handler
│   └── stm32f407.ld        ← linker script
│
├── .vscode/
│   ├── launch.json         ← Cortex-Debug configuration
│   ├── tasks.json          ← build / flash / clean tasks
│   ├── settings.json       ← editor settings
│   └── STM32F407.svd       ← peripheral register description
│
├── examples/               ← examples from lectures/videos
│   ├── mov_operations/
│   ├── add_sub_operations/
│   └── memory_layout/
│
├── labs/                   ← student labs
│   └── lab01/
│
├── build/                  ← generated files: ELF, BIN, MAP, current.elf
│
└── Makefile
```

---

## Environment Setup

### Step 1 — GNU ARM Embedded Toolchain

**Linux (Ubuntu/Debian):**

```bash
sudo apt update
sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi gdb-multiarch make
```

**macOS:**

```bash
brew install arm-none-eabi-gcc make
```

**Windows:**

1. Download from [ARM Developer](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
2. Install and add to PATH: `C:\Program Files (x86)\GNU Arm Embedded Toolchain\bin`
3. Install [Make for Windows](https://gnuwin32.sourceforge.net/packages/make.htm)

Verify:

```bash
arm-none-eabi-gcc --version
```

---

### Step 2 — OpenOCD

OpenOCD connects to the ST-Link on the board and exposes a GDB server.

**Linux:**

```bash
sudo apt install openocd
```

If you use a custom OpenOCD installation, check its path:

```bash
which openocd
```

For this course setup, the tested OpenOCD path is:

```text
/opt/openocd/bin/openocd
```

This path is explicitly used in `.vscode/launch.json`:

```json
"serverpath": "/opt/openocd/bin/openocd"
```

**macOS:**

```bash
brew install open-ocd
```

**Windows:** Download from [OpenOCD releases](https://github.com/openocd-org/openocd/releases), add `bin/` to PATH.

Verify:

```bash
openocd --version
```

---

### Step 3 — VS Code + Extensions

1. Install [Visual Studio Code](https://code.visualstudio.com/)
2. Open the root `stm32f407-asm-course/` folder in VS Code
3. Accept the prompt to install recommended extensions, or install manually:

   * **Cortex-Debug** (`marus25.cortex-debug`) — register / peripheral / memory panels
   * **ARM Assembly** (`dan-c-underwood.arm`) — syntax highlighting
   * **Linker Script** (`zixuanwang.linkerscript`) — `.ld` syntax highlighting

---

### Step 4 — SVD File (Peripherals Panel)

The SVD file describes every peripheral register of the STM32F407 in human-readable form.
It enables the **PERIPHERALS** panel in VS Code: GPIO, RCC, USART, timers, etc.

1. Download `STM32F407.svd` from:
   https://raw.githubusercontent.com/cmsis-svd/cmsis-svd-data/main/data/STMicro/STM32F407.svd
2. Place it at:

```text
.vscode/STM32F407.svd
```

---

## Build and Flash

All commands are run from the repository root. Pass `PROJECT=` with the path to the target project.

### Build

```bash
make PROJECT=examples/mov_operations
make PROJECT=examples/add_sub_operations
make PROJECT=labs/lab01
```

After each successful build, the selected project ELF is also copied to:

```text
build/current.elf
```

VS Code always debugs this file.

### Flash

```bash
make flash PROJECT=examples/mov_operations
```

### Start OpenOCD server manually

This is mainly for terminal debugging:

```bash
make openocd
```

### Start GDB session manually

OpenOCD must already be running in another terminal:

```bash
make debug PROJECT=examples/mov_operations
```

Successful build output example:

```text
AS  examples/mov_operations/main.s
AS  core/startup.s
LD  build/mov_operations/mov_operations.elf
BIN build/mov_operations/mov_operations.bin

   text    data     bss     dec     hex filename
     92       0       0      92      5c build/mov_operations/mov_operations.elf
```

---

## Debug — VS Code

This is the recommended debugging workflow.

1. Open the root `stm32f407-asm-course/` folder in VS Code
2. Press **F5**
3. VS Code runs the `build` task first
4. Select the project from the dropdown
5. The project is built and copied to:

```text
build/current.elf
```

6. Cortex-Debug starts OpenOCD automatically
7. GDB connects to OpenOCD
8. Execution halts at `main`

The debug configuration uses:

```json
"serverpath": "/opt/openocd/bin/openocd",
"executable": "${workspaceFolder}/build/current.elf"
```

Do not run `make openocd` or `make debug` manually when using the normal VS Code `F5` workflow.

Panels available during debug:

| Panel           | Contents                            |
| --------------- | ----------------------------------- |
| **REGISTERS**   | r0–r15, PC, SP, LR, xPSR            |
| **PERIPHERALS** | GPIO, RCC, USART, etc. Requires SVD |
| **MEMORY**      | Inspect any memory address          |
| **DISASSEMBLY** | Live disassembly                    |

| Action    | Key               |
| --------- | ----------------- |
| Step Over | F10               |
| Step Into | F11               |
| Continue  | F5                |
| Stop      | Shift + F5        |
| Restart   | Ctrl + Shift + F5 |

---

## Debug — Terminal (GDB)

This is the manual debugging workflow. Use it when you want to see OpenOCD and GDB separately.

Open two terminals.

**Terminal 1 — start OpenOCD:**

```bash
make openocd
```

Leave this terminal open. It should print:

```text
Listening on port 3333 for gdb connections
```

**Terminal 2 — start GDB:**

```bash
make debug PROJECT=examples/mov_operations
```

The `debug` target automatically runs:

```gdb
target extended-remote localhost:3333
monitor reset halt
load
monitor reset halt
```

### Useful GDB commands

```gdb
info registers
si
continue
disassemble
```

### TUI Mode

`layout regs` opens a split view directly in the terminal: registers on top, disassembly on the bottom, with an arrow pointing at the current instruction.

```gdb
layout regs
break main
continue
si
```

---

### Tasks (Ctrl + Shift + B)

Without entering debug mode, you can run build, flash and clean directly from VS Code via:

```text
Ctrl + Shift + B
```

or:

```text
Terminal → Run Task
```

A dropdown lets you select the full project path, for example:

```text
examples/mov_operations
examples/add_sub_operations
labs/lab01_basic_operations
```

The selected path is passed to Make as:

```bash
make PROJECT=<selected-project>
```

---

## Submitting Labs (GitHub Classroom)

1. Follow the assignment link provided by the instructor
2. GitHub Classroom creates a **private repository in your account** automatically
3. Clone your repository:

```bash
git clone https://github.com/YOUR_USERNAME/lab01-basic-operation-YOUR_NAME
```

4. Complete the assignment
5. Push when ready:

```bash
git add .
git commit -m "Lab01: Add basic operation assembly code"
git push
```

Required files per lab:

* `main.s` — commented source code
* `README.md` — lab report with explanation and screenshot
* `screenshots/debug_registers.png` — register panel during execution

The instructor will review and approve via GitHub.

---

## Troubleshooting

**`arm-none-eabi-gcc: command not found`**
Toolchain is not in PATH. On Windows check Environment Variables. On Linux run:

```bash
echo $PATH
```

---

**`gdb-multiarch: command not found`**
Install it:

```bash
sudo apt install gdb-multiarch
```

On macOS, use `arm-none-eabi-gdb` and update `gdbPath` in `.vscode/launch.json`.

---

**VS Code: `spawn arm-none-eabi-gdb ENOENT`**
GDB binary name differs on your system. Change `.vscode/launch.json`:

```json
"gdbPath": "gdb-multiarch"
```

or, if available:

```json
"gdbPath": "arm-none-eabi-gdb"
```

---

**VS Code: OpenOCD starts manually but fails from Cortex-Debug**

Check which OpenOCD works in the terminal:

```bash
which openocd
```

If the working OpenOCD is installed at:

```text
/opt/openocd/bin/openocd
```

then `.vscode/launch.json` must contain:

```json
"serverpath": "/opt/openocd/bin/openocd"
```

This forces Cortex-Debug to use the same OpenOCD binary that works in the terminal.

---

**OpenOCD cannot find the board**
Install ST-Link drivers. On Linux add udev rules:

```bash
sudo cp /usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Then reconnect the board.

---

**OpenOCD: `GDB Server Quit Unexpectedly`**

Another OpenOCD or GDB session may still be running. Stop old debug processes:

```bash
pkill -9 openocd
pkill -9 gdb-multiarch
```

Then press `F5` again in VS Code.

When using the normal VS Code workflow, do not run `make openocd` or `make debug` manually at the same time.

---

**Wrong project path**

Use the full project path without a trailing slash:

```bash
make PROJECT=examples/mov_operations
```

Correct:

```bash
make PROJECT=examples/mov_operations
```

Incorrect:

```bash
make PROJECT=examples/mov_operations/
```

The Makefile removes trailing slashes, but it is still better to avoid them.

---

**VS Code: `build/current.elf` not found**

Run build first:

```bash
make PROJECT=examples/mov_operations
```

or press `Ctrl + Shift + B` in VS Code and select a project.

`build/current.elf` is generated automatically after every successful build.

---

**VS Code does not show REGISTERS panel**
Make sure **Cortex-Debug** extension is installed and `.vscode/launch.json` uses:

```json
"type": "cortex-debug"
```

---

**Program does not run after flashing**

Check that the vector table is placed in Flash:

```bash
arm-none-eabi-objdump -h build/current.elf
arm-none-eabi-objdump -s -j .vectors build/current.elf
```

The vector table must be located at the beginning of Flash memory, starting at `0x08000000`.

---

**HardFault immediately on startup**
Most likely cause: missing `+1` on function addresses in the vector table. Check `core/startup.s`:

```asm
.word  Reset_Handler + 1
```

The `+1` marks the handler address as a Thumb function address.

---

**OpenOCD: `Error: open failed` or `libusb_open() failed`**
Another process may be using the ST-Link. Stop old OpenOCD processes:

```bash
pkill -9 openocd
```

Then reconnect the board.

---

## References

* [STM32F407 Reference Manual RM0090](https://www.st.com/resource/en/reference_manual/dm00031020-stm32f405-415-stm32f407-417-stm32f427-437-and-stm32f429-439-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf)
* [ARM Cortex-M4 Technical Reference Manual](https://developer.arm.com/documentation/100166/latest)
* [ARMv7-M Architecture Reference Manual](https://developer.arm.com/documentation/ddi0403/latest)
* [GNU Assembler (GAS) Manual](https://sourceware.org/binutils/docs/as/)
* [Cortex-Debug Wiki](https://github.com/Marus/cortex-debug/wiki)
