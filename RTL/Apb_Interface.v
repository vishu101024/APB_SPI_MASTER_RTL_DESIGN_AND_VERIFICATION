```verilog
//============================================================
// Module : apb
// Purpose: APB register interface and SPI control
//============================================================

module apb (
    pclk, preset, paddr, pwrite, psel, penable, pwdata,
    ss, miso_data, recive_data, tip, prdata_o, mstr_o,
    cpol_o, cpha_o, lsbfe_o, spiswai_o, sppr_o, spr_o,
    spi_int_req, pready_o, psalve_o, send_data_o,
    mosi_data_o, spi_mode
);

    // Inputs
    input pclk, preset, pwrite, psel, penable;
    input ss, recive_data, tip;
    input [2:0] paddr;
    input [7:0] pwdata, miso_data;

    // Outputs
    output reg [7:0] prdata_o, mosi_data_o;
    output [6:4] sppr_o;
    output [2:0] spr_o;
    output mstr_o, cpol_o, cpha_o, lsbfe_o;
    output spiswai_o, pready_o, psalve_o;
    output [1:0] spi_mode;
    output reg send_data_o, spi_int_req;

    // Internal registers
    reg [7:0] spi_cr1, spi_cr2, spi_bd, spi_dr;
    reg [2:0] state, ns, state1, ns1;

    // Internal wires
    wire rd_enable, wr_enable;
    wire sptef, modef, spif, spie, sptie, ssoe, spe;
    wire modefn;
    wire [7:0] spi_cr2_mask, spi_bd_mask, spi_sr;

    // State definitions
    parameter idle     = 3'b000,
              setup    = 3'b010,
              access   = 3'b011,
              spi_run  = 3'b100,
              spi_wait = 3'b101,
              spi_stop = 3'b110;

    //========================================================
    // Control register output assignments
    //========================================================
    assign mstr_o    = spi_cr1[4];
    assign cpol_o    = spi_cr1[3];
    assign cpha_o    = spi_cr1[0];
    assign lsbfe_o   = spi_cr1[0];
    assign spiswai_o = spi_cr2[0];
    assign sppr_o    = spi_bd[6:4];
    assign spr_o     = spi_bd[2:0];

    assign modefn = spi_cr2[4];
    assign spie   = spi_cr1[7];
    assign sptie  = spi_cr1[5];
    assign spe    = spi_cr1[6];
    assign spiswai_o = spi_cr2[1];
    assign ssoe   = spi_cr1[1];

    //========================================================
    // Status and bus-control signals
    //========================================================
    assign sptef = (spi_dr == 8'd0) ? 1'b1 : 1'b0;
    assign spif  = (spi_dr == 8'd0) ? 1'b1 : 1'b0;

    assign modef = ((~ssoe) && modefn && mstr_o && (~ss));

    assign rd_enable = ((~pwrite) && (state == access))
                       ? 1'b1 : 1'b0;

    assign wr_enable = (pwrite && (state == access))
                       ? 1'b1 : 1'b0;

    assign spi_cr2_mask = 8'b00011011;
    assign spi_bd_mask  = 8'b01110111;

    assign pready_o = (state == access) ? 1'b1 : 1'b0;
    assign psalve_o = (state == access) ? (~tip) : 1'b0;

    assign spi_mode = (state1 == spi_run)  ? 2'b00 :
                      (state1 == spi_wait) ? 2'b01 :
                      (state1 == spi_stop) ? 2'b10 :
                                             2'b11;

    assign spi_sr = (!preset) ? 8'b0010_0000 :
                    {spif, 1'b0, sptef, modef, 4'b0};

    //========================================================
    // Control register 1
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            spi_cr1 <= 8'h00;
        else if (wr_enable) begin
            if (paddr == 3'b000)
                spi_cr1 <= pwdata;
            else
                spi_cr1 <= spi_cr1;
        end
        else
            spi_cr1 <= spi_cr1;
    end

    //========================================================
    // Control register 2
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            spi_cr2 <= 8'h00;
        else if (wr_enable) begin
            if (paddr == 3'b001)
                spi_cr2 <= pwdata & spi_cr2_mask;
            else
                spi_cr2 <= spi_cr2;
        end
        else
            spi_cr2 <= spi_cr2;
    end

    //========================================================
    // Baud-rate register
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            spi_bd <= 8'h00;
        else if (wr_enable) begin
            if (paddr == 3'b010)
                spi_bd <= pwdata & spi_bd_mask;
            else
                spi_bd <= spi_bd;
        end
        else
            spi_bd <= spi_bd;
    end

    //========================================================
    // Data register
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            spi_dr <= 8'd0;
        else if (wr_enable) begin
            if (paddr == 3'b101)
                spi_dr <= pwdata;
            else
                spi_dr <= spi_dr;
        end
        else if (((spi_mode == 2'b00) ||
                 (spi_mode == 2'b01 && !spiswai_o)) &&
                 (spi_dr != miso_data) &&
                 (spi_dr == pwdata))
            spi_dr <= 8'b0;
        else if (recive_data &&
                 ((spi_mode == 2'b00) || (spi_mode == 2'b01)))
            spi_dr <= miso_data;
        else
            spi_dr <= spi_dr;
    end

    //========================================================
    // Send-data control
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            send_data_o <= 1'b0;
        else if (!wr_enable) begin
            if (((spi_mode == 2'b00) || (spi_mode == 2'b01)) &&
                (spi_dr !== miso_data) &&
                (spi_dr == pwdata))
                send_data_o <= 1'b1;
            else
                send_data_o <= 1'b0;
        end
        else
            send_data_o <= 1'b0;
    end

    //========================================================
    // MOSI data output register
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            mosi_data_o <= 8'h00;
        else if (((spi_mode == 2'b00) || (spi_mode == 2'b01)) &&
                 (spi_dr != miso_data) &&
                 (spi_dr == pwdata))
            mosi_data_o <= spi_dr;
        else
            mosi_data_o <= mosi_data_o;
    end

    //========================================================
    // APB read-data multiplexer
    //========================================================
    always @(*) begin
        if (rd_enable) begin
            case (paddr)
                3'b000: prdata_o = spi_cr1;
                3'b001: prdata_o = spi_cr2;
                3'b010: prdata_o = spi_bd;
                3'b011: prdata_o = spi_sr;
                3'b101: prdata_o = spi_dr;
                default: prdata_o = 8'b0;
            endcase
        end
        else
            prdata_o = 8'b0;
    end

    //========================================================
    // SPI interrupt request
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!(~spie) && (~sptie)) begin
            if (!(~sptie) && spie) begin
                if (!(~sptie) && spie)
                    spi_int_req <= (spif || modef || sptef);
                else
                    spi_int_req <= sptef;
            end
            else
                spi_int_req <= (spif || modef);
        end
        else
            spi_int_req <= 1'b0;
    end

    //========================================================
    // APB state register
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            state <= idle;
        else
            state <= ns;
    end

    //========================================================
    // APB next-state logic
    //========================================================
    always @(*) begin
        case (state)
            idle: begin
                if (psel && !penable)
                    ns = setup;
                else
                    ns = idle;
            end

            setup: begin
                if (!psel)
                    ns = idle;
                else if (psel && penable)
                    ns = access;
                else
                    ns = setup;
            end

            access: begin
                if (psel)
                    ns = setup;
                else
                    ns = idle;
            end

            default: ns = idle;
        endcase
    end

    //========================================================
    // SPI state register
    //========================================================
    always @(posedge pclk or preset) begin
        if (!preset)
            state1 <= spi_run;
        else
            state1 <= ns1;
    end

    //========================================================
    // SPI next-state logic
    //========================================================
    always @(*) begin
        case (state1)
            spi_run: begin
                if (!spe)
                    ns1 = spi_wait;
                else
                    ns1 = spi_run;
            end

            spi_wait: begin
                if (spiswai_o)
                    ns1 = spi_stop;
                else
                    ns1 = spi_wait;
            end

            spi_stop: begin
                if (!spiswai_o)
                    ns1 = spi_wait;
                else if (spe)
                    ns1 = spi_run;
                else
                    ns1 = spi_stop;
            end

            default: ns1 = spi_run;
        endcase
    end

endmodule
```
