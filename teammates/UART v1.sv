module UART_v1 (
input wire clk,
input wire rst,

input wire div_en,
input wire [15:0] div_in,

input wire [31:0] d_in,
//output wire [31:0] d_out,

input wire tx_en,
output reg ser_tx,
output reg tx_empty     // transmitter is empty (Transmission is complete)

//input wire ser_rx,
//input wire rx_ready     // receiver has data ready (Reception is complete)

);

parameter [15:0] default_baud = 16'b1;

reg [31:0] d_in_reg;
//reg [31:0] d_out_reg;


//clock divider related regs
reg div_en_reg;
reg br_set;

reg [15:0] div_reg;

//transmitter related regs
reg [15:0] tx_div_cnt;		//clock divider counter for transmitter
reg [1:0] tx_frame_cnt;     //frame counter for transmitter 32bits = 4 data frames
reg [3:0] tx_bit_cnt;       //bit counter for transmitter (1 start + 8 data + 1 stop = 10 bits)
reg tx_en_reg;
reg tx_on;
reg tx_clk;
reg [9:0]tx_buf;

//transmitter states for FSM
reg [1:0] tx_status;
parameter tx_idle = 2'b00;
parameter tx_start_bit = 2'b01;
parameter tx_data_bit = 2'b10;
parameter tx_stop_bit = 2'b11;

//receiver related regs
//reg [15:0] rx_div_cnt;		//clock divider counter for receiver
//reg [1:0] rx_frame_cnt;     //frame counter for receiver 32bits = 4 data frames
//reg [3:0] rx_bit_cnt;       //bit counter for receiver (1 start + 8 data + 1 stop = 10 bits)
//reg rx_en_reg;
//reg rx_on;
//reg rx_clk;
//reg [9:0]rx_buf;

//receiver states for FSM
//reg [1:0] rx_status;
//parameter rx_idle = 2'b00;
//parameter rx_start_bit = 2'b01;
//parameter rx_data_bit = 2'b10;
//parameter rx_stop_bit = 2'b11;

//************************************************Clock Divider Block************************************************//

always @(posedge clk) begin
    if (rst == 1'b1) begin
        div_en_reg <= 1'b0;
    end

    else begin
        div_en_reg <= div_en;
    end
end

always @(posedge clk) begin    // br_set combinational logic
    if (rst == 1'b1) begin
        br_set = 1'b0;
    end
    else begin
        if (div_en_reg == 1'b0 && div_en == 1'b1) begin     // rising edge detected
            br_set = 1'b0;
        end

        if (div_en_reg == 1'b1 && div_en == 1'b0) begin     // falling edge detected
            br_set = 1'b1;
        end
    end
end


always @(posedge clk) begin     // clock _divider configuration
    if (rst == 1'b1) begin
        div_reg <= default_baud;
    end

    else begin
        if (div_en == 1'b1) begin
            if ((div_in != 16'b0) || (div_in != 16'b1)) begin
                div_reg <= div_in - 1;
            end

            else begin
                div_reg <= default_baud;
            end
        end

        //else - do nothing
            // if no div_en yet, wait for div_en to be high - comm has not started yet
            // if div_en became zero after being atleast once high, then hold the value in div_reg - comm is happening
    end
end

//************************************************End of Clock Divider Block************************************************//



//************************************************Transmitter Block************************************************//

always @(posedge clk) begin     // tx_en_reg to detect edges of tx_en
    if (rst == 1'b1) begin
        tx_en_reg <= 1'b0;
    end

    else begin
        tx_en_reg <= tx_en;
    end
end

always @(posedge clk) begin    // tx_on logic
    if (rst == 1'b1) begin
        tx_on <= 1'b0;
    end
    else begin
        if (br_set == 1'b1) begin
            if (tx_en_reg == 1'b0 && tx_en == 1'b1) begin     // rising edge detected
                tx_on = 1'b0;
            end

            if (tx_en_reg == 1'b1 && tx_en == 1'b0) begin     // falling edge detected
                tx_on = 1'b1;
            end
        end

        else begin
            tx_on = 1'b0;
        end
    end
end

always @(posedge clk) begin     //d_in_reg to latch input data
    if (rst == 1'b1) begin
        d_in_reg <= 32'b0;
    end

    else begin
        if (tx_on == 1'b1 && tx_status == tx_idle) begin
            d_in_reg <= d_in;
        end
    end
end

always @(posedge clk) begin     //Transmitter clock divider counter
    if (rst == 1'b1) begin
        tx_div_cnt <= 16'b0;
        tx_clk <= 1'b0;
    end

    else begin
        if (tx_on == 1'b1) begin
            if (tx_div_cnt < div_reg) begin
                tx_div_cnt <= tx_div_cnt + 1;
            end

            else begin
                tx_clk <= ~tx_clk;
                tx_div_cnt <= 16'b0;
            end
        end

        else begin
            tx_div_cnt <= 16'b0;
            tx_clk <= 1'b0;
        end
    end
end

always @(posedge tx_clk or posedge rst) begin     // Transmitter
    if (rst == 1'b1) begin
        tx_status <= tx_idle;
        tx_buf <= 10'b1111111111;
        tx_frame_cnt <= 2'b0;
        tx_bit_cnt <= 4'b0;
        tx_empty <= 1'b0;
    end

    else begin
        case (tx_status)
            tx_idle: begin
                
                if (tx_on == 1'b1) begin
                    ser_tx <= tx_buf[0];
                    tx_status <= tx_start_bit;
                    tx_buf <= {1'b1, d_in_reg[7:0], 1'b0};      //stop bit, data bits, start bit
                    tx_frame_cnt <= 3;
                    tx_bit_cnt <= 9;
                end

                else begin
                    ser_tx <= tx_buf[0];
                    tx_status <= tx_idle;
                    d_in_reg <= 32'b0;
                    tx_buf <= 10'b1111111111;
                    tx_frame_cnt <= 2'b0;
                    tx_bit_cnt <= 4'b0;
                end
            end

            tx_start_bit: begin
                ser_tx <= tx_buf[0];
                tx_buf <= {1'b1, tx_buf[9:1]};
                tx_status <= tx_data_bit;
                tx_bit_cnt <= tx_bit_cnt - 1;
            end

            tx_data_bit: begin
                ser_tx <= tx_buf[0];
                tx_buf <= {1'b1, tx_buf[9:1]};
                tx_bit_cnt <= tx_bit_cnt - 1;
                if (tx_bit_cnt == 1) begin
                    tx_status <= tx_stop_bit;
                end

                else begin
                    tx_status <= tx_data_bit;
                end
            end

            tx_stop_bit: begin
                ser_tx <= tx_buf[0];
                tx_buf <= {1'b1, tx_buf[9:1]};
                tx_frame_cnt <= tx_frame_cnt - 1;
                if (tx_frame_cnt == 0) begin
                    tx_status <= tx_idle;
                    tx_on <= 1'b0;
                    tx_empty <= 1'b1;    // Transmission is complete
                end

                else begin
                    tx_status <= tx_start_bit;
                    tx_bit_cnt <= 9;
                    case (tx_frame_cnt)
                        3: tx_buf <= {1'b1, d_in_reg[15:8], 1'b0};      //stop bit, data bits, start bit
                        2: tx_buf <= {1'b1, d_in_reg[23:16], 1'b0};     //stop bit, data bits, start bit
                        1: tx_buf <= {1'b1, d_in_reg[31:24], 1'b0};     //stop bit, data bits, start bit
                    endcase
                end
            end
        endcase
    end
end

//************************************************End of Transmitter Block************************************************//

//************************************************Receiver Block************************************************//




endmodule





