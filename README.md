# x86 Assembly File System Simulator

A low-level file system simulator implemented entirely in x86 Assembly language as part of Computer Architecture coursework. This project demonstrates sophisticated memory management, dynamic allocation algorithms, and file descriptor tracking using only assembly instructions.

## 📋 Project Overview

This file system simulator implements two storage models:
- **Cerinta 1**: 1D vector-based storage (4KB capacity, 1024 blocks)
- **Cerinta 2**: 2D matrix-based storage (4MB capacity, 1024x1024 blocks)

Both implementations support core file system operations with intelligent memory fragmentation handling and space optimization.

## ✨ Features

### Core Operations

1. **ADD** - Add file(s) with specified descriptors and sizes
   - First-fit allocation algorithm
   - Contiguous block search and allocation
   - Automatic memory capacity checking (max 1024 blocks per line/vector)
   - Returns file coordinates: `(start, end)` for 1D or `((row, col), (row, col))` for 2D

2. **GET** - Retrieve file location by descriptor
   - Search through allocated memory
   - Return file position range
   - Handle non-existent files gracefully

3. **DELETE** - Remove file by descriptor
   - Free allocated memory blocks (set to 0)
   - Maintain memory structure integrity

4. **DEFRAG** - Memory defragmentation
   - Compact allocated blocks
   - Eliminate fragmentation
   - Optimize memory usage

### Technical Highlights

- **Manual Memory Management**: Direct manipulation of memory blocks without OS abstractions
- **Register Optimization**: Efficient use of x86 registers (EAX, EBX, ECX, EDX, ESI, EDI, EBP)
- **Stack Operations**: Function call handling with proper stack management
- **Arithmetic Operations**: Division, multiplication for block size calculations
- **Loop Constructs**: Complex iteration patterns using jumps and labels
- **I/O Operations**: scanf/printf integration for user interaction

## 🛠️ Technology Stack

- **Language**: x86 Assembly (32-bit)
- **Assembler**: GAS (GNU Assembler) syntax
- **Architecture**: Intel x86 instruction set
- **System Calls**: Standard C library integration (scanf, printf, fflush)

## 📁 Project Structure

```
x86-FileSystem/
│
├── cerinta1.s          # 1D vector implementation (4KB storage)
├── cerinta2.s          # 2D matrix implementation (4MB storage)
└── README.md           # Project documentation
```

## 🚀 Getting Started

### Prerequisites

- GCC with 32-bit support
- Linux environment or compatible x86 assembler
- Basic understanding of x86 assembly language

### Compilation

```bash
# Compile cerinta1.s (1D version)
gcc -m32 cerinta1.s -o cerinta1

# Compile cerinta2.s (2D version)
gcc -m32 cerinta2.s -o cerinta2
```

### Execution

```bash
# Run 1D version
./cerinta1

# Run 2D version
./cerinta2
```

### Input Format

```
<number_of_operations>
<operation_code> [parameters]
```

**Operation Codes:**
- `1` - ADD: `1 <num_files> <descriptor1> <size1> <descriptor2> <size2> ...`
- `2` - GET: `2 <descriptor>`
- `3` - DELETE: `3 <descriptor>`
- `4` - DEFRAG: `4`

### Example Usage

```
5
1 2 100 64 200 128
2 100
3 200
1 1 300 256
4
```

**Explanation:**
1. Perform 5 operations
2. ADD: Add 2 files (descriptor 100 with 64 bytes, descriptor 200 with 128 bytes)
3. GET: Retrieve location of file with descriptor 100
4. DELETE: Remove file with descriptor 200
5. ADD: Add 1 file (descriptor 300 with 256 bytes)
6. DEFRAG: Defragment memory

### Output Format

**ADD Operation:**
```
<descriptor>: (start, end)                    # 1D version
<descriptor>: ((row_start, col_start), (row_end, col_end))  # 2D version
```

**GET Operation:**
```
(start, end)                                  # 1D version
((row_start, col_start), (row_end, col_end))  # 2D version
```

If no space available:
```
<descriptor>: (0, 0)                          # 1D version
<descriptor>: ((0, 0), (0, 0))                # 2D version
```

## 🧠 Algorithm Details

### Memory Allocation (First-Fit)
1. Calculate required blocks: `size / 8` (rounded up if remainder exists)
2. Scan memory for contiguous free blocks (value = 0)
3. Allocate blocks by writing descriptor value
4. Track block positions and return coordinates

### Fragmentation Handling
- Detects consecutive zero blocks
- Handles edge cases (end-of-memory zeros)
- Adjusts vector/matrix length dynamically

### 2D Storage Optimization
- Row-major memory layout
- Line length tracking array
- Optimized addressing: `address = row * 1024 * 4 + col * 4`

## 📊 Memory Specifications

| Version | Storage Type | Capacity | Block Size | Max Blocks |
|---------|-------------|----------|------------|------------|
| Cerinta 1 | 1D Vector | 4KB | 1 byte | 1024 |
| Cerinta 2 | 2D Matrix | 4MB | 1 byte | 1024×1024 |

## 🎓 Learning Outcomes

This project demonstrates proficiency in:
- Low-level programming and computer architecture
- Memory management without high-level abstractions
- Algorithm implementation at machine code level
- x86 instruction set and register usage
- Stack frame management and calling conventions
- Performance optimization at hardware level
- Problem-solving with limited computational resources

## 🏆 Achievements

- ✅ Fully functional file system operations in pure assembly
- ✅ Dynamic memory allocation with fragmentation handling
- ✅ Support for multiple storage models (1D and 2D)
- ✅ Efficient first-fit allocation algorithm
- ✅ Robust error handling for edge cases
- ✅ Optimized register usage and minimal memory overhead

## 📝 Notes

- Block size unit: 8 bytes per descriptor block
- Memory is zero-initialized at program start
- Descriptors are stored as 4-byte integers
- Maximum operations limited by input specification
- All arithmetic operations performed at register level

## 👤 Author

**Bogdan Caraeane**
- University Project - Computer Architecture (ASC)
- Year 1, Semester 1

## 📄 License

This is an academic project created for educational purposes.

---

