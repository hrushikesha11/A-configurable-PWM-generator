`timescale 1ns / 1ps

module tb_configurable_pwm_generator;

    localparam integer NUM_CHANNELS  = 3;
    localparam integer COUNTER_WIDTH = 8;

    reg clk;
    reg reset_n;
    reg enable;
    reg [COUNTER_WIDTH-1:0] period_cycles;
    reg [NUM_CHANNELS*COUNTER_WIDTH-1:0] duty_cycles;
    wire [NUM_CHANNELS-1:0] pwm_out;

    integer errors;
    integer high_count_0;
    integer high_count_1;
    integer high_count_2;
    integer i;

    configurable_pwm_generator #(
        .NUM_CHANNELS(NUM_CHANNELS),
        .COUNTER_WIDTH(COUNTER_WIDTH)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .enable(enable),
        .period_cycles(period_cycles),
        .duty_cycles(duty_cycles),
        .pwm_out(pwm_out)
    );

    always #5 clk = ~clk;

    task wait_clocks;
        input integer count;
        integer k;
        begin
            for (k = 0; k < count; k = k + 1)
                @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 1'b0;
        reset_n = 1'b0;
        enable = 1'b0;
        period_cycles = 8'd10;
        // Packed order: channel 2, channel 1, channel 0.
        // Channel 0 = 3 cycles, channel 1 = 5, channel 2 = 8.
        duty_cycles = {8'd8, 8'd5, 8'd3};
        errors = 0;

        wait_clocks(2);
        reset_n = 1'b1;
        enable = 1'b1;

        // Sample one full 10-clock period after the output has settled.
        wait_clocks(1);
        high_count_0 = 0;
        high_count_1 = 0;
        high_count_2 = 0;

        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);
            if (pwm_out[0]) high_count_0 = high_count_0 + 1;
            if (pwm_out[1]) high_count_1 = high_count_1 + 1;
            if (pwm_out[2]) high_count_2 = high_count_2 + 1;
        end

        if (high_count_0 != 3) begin
            $display("FAIL: channel 0 expected 3 high clocks, got %0d", high_count_0);
            errors = errors + 1;
        end else $display("PASS: channel 0 duty = 3/10");

        if (high_count_1 != 5) begin
            $display("FAIL: channel 1 expected 5 high clocks, got %0d", high_count_1);
            errors = errors + 1;
        end else $display("PASS: channel 1 duty = 5/10");

        if (high_count_2 != 8) begin
            $display("FAIL: channel 2 expected 8 high clocks, got %0d", high_count_2);
            errors = errors + 1;
        end else $display("PASS: channel 2 duty = 8/10");

        // Check runtime configuration change: period 8, channel 0 duty 4.
        @(negedge clk);
        period_cycles = 8'd8;
        duty_cycles = {8'd0, 8'd0, 8'd4};
        wait_clocks(10);

        // Check disabled output is low.
        enable = 1'b0;
        wait_clocks(2);
        if (pwm_out !== {NUM_CHANNELS{1'b0}}) begin
            $display("FAIL: outputs should be low when disabled");
            errors = errors + 1;
        end else $display("PASS: enable control");

        // Check reset clears the output and counter.
        enable = 1'b1;
        reset_n = 1'b0;
        wait_clocks(1);
        if (pwm_out !== {NUM_CHANNELS{1'b0}}) begin
            $display("FAIL: reset should clear outputs");
            errors = errors + 1;
        end else $display("PASS: reset control");

        if (errors == 0)
            $display("\nALL PWM TESTS PASSED");
        else
            $display("\nPWM TESTS FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule
