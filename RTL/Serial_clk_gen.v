
//============================================================
// Module : clkgen
// Purpose: SPI clock generation and data timing pulse generation
//============================================================

module clkgen (
    cpol,
    cpha,
    pclk,
    preset,
    spiswai,
    ss,
    spimode,
    sppr_i,
    spr_i,
    sclk,
    miso_recive_sclk_o,
    miso_recive_sclk0_o,
    mosi_send_sclk0_o,
    mosi_send_sclk_o,
    bd
);

    // Inputs
    input pclk;
    input preset;
    input spiswai;
    input ss;
    input cpol;
    input cpha;
    input [1:0] spimode;
    input [2:0] sppr_i;
    input [2:0] spr_i;

    // Outputs
    output reg sclk;
    output reg miso_recive_sclk_o;
    output reg miso_recive_sclk0_o;
    output reg mosi_send_sclk0_o;
    output reg mosi_send_sclk_o;
    output [11:0] bd;

    // Internal signals
    reg [11:0] count;
    wire pre_sclk;

    // Baud-rate divider calculation
    assign pre_sclk = cpol ? 1'b1 : 1'b0;
    assign bd = ((sppr_i + 1) * (2**(spr_i + 1)));

    //========================================================
    // SPI clock generation
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            sclk <= pre_sclk;
        else if ((spimode == 2'b00 || spimode == 2'b01)
                 && (~ss) && (~spiswai)) begin
            if (count == ((bd / 2) - 1'b1))
                sclk <= ~sclk;
            else
                sclk <= sclk;
        end
        else
            sclk <= pre_sclk;
    end

    //========================================================
    // Baud-rate counter
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            count <= 12'b0;
        else if ((spimode == 2'b00 || 2'b01)
                 && (~ss) && (~spiswai)) begin
            if (count == ((bd / 2) - 1'b1))
                count <= 12'b0;
            else
                count <= count + 1'b1;
        end
    end

    //========================================================
    // MISO receive timing pulse - first phase combination
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            miso_recive_sclk_o <= 1'b0;
        else if ((cpol && cpha) || (~cpol && ~cpha)) begin
            if (~sclk) begin
                if (count == ((bd / 2) - 1'b1))
                    miso_recive_sclk_o <= 1'b1;
                else
                    miso_recive_sclk_o <= 1'b0;
            end
            else
                miso_recive_sclk_o <= 1'b0;
        end
    end

    //========================================================
    // MISO receive timing pulse - second phase combination
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            miso_recive_sclk0_o <= 1'b0;
        else if ((~cpol && cpha) || (cpol && ~cpha)) begin
            if (sclk) begin
                if (count == ((bd / 2) - 1'b1))
                    miso_recive_sclk0_o <= 1'b1;
                else
                    miso_recive_sclk0_o <= 1'b0;
            end
            else
                miso_recive_sclk0_o <= 1'b0;
        end
    end

    //========================================================
    // MOSI transmit timing pulse - first phase combination
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            mosi_send_sclk_o <= 1'b0;
        else if ((cpol && cpha) || (~cpol && ~cpha)) begin
            if (~sclk) begin
                if (count == ((bd / 2) - 2'b10))
                    mosi_send_sclk_o <= 1'b1;
                else
                    mosi_send_sclk_o <= 1'b0;
            end
            else
                mosi_send_sclk_o <= 1'b0;
        end
    end

    //========================================================
    // MOSI transmit timing pulse - second phase combination
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            mosi_send_sclk0_o <= 1'b0;
        else if ((~cpol && cpha) || (cpol && ~cpha)) begin
            if (sclk) begin
                if (count == ((bd / 2) - 2'b10))
                    mosi_send_sclk0_o <= 1'b1;
                else
                    mosi_send_sclk0_o <= 1'b0;
            end
            else
                mosi_send_sclk0_o <= 1'b0;
        end
    end

endmodule
