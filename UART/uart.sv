module uart_tx (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] data_in,
    input  logic       send,
    output logic       tx,
    output logic       busy
);

//counter
logic [4:0]counter;

logic is_clear = (counter == 8);

//fsm

typedef enum logic [1:0]{
    IDLE,
    START,
    DATA,
    STOP
} state_t;

state_t state;

always_ff @(posedge clk) begin
    if(reset)
        state <= IDLE;
    else if(enable) begin
        case(state)
            IDLE:
            START:
            DATA:
            STOP:


        endcase

    end

end


endmodule