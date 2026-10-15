```verilog
//============================================================
// Module : top
// Purpose: Top-level SPI controller integration
//============================================================

module top (
    PCLK,
    PRESET,
    PADDR,
    PWRITE,
    PSEL,
    PENABLE,
    PWDATA,
    MISO,
    SS,
    SCLK,
    SPI_INT_REQ,
    MOSI,
    PRDATA,
    PREADY,
    PSLAVE
);

    // APB inputs
    input PCLK;
    input PRESET;
    input PWRITE;
    input PENABLE;
    input PSEL;
    input MISO;
    input [2:0] PADDR;
    input [7:0] PWDATA;

    // External outputs
    output SS;
    output SCLK;
    output SPI_INT_REQ;
    output MOSI;
    output PREADY;
    output PSLAVE;
    output [7:0] PRDATA;

    // Clock-generator signals
    wire CPOL;
    wire CPHA;
    wire SPISWAI;
    wire [2:0] SPPR_I;
    wire [2:0] SPR_I;
    wire [1:0] SPI_MODE;

    wire MISO_RECIVE_SCLK;
    wire MISO_RECIVE_SCLK0;
    wire MOSI_SEND_SCLK;
    wire MOSI_SEND_SCLK0;
    wire [11:0] BD;

    // Slave-control signals
    wire MSTR_I;
    wire SEND_DATA_I;
    wire RECIVE_DATA;
    wire TIP;

    // Shift-register signals
    wire LSBFE;
    wire [7:0] DATA_MOSI;
    wire [7:0] DATA_MISO_O;

    //========================================================
    // Block 1: SPI clock generator
    //========================================================
    clkgen dut1 (
        CPOL,
        CPHA,
        PCLK,
        PRESET,
        SPISWAI,
        SS,
        SPI_MODE,
        SPPR_I,
        SPR_I,
        SCLK,
        MISO_RECIVE_SCLK,
        MISO_RECIVE_SCLK0,
        MOSI_SEND_SCLK0,
        MOSI_SEND_SCLK,
        BD
    );

    //========================================================
    // Block 2: Slave-select and transfer control
    //========================================================
    slave dut2 (
        PCLK,
        PRESET,
        MSTR_I,
        SPISWAI,
        SPI_MODE,
        SEND_DATA_I,
        BD,
        RECIVE_DATA,
        SS,
        TIP
    );

    //========================================================
    // Block 3: SPI shift register
    //========================================================
    shift dut3 (
        PCLK,
        PRESET,
        SS,
        SEND_DATA_I,
        LSBFE,
        CPOL,
        CPHA,
        MISO_RECIVE_SCLK,
        MISO_RECIVE_SCLK0,
        MOSI_SEND_SCLK,
        MOSI_SEND_SCLK0,
        DATA_MOSI,
        MISO,
        RECIVE_DATA,
        MOSI,
        DATA_MISO_O
    );

    //========================================================
    // Block 4: APB interface
    //========================================================
    apb dut4 (
        PCLK,
        PRESET,
        PADDR,
        PWRITE,
        PSEL,
        PENABLE,
        PWDATA,
        SS,
        DATA_MISO_O,
        RECIVE_DATA,
        TIP,
        PRDATA,
        MSTR_I,
        CPOL,
        CPHA,
        LSBFE,
        SPISWAI,
        SPPR_I,
        SPR_I,
        SPI_INT_REQ,
        PREADY,
        PSLAVE,
        SEND_DATA_I,
        DATA_MOSI,
        SPI_MODE
    );

endmodule
```
