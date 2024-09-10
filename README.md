#read me is made by AI
# ssysi (Small System Information)

**ssysi** is a simplified, lightweight system information tool. The goal of this project is to provide essential system information in a minimal package, under 10KB, while retaining useful and practical features for everyday system monitoring.

## Key Features

- **Minimalist Design**: Under 10KB in size, making it fast and resource-efficient.
- **Essential System Stats**:
  - CPU model, core count, and thread count.
  - Memory usage and swap statistics.
  - Disk usage and mounted drives.
  - System uptime and kernel information.
  - Battery status (if applicable).
- **User-Friendly Output**: Information is presented in a clean, formatted, and color-coded way to improve readability.
- **Lightweight & Fast**: No unnecessary overhead, designed for speed and low resource usage.
- **Terminal-Friendly**: Runs seamlessly in the terminal, with centered text for a polished look.

## Displayed Information

1. **System Information**:
   - OS, hostname, model
   - Kernel version, uptime
   - Screen resolution

2. **CPU Information**:
   - Model name, core count, and thread count

3. **Memory & Swap Usage**:
   - Memory and swap usage percentages

4. **Disk Usage & I/O Statistics**:
   - Disk usage for root (`/`)
   - Mounted drives and their usage
   - I/O stats (read/write speeds)

5. **Battery Status** (optional):
   - Current charge and state

6. **Top Processes**:
   - Processes ranked by CPU and memory usage

## How It Works

- **Color Formatting**: Uses ANSI escape codes for background colors and clear text presentation.
- **Centered Text**: Outputs all information neatly centered in the terminal for readability.
- **Efficient Parsing**: Uses lightweight commands like `awk`, `ps`, `df`, and `free` for data collection.
  
## Example Usage

Running the script will display a concise overview of your system's current state, such as:

```bash
   Operating System: EndeavourOS
                          Host: zdislav-asus
                         Model: ASUSTeK X509MA
  Logged-in Users  22:27:49 up  5:05,  2 users,  load average: 3.20, 2.13, 1.29
              USER     TTY       LOGIN@   IDLE   JCPU   PCPU  WHAT
 zdislav            17:24    2.00s  0.00s  0.02s lightdm --session-child 13 20
zdislav            17:24    2.00s  0.00s  0.51s /usr/lib/systemd/systemd --user
                           Kernel Name: Linux
                    Kernel Version: 6.10.8-arch1-1 
  Kernel Release: #1 SMP PREEMPT_DYNAMIC Wed, 04 Sep 2024 15:16:37 +0000
                    Resolution: 1920x1080     60.03*
                     Uptime : up 5 hours, 5 minutes
                     Memory: 2.5G / 8.1G (30.53%)
                       Swap: 0B / 9.4G (0.00%)
             CPU: Intel(R) Celeron(R) N4020 CPU @ 1.10GHz
                             CPU Cores: 2
                            CPU Threads: 2
                      Top Processes by CPU Usage
```
