`timescale 1ns/1ps

module uart_tb;

    localparam CLK_FREQ   = 100_000_000;
    localparam BAUD_RATE  = 115200;
    localparam CLK_PERIOD = 10;

    logic clk;
    logic reset;

    logic [7:0] tx_data;
    logic       tx_send;
    logic       tx;
    logic       tx_busy;

    logic       rx_in;
    logic [7:0] rx_data;
    logic       rx_valid;

    assign rx_in = tx;

    uart #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .reset(reset),

        .tx_data(tx_data),
        .tx_send(tx_send),
        .tx(tx),
        .tx_busy(tx_busy),

        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task send_byte(input logic [7:0] data);
    begin
        wait(tx_busy == 0);

        @(negedge clk);
        tx_data = data;
        tx_send = 1;

        @(negedge clk);
        tx_send = 0;

        wait(rx_valid == 1);

        if (rx_data === data)
            $display("PASS: sent=%h received=%h", data, rx_data);
        else
            $display("FAIL: sent=%h received=%h", data, rx_data);
    end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        tx_send = 0;
        tx_data = 0;

        repeat(3) @(posedge clk);
        reset = 0;

        send_byte(8'hA5);
        send_byte(8'h00);
        send_byte(8'hFF);
        send_byte(8'h55);
        send_byte(8'h48);

        #20;
        $finish;
    end

endmodule