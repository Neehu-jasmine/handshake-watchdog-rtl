# Handshake Watchdog RTL

A small, parameterized RTL design that monitors a `valid/ready` handshake and detects when a transaction remains stalled for too long.

Designed and verified using **Verilog HDL** and **Xilinx Vivado simulation**.

## Overview

In a typical `valid/ready` interface:

- `valid = 1` means the sender has a valid transaction.
- `ready = 1` means the receiver can accept it.
- A transfer occurs when both are HIGH.

This project adds a watchdog that monitors the waiting period.

If `valid` remains HIGH while `ready` stays LOW for the configured number of clock cycles, the watchdog asserts `timeout`.

```text
                Handshake Watchdog
                       │
       ┌───────────────┼───────────────┐
       │               │               │
      clk            valid            ready
       │               │               │
       ▼               ▼               ▼
   ┌──────────────────────────────────────┐
   │                                      │
   │        Valid / Ready Monitor         │
   │                 │                    │
   │                 ▼                    │
   │          Wait Cycle Counter          │
   │                 │                    │
   │                 ▼                    │
   │          Timeout Detection           │
   │                                      │
   └──────────────┬───────────────┬───────┘
                  │               │
                  ▼               ▼
               timeout        handshake
