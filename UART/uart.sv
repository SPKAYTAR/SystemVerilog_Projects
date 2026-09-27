module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] data_in,
    input  logic       send,
    output logic       tx,
    output logic       busy
);
//baud logic
logic baud_done;
localparam BAUD_MAX = CLK_FREQ / BAUD_RATE - 1;


//counter
logic [9:0] baud_count;
logic [4:0] bit_count;
assign baud_done = (baud_count == BAUD_MAX);
//reg
logic [7:0] data_reg;

//state logic
typedef enum logic [1:0]{
    IDLE,
    START,
    DATA,
    STOP
} state_t;


state_t state;

assign busy = (state != IDLE);
//counter logic
// Baud counter
always_ff @(posedge clk) begin
    if (reset || state == IDLE)
        baud_count <= 0;

    else if (baud_done)
        baud_count <= 0;

    else
        baud_count <= baud_count + 1;
end


// Bit counter
always_ff @(posedge clk) begin
    if (reset || state != DATA)
        bit_count <= 0;

    else if (baud_done && bit_count < 7)
        bit_count <= bit_count + 1;
end

//state logic
always_ff @(posedge clk) begin  //start/busy handshake: busy says data_in wait im doing something, start tells uart i have info for you
    if (reset) begin
        state <= IDLE;
        data_reg <= 8'b00000000;
    end
    else
        case (state)

            IDLE: begin
                if (send) begin
                    state <= START;
                    data_reg <= data_in;
                end
            end
            START: begin
                if (baud_done) //pull low one baud cycle 
                    state <= DATA;
            end
            DATA: begin
                 if (baud_done) begin

                    if (bit_count == 7)
                        state <= STOP;
                    else begin
                        data_reg <= {1'b0, data_reg[7:1]};

                    end
                 end 
            end
            STOP: begin
                if (baud_done)
                    state <= IDLE;
            end
        endcase
end

//tx assigner
always_comb begin  // updates whenever anything is changed
    if (state == IDLE)
        tx = 1;
    else if (state == START)
        tx = 0;
    else if (state == DATA)
        tx = data_reg[0];
    else
        tx = 1;
end

endmodule





//RX UART

module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  logic       clk,
    input  logic       reset,
    input  logic       data_in,
    output logic [7:0] rx,
    output logic       data_valid
);

logic [7:0] data_reg;
//state logic
typedef enum logic [1:0]{
    IDLE,
    START,
    DATA,
    STOP
 } state_t;
state_t state;


//clock logic
localparam OVER_MAX = CLK_FREQ / (BAUD_RATE * 16) - 1; // 16 x oversample
logic [5:0]over_clk_count;
logic [2:0] bit_count;
logic [4:0] overcount; //no baud this handles sample timing

//overcount clock
always_ff @(posedge clk) begin

    if (reset || state == IDLE) begin
        over_clk_count <= 0;
        overcount <= 0;
    end
    else if (state == START && overcount == 8) begin
        overcount <= 0;
    end
    else if ((state == DATA || state == STOP) && overcount == 16) begin
        overcount <= 0;
    end
    else if (over_clk_count == OVER_MAX) begin
        over_clk_count <= 0;
        overcount <= overcount + 1;
    end
    else begin
        over_clk_count <= over_clk_count + 1;
    end
end

//bit clock
always_ff @(posedge clk) begin
    if(reset)
        bit_count <= 0;
    else if (state != DATA)
        bit_count <= 0;
    else if (overcount == 16) begin
        if (bit_count == 7)
            bit_count <= 0;
        else
            bit_count <= bit_count + 1;
    end
end



//FMS LOGIC
always_ff @(posedge clk) begin
    if(reset) begin
        state <= IDLE;
        data_reg <= 8'b0;
        rx       <= 8'b0;
        data_valid <= 0;
    end
    else begin
        data_valid <= 0;
        case(state)
            IDLE: begin
                if(data_in == 0) begin
                    state <= START;
                    data_reg <= 8'b0;
                end
            end
            START: begin
                if (overcount == 8) begin
                    if (data_in == 0)
                        state <= DATA;
                    else
                        state <= IDLE;
                end
            end
            DATA: begin
                if (overcount == 16) begin
                    data_reg <= {data_in, data_reg[7:1]};
                    

                if (bit_count == 7)
                    state <= STOP;
                    end
            end
            STOP: begin
                if (overcount == 16) begin
                    if (data_in == 1)
                        rx <= data_reg;
                        data_valid <= 1;
                    state <= IDLE;
                end
            end
        endcase
    end
end

  
endmodule
        
//combined uart
module uart #(
    parameter CLK_FREQ  = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  logic       clk,
    input  logic       reset,

    input  logic [7:0] tx_data,
    input  logic       tx_send,
    output logic       tx,
    output logic       tx_busy,

    input  logic       rx_in,
    output logic [7:0] rx_data,
    output logic       rx_valid
);

uart_tx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) tx_unit (
    .clk(clk),
    .reset(reset),
    .data_in(tx_data), //8 bit
    .send(tx_send),
    .tx(tx),  /bit
    .busy(tx_busy)
);


uart_rx #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
) rx_unit (
    .clk(clk),
    .reset(reset),
    .data_in(rx_in), //bit
    .rx(rx_data),  //8 bit
    .data_valid(rx_valid)
);

endmodule