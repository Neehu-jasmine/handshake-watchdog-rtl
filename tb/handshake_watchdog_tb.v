`timescale 1ns / 1ps

module handshake_watchdog_tb;

    // Testbench signals
    reg clk;
    reg reset;
    reg valid;
    reg ready;

    wire timeout;
    wire handshake;

    // --------------------------------
    // DUT
    // --------------------------------
    handshake_watchdog #(
        .TIMEOUT_LIMIT(4)
    ) dut (
        .clk       (clk),
        .reset     (reset),
        .valid     (valid),
        .ready     (ready),
        .timeout   (timeout),
        .handshake (handshake)
    );

    // --------------------------------
    // Clock generation
    // 10 ns period
    // --------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // --------------------------------
    // Test sequence
    // --------------------------------
    initial begin

        $display("======================================");
        $display(" HANDSHAKE WATCHDOG VERIFICATION");
        $display("======================================");

        // Initial state
        reset = 1;
        valid = 0;
        ready = 0;

        // --------------------------------
        // TEST 1: Reset
        // --------------------------------
        #20;

        reset = 0;

        if (timeout == 0)
            $display("PASS: Reset clears timeout");
        else
            $display("FAIL: Reset did not clear timeout");

        // --------------------------------
        // TEST 2: Normal handshake
        // --------------------------------
        valid = 1;
        ready = 1;

        #10;

        if (handshake == 1 && timeout == 0)
            $display("PASS: Normal handshake");
        else
            $display("FAIL: Normal handshake");

        // --------------------------------
        // TEST 3: Waiting condition
        // --------------------------------
        ready = 0;

        #10;

        if (handshake == 0)
            $display("PASS: Waiting condition detected");
        else
            $display("FAIL: Waiting condition");

        // --------------------------------
        // TEST 4: Timeout
        // --------------------------------
        #30;

        if (timeout == 1)
            $display("PASS: Timeout detected");
        else
            $display("FAIL: Timeout not detected");

        // --------------------------------
        // TEST 5: Timeout recovery
        // --------------------------------
        ready = 1;

        #10;

        if (handshake == 1 && timeout == 0)
            $display("PASS: Timeout recovery");
        else
            $display("FAIL: Timeout recovery");

        // --------------------------------
        // TEST 6: Idle state
        // --------------------------------
        valid = 0;
        ready = 0;

        #10;

        if (timeout == 0)
            $display("PASS: Idle state");
        else
            $display("FAIL: Idle state");

        // --------------------------------
        // TEST 7: Prolonged stall
        // --------------------------------
        valid = 1;
        ready = 0;

        #50;

        if (timeout == 1)
            $display("PASS: Prolonged stall timeout");
        else
            $display("FAIL: Prolonged stall timeout");

        // --------------------------------
        // TEST 8: Prolonged stall recovery
        // --------------------------------
        ready = 1;

        #10;

        if (handshake == 1 && timeout == 0)
            $display("PASS: Prolonged stall recovery");
        else
            $display("FAIL: Prolonged stall recovery");

        // --------------------------------
        // Verification complete
        // --------------------------------
        $display("======================================");
        $display(" VERIFICATION COMPLETE");
        $display("======================================");

        $finish;

    end

endmodule
