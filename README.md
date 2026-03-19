# Systolic-Array
# RTL Matrix Multiplication Accelerator (4×4)

## Overview
This project implements a **4×4 matrix multiplication accelerator** using **Verilog HDL** on **Vivado ML Standard**.

Two architectures are designed:
- **Sequential Architecture** – low area, higher latency  
- **Parallel Systolic Array** – high performance, higher area  

---

## Objective
- Design a hardware accelerator for matrix multiplication  
- Implement and compare sequential and parallel architectures  

---

## Specifications

| Parameter    | Value                   |
|--------------|------------------------|
| Input Width  | 8-bit unsigned         |
| Output Width | 20-bit accumulator     |
| Clock        | Single synchronous     |
| Reset        | Active-low (`rst_n`)   |

---

## Architecture

### Processing Element (PE)
- Multiply-Accumulate (MAC) unit  
- Signals:
  - `en` – enable computation  
  - `clear_acc` – reset accumulator  

---

### Sequential Engine (`matmul_seq`)
- Uses a single PE  
- Computes all outputs sequentially  
- Low area, higher latency  

---

### Parallel Engine (`matmul_par`)
- 4×4 systolic array (16 PEs)  
- Parallel computation  
- High throughput, higher area  

---

### Memory Buffer
- Stores input matrices (A, B) and output (C)  
- Interfaces with both architectures  

---

### Top Module (`matrix_top`)
- Integrates both engines  
- Select signal to choose architecture  

---

## Hardware Output (7-Segment)

- Output: 20-bit value (one element at a time)  
- Converted to decimal using **Double Dabble (Shift-Add-3)**  
- Displayed using a **7-segment decoder**  

---

## 📂 Structure
