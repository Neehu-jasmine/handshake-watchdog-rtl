`timescale 1ns / 1ps

module handshake_watchdog #(
    parameter TIMEOUT_LIMIT = 4
)(
    input  wire clk,
    input  wire reset,

    input  wire valid,
    input  wire ready,

    output reg  timeout,
    output wire handshake
);

    // Counter width automatically adapts to TIMEOUT_LIMIT
    localparam COUNT_WIDTH =
        (TIMEOUT_LIMIT < 2) ? 1 : $clog2(TIMEOUT_LIMIT + 1);

    // Counts how many clock cycles VALID has been waiting
    reg [COUNT_WIDTH-1:0] wait_count;

    // Handshake occurs when both VALID and READY are high
    assign handshake = valid && ready;

    // Watchdog logic
    always @(posedge clk) begin

        if (reset) begin
            wait_count <= 0;
            timeout    <= 0;
        end

        else begin

            // Successful handshake
            if (handshake) begin
                wait_count <= 0;
                timeout    <= 0;
            end

            // Sender is waiting for receiver
            else if (valid && !ready) begin

                if (wait_count >= TIMEOUT_LIMIT - 1) begin
                    timeout <= 1;
                end

                else begin
                    wait_count <= wait_count + 1'b1;
                    timeout    <= 0;
                end
            end

            // No valid transaction
            else begin
                wait_count <= 0;
                timeout    <= 0;
            end
        end
    end

endmodule
