`timescale 1ns/1ps

module shift_tb;

logic clk;
logic enable;
logic serial_in;
logic reset;
logic [3:0] q;

logic data [0:20];

always #5 clk = ~clk;

shift_reg_4 dut (
    .clk(clk),
    .enable(enable),
    .serial_in(serial_in),
    .reset(reset),
    .q(q)
);

initial begin
    data = '{1,0,1,1,0,0,1,0,1,1,0,1,0,0,1,1,1,0,0,1,0};

    clk = 0;
    enable = 1;
    serial_in = 0;
    reset = 1;
    
    #10;
    reset = 0;
    $monitor("%b %b %b ", clk, serial_in, q);
    for(int i = 20; i >=0; i--) begin
        #10
        serial_in = data[i];
    end

    $finish;
end

endmodule


