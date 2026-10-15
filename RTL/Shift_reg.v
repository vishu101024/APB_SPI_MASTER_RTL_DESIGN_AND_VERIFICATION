```verilog
//============================================================
// Module : shift
// Purpose: SPI serial data transmission and reception
//============================================================

module shift (
    pclk,
    preset,
    ss,
    send_data,
    lsbfe,
    cpol,
    cpha,
    miso_recive_sclk,
    miso_recive_sclk0,
    mosi_send_sclk,
    mosi_send_sclk0,
    data_mosi,
    miso,
    recive_data,
    mosi_o,
    data_miso_o
);

    // Inputs
    input pclk;
    input preset;
    input ss;
    input send_data;
    input lsbfe;
    input cpol;
    input cpha;
    input miso_recive_sclk;
    input miso_recive_sclk0;
    input mosi_send_sclk;
    input mosi_send_sclk0;
    input miso;
    input recive_data;
    input [7:0] data_mosi;

    // Outputs
    output reg mosi_o;
    output [7:0] data_miso_o;

    // Internal registers
    reg [2:0] count;
    reg [2:0] count1;
    reg [2:0] count2;
    reg [2:0] count3;
    reg [7:0] temp;
    reg [7:0] shift_reg;

    // Received data is exposed when receive completes
    assign data_miso_o = recive_data ? temp : 8'h00;

    //========================================================
    // Transmit shift-register loading
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            shift_reg <= 8'h00;
        else if (send_data)
            shift_reg <= data_mosi;
        else
            shift_reg <= shift_reg;
    end

    //========================================================
    // MOSI output generation
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            mosi_o <= 1'b0;
        else if (~ss) begin
            if ((~cpol && cpha) || (cpol && ~cpha)) begin
                if (lsbfe) begin
                    if (count <= 3'd7) begin
                        if (mosi_send_sclk0)
                            mosi_o <= shift_reg[count];
                        else
                            mosi_o <= mosi_o;
                    end
                    else
                        mosi_o <= mosi_o;
                end
                else if (!lsbfe) begin
                    if (count1 >= 3'd0) begin
                        if (mosi_send_sclk0)
                            mosi_o <= shift_reg[count1];
                        else
                            mosi_o <= mosi_o;
                    end
                    else
                        mosi_o <= 3'd7;
                end
            end
            else begin
                if (lsbfe) begin
                    if (count <= 3'd7) begin
                        if (mosi_send_sclk)
                            mosi_o <= shift_reg[count];
                        else
                            mosi_o <= mosi_o;
                    end
                    else
                        mosi_o <= 3'd0;
                end
                else if (!lsbfe) begin
                    if (count1 >= 3'd0) begin
                        if (mosi_send_sclk)
                            mosi_o <= shift_reg[count1];
                        else
                            mosi_o <= mosi_o;
                    end
                    else
                        mosi_o <= 3'd7;
                end
            end
        end
    end

    //========================================================
    // MOSI bit counters
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset) begin
            count  <= 3'b000;
            count1 <= 3'b111;
        end
        else if (~ss) begin
            if ((~cpol && cpha) || (cpol && ~cpha)) begin
                if (lsbfe) begin
                    if (count <= 3'd7) begin
                        if (mosi_send_sclk0)
                            count <= count + 1'b1;
                        else
                            count <= count;
                    end
                    else
                        count <= 3'd0;
                end
                else if (!lsbfe) begin
                    if (count1 >= 3'd0) begin
                        if (mosi_send_sclk0)
                            count1 <= count1 - 1'b1;
                        else
                            count1 <= count1;
                    end
                    else
                        count1 <= 3'd7;
                end
            end
            else begin
                if (lsbfe) begin
                    if (count <= 3'd7) begin
                        if (mosi_send_sclk)
                            count <= count + 1'b1;
                        else
                            count <= count;
                    end
                    else
                        count <= 3'd0;
                end
                else if (!lsbfe) begin
                    if (count1 >= 3'd0) begin
                        if (mosi_send_sclk)
                            count1 <= count1 - 1'b1;
                        else
                            count1 <= count1;
                    end
                    else
                        count1 <= 3'd7;
                end
            end
        end
    end

    //========================================================
    // MISO receive logic and receive bit counters
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset) begin
            temp   <= 8'b0;
            count2 <= 3'b000;
            count3 <= 3'b111;
        end
        else if (~ss) begin
            if ((~cpol && cpha) || (cpol && ~cpha)) begin
                if (lsbfe) begin
                    if (count2 <= 3'd7) begin
                        if (miso_recive_sclk0) begin
                            temp[count2] <= miso;
                            count2 <= count2 + 1'b1;
                        end
                        else
                            temp[count2] <= temp[count2];
                    end
                    else
                        temp[count2] <= 3'd0;
                end
                else if (!lsbfe) begin
                    if (count3 >= 3'd0) begin
                        if (miso_recive_sclk0) begin
                            temp[count3] <= miso;
                            count3 <= count3 - 1'b1;
                        end
                        else
                            temp[count3] <= temp[count3];
                    end
                    else
                        temp[count3] <= 3'd7;
                end
            end
            else begin
                if (lsbfe) begin
                    if (count2 <= 3'd7) begin
                        if (miso_recive_sclk) begin
                            temp[count2] <= miso;
                            count2 <= count2 + 1'b1;
                        end
                        else
                            temp[count2] <= temp[count2];
                    end
                    else
                        temp[count2] <= 3'd0;
                end
                else if (!lsbfe) begin
                    if (count3 >= 3'd0) begin
                        if (miso_recive_sclk) begin
                            temp[count3] <= miso;
                            count3 <= count3 - 1'b1;
                        end
                        else
                            temp[count3] <= temp[count3];
                    end
                    else
                        temp[count3] <= 3'd7;
                end
            end
        end
    end

endmodule
```
