# Server Performance Stats Analyzer

A comprehensive bash script to analyze server performance statistics on Linux systems.

## Features

### Core Requirements
- ✅ Total CPU usage
- ✅ Total memory usage (Free vs Used including percentage)
- ✅ Total disk usage (Free vs Used including percentage)
- ✅ Top 5 processes by CPU usage
- ✅ Top 5 processes by memory usage

### Stretch Goals (Bonus Features)
- ✅ OS version and kernel information
- ✅ System uptime
- ✅ Load average (1, 5, 15 minutes)
- ✅ Currently logged in users
- ✅ Failed login attempts
- ✅ Swap memory usage
- ✅ Multiple filesystem monitoring
- ✅ Color-coded output for better readability

## Usage

### On Linux Server

1. Make the script executable:
```bash
chmod +x server-stats.sh
```

2. Run the script:
```bash
./server-stats.sh
```

### For Root-Level Metrics

Some metrics (like failed login attempts) require root privileges:
```bash
sudo ./server-stats.sh
```

## Output Sections

The script provides organized output in the following sections:

1. **System Information**
   - OS version and kernel
   - Hostname
   - System uptime
   - Load average

2. **CPU Usage**
   - Total CPU usage percentage
   - Number of CPU cores

3. **Memory Usage**
   - Total, used, and free memory
   - Memory usage percentage
   - Swap usage (if available)

4. **Disk Usage**
   - All mounted filesystems
   - Total size, used space, and available space
   - Color-coded warnings (red >90%, yellow >70%)

5. **Top 5 Processes by CPU Usage**
   - PID, user, CPU percentage, and command

6. **Top 5 Processes by Memory Usage**
   - PID, user, memory percentage, and command

7. **User Information**
   - Currently logged in users
   - Active sessions
   - Failed login attempts (requires root)

## Requirements

- Linux operating system
- Bash shell
- Standard utilities: `top`, `free`, `df`, `ps`, `who`, `uptime`

## Color Coding

- 🟢 Green: Normal/healthy status
- 🟡 Yellow: Warning (70-90% usage)
- 🔴 Red: Critical (>90% usage)
- 🔵 Blue: Section headers
- 🔷 Cyan: Main headers

## Notes

- The script is designed to work on any Linux distribution
- Some metrics may require root privileges for full access
- Failed login attempts are read from `/var/log/auth.log` or `/var/log/secure`
- The script uses color output for better readability in terminal

## Troubleshooting

If you encounter permission issues:
```bash
sudo ./server-stats.sh
```

If the script doesn't run:
```bash
bash server-stats.sh
```

## License

Free to use and modify for server monitoring purposes.
