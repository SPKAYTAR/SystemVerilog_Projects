`timescale 1ns/1ps

module counter_tb;

logic clk;
logic enable;
logic direction;
logic [4:0] count;

//initialize bidirectiona counter
Counter dut (
    .clk(clk),
    .direction(direction),
    .enable(enable),
    .count(count)
);

always #1 clk = ~clk;
initial begin
    $timeformat(-9,0, "ns", 0);

    clk = 0;
    enable = 1;
    direction = 1;

    $monitor("%0t %0d %0d %0d", $time, direction, enable, count);

    # 5 ;

    enable = 0;

    #5;

    enable = 1;
    direction = 0;

    #10;

    $finish;
    end


endmodule