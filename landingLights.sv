module landingLights (clk, reset, SW, LEDR );
	input  logic clk, reset;
	input logic  [1:0] SW;
	output logic [2:0] LEDR;

	logic [2:0] ps; // Present State
	logic [2:0] ns; // Next State

	// State encoding
	parameter [2:0] A = 3'b101, B = 3'b001, C = 3'b010, D = 3'b100;

	// Next State logic
	always_comb
		case (ps)
			A: if (~SW[1] & ~SW[0])	ns = C;  //00 & 101 --> 010
				else if (~SW[1] & SW[0]) ns = B; //01 & 101 --> 001;
				else if (SW[1] & ~SW[0]) ns = D; //10 & 101 --> 100;
				else		ns = 3'bxxx;	
			B: if (~SW[1] & ~SW[0])	ns = A;  //00 & 001 --> 101
				else if (~SW[1] & SW[0]) ns = C; //01 & 001 --> 010;
				else if (SW[1] & ~SW[0]) ns = D; //10 & 001 --> 100;
				else		ns = 3'bxxx;
			C: if (~SW[1] & ~SW[0])	ns = A;  //00 & 010 --> 101
				else if (~SW[1] & SW[0]) ns = D; //01 & 010 --> 100;
				else if (SW[1] & ~SW[0]) ns = B; //10 & 001 --> 001;
				else		ns = 3'bxxx;
			D: if (~SW[1] & ~SW[0])	ns = A;  //00 & 100 --> 101
				else if (~SW[1] & SW[0]) ns = B; //01 & 100 --> 001;
				else if (SW[1] & ~SW[0]) ns = C; //10 & 100 --> 010;
				else		ns = 3'bxxx;
			default:		ns = A;
		endcase

	// Output logic - could also be another always, or part of above block
	assign LEDR = ps;

	// DFFs
	always_ff @(posedge clk)
		if (reset)
			ps <= A;
		else
			ps <= ns;

endmodule


module landingLights_testbench();
	logic clk, reset;
	logic  [1:0] SW;
	logic [2:0] LEDR;

	landingLights dut (clk, reset, SW, LEDR);
    
	// Set up the clock
	parameter CLOCK_PERIOD = 100;
	initial begin
    	clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		@(posedge clk); reset <= 1;
		@(posedge clk); reset <= 0; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk); SW[1] <= 0; SW[0] <= 0;
		@(posedge clk);             
		@(posedge clk);             
		@(posedge clk);
		@(posedge clk); SW[1] <= 0; SW[0] <= 1;
		@(posedge clk);
		@(posedge clk);             
		@(posedge clk);
		@(posedge clk); SW[1] <= 1; SW[0] <= 0;
		@(posedge clk);
		@(posedge clk);             
		@(posedge clk);
		@(posedge clk); SW[1] <= 1; SW[0] <= 1;

		$stop; // End the simulation
	end
endmodule