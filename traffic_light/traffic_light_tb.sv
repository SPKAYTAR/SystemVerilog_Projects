`timescale 1ns / 1ps

module traffic_light_tb;

  logic clk;
  logic reset;
  logic red;
  logic yellow;
  logic green;


  // Create traffic light circuit
  traffic_light dut (
      .clk(clk),
      .reset(reset),
      .red(red),
      .yellow(yellow),
      .green(green)
  );


  // 100 MHz clock
  always #5 clk = ~clk;


  // Test
  initial begin
    $timeformat(-9, 0, " ns", 0);

    clk   = 0;
    reset = 1;

    // Watch signals
    $monitor("time=%0t  count=%0d  state=%0d  red=%b yellow=%b green=%b", $time, dut.count,
             dut.state, red, yellow, green);


    // Reset for one clock cycle
    #10;
    reset = 0;

    // Let circuit run
    #300;

    $finish;

  end

endmodule
