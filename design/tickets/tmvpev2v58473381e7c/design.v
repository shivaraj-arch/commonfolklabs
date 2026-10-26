// Title: Bidirectional Multi-Track Railway Crossing Interlocking and Fault Detection System
// Module: dut

module dut (
    input  wire       clk,
    input  wire       rst_n,             // Active-low master reset
    input  wire       A,                 // Track 1 Sensor A
    input  wire       B,                 // Track 1 Sensor B
    input  wire       C,                 // Track 2 Sensor C
    input  wire       D,                 // Track 2 Sensor D
    input  wire       T1_CLEAR,          // Track 1 Clear Confirmation
    input  wire       T2_CLEAR,          // Track 2 Clear Confirmation
    input  wire       GATE_CLOSED_FB,    // Feedback: Gate fully closed
    input  wire       GATE_OPEN_FB,      // Feedback: Gate fully open
    input  wire       RESET_SW,          // Manual fault reset switch
    input  wire       EMERGENCY,         // Emergency input signal

    output reg        led_red_stop,       // Road STOP LED
    output reg        led_green_go,       // Road GO LED
    output reg        led_yellow_warn,    // Road Warning LED
    output reg        cmd_gate_close,     // Gate Close Actuator Command
    output reg        cmd_gate_open,      // Gate Open Actuator Command
    output reg        led_gate_closed_fb, // Gate Closed Status LED
    output reg        led_fault,          // System Fault LED
    output reg        led_t1_active,      // Track 1 Occupied LED
    output reg        led_t2_active,      // Track 2 Occupied LED
    output reg        led_t1_d1,          // Track 1 Dir 1 (A->B) LED
    output reg        led_t1_d2,          // Track 1 Dir 2 (B->A) LED
    output reg        led_t2_d1,          // Track 2 Dir 1 (C->D) LED
    output reg        led_t2_d2,          // Track 2 Dir 2 (D->C) LED
    output reg        buzzer,             // Warning Buzzer
    output reg  [6:0] seg7                // 7-Segment State/Fault Display (g-f-e-d-c-b-a)
);

    // FSM State Encoding
    localparam S_IDLE      = 3'b000; // State 0
    localparam S_WARNING   = 3'b001; // State 1
    localparam S_CLOSING   = 3'b010; // State 2
    localparam S_CLOSED    = 3'b011; // State 3
    localparam S_CLEARANCE = 3'b100; // State 4
    localparam S_REOPENING = 3'b101; // State 5
    localparam S_FAULT     = 3'b110; // State 6 / Fault state

    reg [2:0] state, next_state;
    reg [7:0] timer;

    // Track Occupancy and Direction Registers
    reg t1_act, t1_dir1, t1_dir2;
    reg t2_act, t2_dir1, t2_dir2;
    reg seq_fault;

    // Direct Gate Feedback Fault (Both sensors active simultaneously is illegal)
    wire fb_fault = (GATE_CLOSED_FB && GATE_OPEN_FB);
    wire effective_seq_fault = seq_fault && !RESET_SW;

    // Track 1 Direction and Occupancy Detector
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            t1_act  <= 1'b0;
            t1_dir1 <= 1'b0;
            t1_dir2 <= 1'b0;
        end else if (RESET_SW || T1_CLEAR) begin
            t1_act  <= 1'b0;
            t1_dir1 <= 1'b0;
            t1_dir2 <= 1'b0;
        end else if (!t1_act) begin
            if (A && !B) begin
                t1_act  <= 1'b1;
                t1_dir1 <= 1'b1;
                t1_dir2 <= 1'b0;
            end else if (B && !A) begin
                t1_act  <= 1'b1;
                t1_dir1 <= 1'b0;
                t1_dir2 <= 1'b1;
            end
        end
    end

    // Track 2 Direction and Occupancy Detector
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            t2_act  <= 1'b0;
            t2_dir1 <= 1'b0;
            t2_dir2 <= 1'b0;
        end else if (RESET_SW || T2_CLEAR) begin
            t2_act  <= 1'b0;
            t2_dir1 <= 1'b0;
            t2_dir2 <= 1'b0;
        end else if (!t2_act) begin
            if (C && !D) begin
                t2_act  <= 1'b1;
                t2_dir1 <= 1'b1;
                t2_dir2 <= 1'b0;
            end else if (D && !C) begin
                t2_act  <= 1'b1;
                t2_dir1 <= 1'b0;
                t2_dir2 <= 1'b1;
            end
        end
    end

    // Sequence Fault Detection Logic (Simultaneous sensor trips from IDLE)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seq_fault <= 1'b0;
        end else if (RESET_SW) begin
            seq_fault <= 1'b0;
        end else begin
            if (!t1_act && A && B) seq_fault <= 1'b1;
            if (!t2_act && C && D) seq_fault <= 1'b1;
        end
    end

    // FSM Sequential Logic with Timers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
            timer <= 8'd0;
        end else begin
            if (fb_fault || effective_seq_fault) begin
                state <= S_FAULT;
                timer <= 8'd0;
            end else if (EMERGENCY && (state == S_IDLE || state == S_REOPENING || state == S_CLEARANCE)) begin
                state <= S_WARNING;
                timer <= 8'd0;
            end else begin
                state <= next_state;
                if (state != next_state) begin
                    timer <= 8'd0;
                end else begin
                    timer <= timer + 1'b1;
                end
            end
        end
    end

    // Combined Track Logic Signals
    wire track_req  = t1_act || t2_act || A || B || C || D;
    wire both_clear = T1_CLEAR && T2_CLEAR && !A && !B && !C && !D;

    // FSM Next State Logic
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE: begin
                if (track_req || EMERGENCY) begin
                    next_state = S_WARNING;
                end
            end

            S_WARNING: begin
                if (timer >= 8'd4) begin // Warning phase delay
                    next_state = S_CLOSING;
                end
            end

            S_CLOSING: begin
                if (GATE_CLOSED_FB && !GATE_OPEN_FB) begin
                    next_state = S_CLOSED;
                end else if (timer >= 8'd12) begin // Gate close timeout fault
                    next_state = S_FAULT;
                end
            end

            S_CLOSED: begin
                if (both_clear && !EMERGENCY) begin
                    next_state = S_CLEARANCE;
                end
            end

            S_CLEARANCE: begin
                if (track_req || EMERGENCY) begin
                    next_state = S_CLOSED;
                end else if (timer >= 8'd3) begin // Clearance safety buffer
                    next_state = S_REOPENING;
                end
            end

            S_REOPENING: begin
                if (track_req || EMERGENCY) begin
                    next_state = S_WARNING;
                end else if (GATE_OPEN_FB && !GATE_CLOSED_FB) begin
                    next_state = S_IDLE;
                end else if (timer >= 8'd12) begin // Gate open timeout fault
                    next_state = S_FAULT;
                end
            end

            S_FAULT: begin
                if (RESET_SW && !fb_fault && !EMERGENCY) begin
                    if (GATE_CLOSED_FB && !GATE_OPEN_FB)
                        next_state = S_CLOSED;
                    else if (GATE_OPEN_FB && !GATE_CLOSED_FB && !track_req)
                        next_state = S_IDLE;
                    else if (GATE_OPEN_FB && !GATE_CLOSED_FB && track_req)
                        next_state = S_WARNING;
                end
            end

            default: next_state = S_IDLE;
        endcase
    end

    // Combinational Output Decoding
    always @(*) begin
        // Output defaults
        led_red_stop       = 1'b0;
        led_green_go       = 1'b0;
        led_yellow_warn    = 1'b0;
        cmd_gate_close     = 1'b0;
        cmd_gate_open      = 1'b0;
        led_gate_closed_fb = GATE_CLOSED_FB;
        led_fault          = 1'b0;
        buzzer             = 1'b0;

        led_t1_active      = t1_act;
        led_t2_active      = t2_act;
        led_t1_d1          = t1_dir1;
        led_t1_d2          = t1_dir2;
        led_t2_d1          = t2_dir1;
        led_t2_d2          = t2_dir2;

        case (state)
            S_IDLE: begin
                led_green_go = 1'b1;
            end
            S_WARNING: begin
                led_red_stop    = 1'b1;
                led_yellow_warn = 1'b1;
                buzzer          = 1'b1;
            end
            S_CLOSING: begin
                led_red_stop   = 1'b1;
                cmd_gate_close = 1'b1;
                buzzer         = 1'b1;
            end
            S_CLOSED: begin
                led_red_stop   = 1'b1;
                cmd_gate_close = 1'b1;
            end
            S_CLEARANCE: begin
                led_red_stop   = 1'b1;
                cmd_gate_close = 1'b1;
            end
            S_REOPENING: begin
                led_red_stop  = 1'b1;
                cmd_gate_open = 1'b1;
            end
            S_FAULT: begin
                led_red_stop = 1'b1;
                led_fault    = 1'b1;
                buzzer       = 1'b1;
            end
            default: begin
                led_red_stop = 1'b1;
            end
        endcase
    end

    // 7-Segment Display Decoder (Active-high g-f-e-d-c-b-a)
    always @(*) begin
        case (state)
            S_IDLE:      seg7 = 7'b0111111; // Display '0'
            S_WARNING:   seg7 = 7'b0000110; // Display '1'
            S_CLOSING:   seg7 = 7'b1011011; // Display '2'
            S_CLOSED:    seg7 = 7'b1001111; // Display '3'
            S_CLEARANCE: seg7 = 7'b1100110; // Display '4'
            S_REOPENING: seg7 = 7'b1101101; // Display '5'
            S_FAULT:     seg7 = 7'b1110001; // Display 'F'
            default:     seg7 = 7'b0000000;
        endcase
    end

endmodule
