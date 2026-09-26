module traffic_light( input logic clk, input logic reset, output logic red, output logic yellow, output logic green);

typedef enum logic [1:0] {
    GREEN, YELLOW, RED  
    } state_t;

state_t state;

logic [2:0] count;
logic five_sec_done;
//control logic
assign five_sec_done = (count == 4);

//clock logic
always_ff @(posedge clk) begin
    if (reset)
        count <= 0;
    else if (five_sec_done)
        count <= 0;
    else
        count <= count + 1;
  
end

//state control
always_ff @(posedge clk) begin
    if (reset)
        state <= GREEN;
    else if (five_sec_done)
        case (state)
            GREEN:  state <= YELLOW;
            YELLOW: state <= RED;
            RED:    state <= GREEN;
        endcase
end

// OUTPUTS
always_comb begin  //combinational logic
    red = 0;
    yellow = 0;
    green = 0;

    case (state)
        GREEN:  green = 1;
        YELLOW: yellow = 1;
        RED:    red = 1;
    endcase
end

endmodule