`timescale 1ns / 1ps

// Runtime-configurable, multi-channel PWM generator.
// period_cycles is the number of input clock cycles in one PWM period.
// Each channel has an independent duty_cycles value in the packed bus.
module configurable_pwm_generator #(
    parameter integer NUM_CHANNELS  = 4,
    parameter integer COUNTER_WIDTH = 32
) (
    input  wire                                      clk,
    input  wire                                      reset_n,
    input  wire                                      enable,
    input  wire [COUNTER_WIDTH-1:0]                  period_cycles,
    input  wire [NUM_CHANNELS*COUNTER_WIDTH-1:0]     duty_cycles,
    output reg  [NUM_CHANNELS-1:0]                   pwm_out
);

    reg [COUNTER_WIDTH-1:0] counter;
    wire [COUNTER_WIDTH-1:0] effective_period;

    // A zero period is treated as a one-clock period to avoid underflow.
    assign effective_period = (period_cycles == {COUNTER_WIDTH{1'b0}})
                            ? {{(COUNTER_WIDTH-1){1'b0}}, 1'b1}
                            : period_cycles;

    integer channel;

    always @(posedge clk) begin
        if (!reset_n) begin
            counter <= {COUNTER_WIDTH{1'b0}};
            pwm_out <= {NUM_CHANNELS{1'b0}};
        end else if (!enable) begin
            counter <= {COUNTER_WIDTH{1'b0}};
            pwm_out <= {NUM_CHANNELS{1'b0}};
        end else begin
            // Wrap after exactly effective_period clock cycles.
            if (counter >= (effective_period - 1'b1))
                counter <= {COUNTER_WIDTH{1'b0}};
            else
                counter <= counter + 1'b1;

            // Each channel compares the shared counter against its own duty.
            for (channel = 0; channel < NUM_CHANNELS; channel = channel + 1) begin
                if (counter < duty_cycles[channel*COUNTER_WIDTH +: COUNTER_WIDTH])
                    pwm_out[channel] <= 1'b1;
                else
                    pwm_out[channel] <= 1'b0;
            end
        end
    end

endmodule
