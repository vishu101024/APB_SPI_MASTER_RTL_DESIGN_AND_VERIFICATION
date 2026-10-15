
//============================================================
// Module : slave
// Purpose: SPI slave-select and transfer control
//============================================================

module slave (
    pclk,
    preset,
    mstr_i,
    spiswai_i,
    spimode_i,
    send_data_i,
    bd_i,
    recive_data_o,
    ss_o,
    tip_o
);

    // Inputs
    input pclk;
    input preset;
    input mstr_i;
    input spiswai_i;
    input [1:0] spimode_i;
    input send_data_i;
    input [11:0] bd_i;

    // Outputs
    output reg recive_data_o;
    output reg ss_o;
    output tip_o;

    // Internal signals
    wire [11:0] target;
    reg [11:0] count;
    reg rcv;

    // Transfer-in-progress indication
    assign tip_o = ~ss_o;

    // Transfer target calculation
    assign target = bd_i * 8;

    //========================================================
    // Receive-data output register
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            recive_data_o <= 1'b0;
        else
            recive_data_o <= rcv;
    end

    //========================================================
    // Transfer counter
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            count <= 16'hffff;
        else if (mstr_i
                 && ((spimode_i == 2'b00)
                 || (spimode_i == 2'b01))
                 && (~spiswai_i)) begin
            if (!send_data_i) begin
                if (count <= (target - 1'b1))
                    count <= count + 1'b1;
                else
                    count <= 16'hffff;
            end
            else
                count <= 16'd0;
        end
        else
            count <= 16'hffff;
    end

    //========================================================
    // Receive-completion logic
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            rcv <= 1'b0;
        else if (mstr_i
                 && ((spimode_i == 2'b00)
                 || (spimode_i == 2'b01))
                 && (~spiswai_i)) begin
            if (!send_data_i) begin
                if (count <= (target - 1'b1)) begin
                    if (count == (target - 1'b1))
                        rcv <= 1'b1;
                    else
                        rcv <= 1'b0;
                end
                else
                    rcv <= 1'b0;
            end
            else
                rcv <= 1'b0;
        end
        else
            rcv <= 1'b0;
    end

    //========================================================
    // Slave-select output logic
    //========================================================
    always @(posedge pclk or negedge preset) begin
        if (!preset)
            ss_o <= 1'b1;
        else if (mstr_i
                 && ((spimode_i == 2'b00)
                 || (spimode_i == 2'b01))
                 && (~spiswai_i)) begin
            if (!send_data_i) begin
                if (count <= (target - 1'b1))
                    ss_o <= 1'b0;
                else
                    ss_o <= 1'b1;
            end
            else
                ss_o <= 1'b0;
        end
        else
            ss_o <= 1'b1;
    end

endmodule
