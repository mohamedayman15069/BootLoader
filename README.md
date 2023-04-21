# BootLoader
This bootloader is used to set up the Global Descriptor Table (GDT) and builds a page table to map the first 2 MB of memory, which is necessary to switch to long mode.

## Features
1. Initializes the null, code, and data descriptors in GDT
2. Sets up control registers CR4, CR3, EFER MSR, and CR0 to enable protected mode and paging
3. Clears the screen using the video_clear function (blue color by default)
4. Constructs a full page table to map the entire memory for unlimited memory and 64-bit registers

## Instructions

To run the bootloader, follow these instructions:
1. Compile the bootloader using the provided Makefile
2. Load the bootloader onto a bootable device (e.g. USB drive)
3. Boot the device and run the bootloader

## Implementation Discussion 
In the second stage bootloader, the GDT is set up by initializing the null, code, and data descriptors. A page table is then built to map the first 2 MB of memory, which is necessary to switch to long mode. This is done by initializing four memory pages (one for each level, 4 KB each) and looping over the 2 MB of memory to map them as 4 KB pages. Control registers CR4, CR3, EFER MSR, and CR0 are then configured to enable protected mode and paging, and the bootloader jumps to the code segment in 64-bit mode. The screen is cleared using the video_clear function (blue color by default).

To construct a full page table that can map the entire memory, three files are created in the third stage. The first file maps the first 2 MB of memory using three levels of page tables. The PML4 (first page table) is created and the first entry is checked to see if the PDP is created. If not, it is created and the entry points to the next level page table, which is the PDP. The PDP entry is then checked to see if the PDT is created. If not, it is created and the PDP first entry contains the address of the PDT. The PDT contains the address of the first 2 MB (0x000 in QEMU).

A bitmap is used to construct the page table. This bitmap is a small chunk of memory containing important information to construct the page table. Each segment contains 8 bytes for the first address, 8 bytes for the length of the segment, a bit for checking whether the segment is 2 MB (with 1) or 4 KB (with 0), and a final bit indicating whether it is mapped or still free. A loop is used to construct an entry by calling the map function. The first 2 MB segments are mapped first by checking the 17th bit of the segment in each segment. The same is done for the remaining memory but with a little care to add 2 MB to the virtual address. For 4 KB segments, the same process is followed but mapped in the fourth level (PTE).

## Conclusion 
This bootloader is capable of setting up the GDT and page table to enable protected mode and paging. It also includes a video_clear function to clear the screen and construct a full page table to map the entire memory.
