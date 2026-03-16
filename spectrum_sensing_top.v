module spectrum_sensing_top(
    input clk,
    input rst,
    input signed [11:0] sample_in,
    input sample_valid,
    output reg spectrum_busy
);

wire [31:0] energy;
wire done;
wire ai_decision;

parameter THRESHOLD = 32'd500000;

/* Energy Detector */
energy_detector ED(
    .clk(clk),
    .rst(rst),
    .sample(sample_in),
    .valid(sample_valid),
    .energy(energy),
    .done(done)
);

/* TinyML Decision Module */
tinyml_classifier AI(
    .energy(energy),
    .decision(ai_decision)
);

/* Final Decision */
always @(posedge clk)
begin
    if(done)
    begin
        if(ai_decision)
            spectrum_busy <= 1;
        else
            spectrum_busy <= 0;
    end
end

endmodule



/* ================= ENERGY DETECTOR ================= */

module energy_detector(
    input clk,
    input rst,
    input signed [11:0] sample,
    input valid,
    output reg [31:0] energy,
    output reg done
);

parameter N = 128;

reg [7:0] count;

always @(posedge clk)
begin
    if(rst)
    begin
        energy <= 0;
        count <= 0;
        done <= 0;
    end
    else if(valid)
    begin
        energy <= energy + sample * sample;
        count <= count + 1;

        if(count == N-1)
        begin
            done <= 1;
            count <= 0;
        end
        else
            done <= 0;
    end
end

endmodule



/* ================= TINYML CLASSIFIER ================= */

module tinyml_classifier(
    input [31:0] energy,
    output reg decision
);

parameter THRESHOLD = 32'd500000;

always @(*)
begin
    if(energy > THRESHOLD)
        decision = 1;
    else
        decision = 0;
end

endmodule