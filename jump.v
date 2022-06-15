module jump(l_button,r_button, clk, rst,led0,led1,led2,led3,led4,led5,level);
	
//================================================================
//  INPUT AND OUTPUT DECLARATION                         
//================================================================
	input clk, l_button,r_button,rst;
	output reg [7:0] led0,led1,led2,led3,led4,led5;
	reg [7:0] score;
	output reg [9:0] level;
	reg clk1,clk2,lose,left,right,stop,flag;
	reg [22:0] count,count1,count2,levelfreq;
	reg signed [3:0] x,y;
	reg floor [5:0][1:0];
	wire rand;
	wire [3:0] score1,score0;
	integer i;
	
//================================================================
//  System argu process                       
//================================================================
	always@(posedge clk or negedge rst)begin//clk1 for light func.
		if(~rst)begin
			count = 0;
			count1 = 0;
			count2 = 0;
			score = 0;
			clk1 = 0;
			clk2 = 0;
			level = 10'b0;
			levelfreq = 4000000;
		end
		else if(lose!=1)begin
			if(score%20==0)begin
				level = level<<1;
				level = level+1;
				levelfreq = levelfreq-300000;
				score= score + 1;
			end		
			else if(count2>=5000000)begin
				count2 = 0;
				score = score + 1;
			end
			else if(count>=levelfreq)begin//50000=1msec
				count = 0;
				clk1 = ~clk1;
			end
			else if(count1>=10)begin
				count1 = 0;
				clk2 = ~clk2;
			end
			else
				count1 = count1  +1;
				count = count + 1;
				count2 = count2 +1;
		end
		//lose = 1 do noting
	end
//================================================================
//  Background part.                         
//================================================================
	lfsr(.clk(clk1), .rst(rst), .Q(rand));
	always@(posedge clk1 or negedge rst)begin
		if(~rst)begin
		stop=1;
			for(i=0;i<6;i=i+1)begin
				floor[i][0]<=0;
				floor[i][1]<=0;
			end
			//inital state
			floor[0][1]<=1;
			floor[1][0]<=1;
			floor[2][0]<=1;
			floor[3][1]<=1;
			floor[4][0]<=1;
			floor[5][1]<=1;
		end
		else begin
			stop=0;
			for(i=0;i<5;i=i+1)begin
				floor[i][0] <= floor[i+1][0];
				floor[i][1] <= floor[i+1][1];
			end
			floor[5][rand]<=1;
			floor[5][~rand]<=0;
		end
	end
	
//================================================================
//  People part.                  
//================================================================
	always@(posedge clk2 or negedge rst)begin
		if(~rst)begin
			x=0;
		end
		else begin
			if (l_button==0)begin
					x=0;
			end
			if (r_button==0)begin
					x=1;
			end
		end
	end
	
	always@(posedge clk1 or negedge rst)begin
		if(~rst)begin
			y=3;
			lose=0;
		end
		else if (y<0)	lose=1;
		else if(stop==0)begin
			if ((floor[y][x])==1 )begin//not touch floor
				y=y-1;
			end
			else if ((floor[y][x])==0 ) begin//touch floor
				if (y!=5)	y=y+1;
				else y=y;
			end
		end
	end
	
//================================================================
//  Display for LEDs                         
//================================================================
	always@(lose or x or y)begin//ouput led0
		if(lose==1)begin
			case(score0)
				 4'b0000:	led0 = 8'b11000000;//0
				 4'b0001:	led0 = 8'b11111001;//1
				 4'b0010:	led0 = 8'b10100100;//2	
				 4'b0011:	led0 = 8'b10110000;//3	
				 4'b0100:	led0 = 8'b10011001;//4	
				 4'b0101:	led0 = 8'b10010010;//5	
				 4'b0110:	led0 = 8'b10000010;//6 
				 4'b0111:	led0 = 8'b11111000;//7	
				 4'b1000:	led0 = 8'b10000000;//8
				 4'b1001:	led0 = 8'b10011000;//9
				 default:	led0 = 8'b11111111;//all blind
			 endcase
		end
		else begin
			case({x,y})
				8'b00000101:begin
					case(floor[5][1])
						1'b0:led0=8'b11101110;//xy=05
						default:led0=8'b11011110;
					endcase
				end
				8'b00010101:begin
					case(floor[5][1])
						1'b0:led0=8'b11100111;//xy=15
						default:led0=8'b11010111;//xy=15
					endcase
				end
				default: begin
					case(floor[5][1])
						1'b0:led0 = 8'b11101111;
						default:led0 = 8'b11011111;
					endcase
				end
			endcase
		end
	end
	always@(lose or x or y)begin//ouput led1
		if(lose==1)begin
			case(score1)
				 4'b0000:	led1 = 8'b11000000;//0
				 4'b0001:	led1 = 8'b11111001;//1
				 4'b0010:	led1 = 8'b10100100;//2	
				 4'b0011:	led1 = 8'b10110000;//3	
				 4'b0100:	led1 = 8'b10011001;//4	
				 4'b0101:	led1 = 8'b10010010;//5	
				 4'b0110:	led1 = 8'b10000010;//6 
				 4'b0111:	led1 = 8'b11111000;//7	
				 4'b1000:	led1 = 8'b10000000;//8
				 4'b1001:	led1 = 8'b10011000;//9
				 default:	led1 = 8'b11111111;//all blind
			endcase
		end
		else begin
			case({x,y})
				8'b00000100:begin
					case(floor[4][1])
						1'b0:led1=8'b11101110;//xy=04
						default:led1=8'b11011110;//xy=04
					endcase
				end
				8'b00010100:begin
					case(floor[4][1])
						1'b0:led1=8'b11100111;//xy=14
						default:led1=8'b11010111;//xy=14
					endcase
				end
				default: begin
					case(floor[4][1])
						1'b0:led1 = 8'b11101111;
						default:led1 = 8'b11011111;
					endcase
				end
			endcase
		end
	end
	always@(lose or x or y)begin//ouput led2
		if(lose==1)begin
			led2=8'b11111111;
		end
		else begin
			case({x,y})
				8'b00000011:begin
					case(floor[3][1])
						1'b0:led2=8'b11101110;//xy=03
						default:led2=8'b11011110;//xy=03
					endcase
				end
				8'b00010011:begin
					case(floor[3][1])
						1'b0:led2=8'b11100111;//xy=13
						default:led2=8'b11010111;//xy=13
					endcase
				end
				default: begin
					case(floor[3][1])
						1'b0:led2 = 8'b11101111;
						default:led2 = 8'b11011111;
					endcase
				end
			endcase
		end
	end
	always@(lose or x or y)begin//ouput led3
		if(lose==1) begin
			led3=8'b11111111;
		end
		else begin
			case({x,y})
				8'b00000010:begin
					case(floor[2][1])
						1'b0:led3=8'b11101110;//xy=02
						default:led3=8'b11011110;//xy=02
					endcase
				end
				8'b00010010:begin
					case(floor[2][1])
						1'b0:led3=8'b11100111;//xy=12
						default:led3=8'b11010111;//xy=12
					endcase
				end
				default: begin
					case(floor[2][1])
						1'b0:led3 = 8'b11101111;
						default:led3 = 8'b11011111;
					endcase
				end
			endcase
		end
	end
	always@(lose or x or y)begin//ouput led4
		if(lose==1)begin
			led4=8'b11111111;
		end
		else begin
			case({x,y})
				6'b00000001:begin
					case(floor[1][1])
						1'b0:led4=8'b11101110;//xy=01
						default:led4=8'b11011110;//xy=01
					endcase
				end
				6'b00010001:begin
					case(floor[1][1])
						1'b0:led4=8'b11100111;//xy=11
						default:led4=8'b11010111;//xy=11
					endcase
				end
				default: begin
					case(floor[1][1])
						1'b0:led4 = 8'b11101111;
						default:led4 = 8'b11011111;
					endcase
				end
			endcase
		end
	end
	always@(lose or x or y)begin//ouput led5
		if(lose==1)begin
			led5=8'b10010010;
		end
		else begin
			case({x,y})
				8'b00000000:begin
					case(floor[0][1])
						1'b0:led5=8'b11101110;//xy=00
						default:led5=8'b11011110;//xy=00
					endcase
				end
				8'b00010000:begin
					case(floor[0][1])
						1'b0:led5=8'b11100111;//xy=10
						default:led5=8'b11010111;//xy=10
					endcase
				end
				//8'bxxxx1111:led5=8'b00000000;
				default: begin
					case(floor[0][1])
						1'b0:led5 = 8'b11101111;
						default:led5 = 8'b11011111;
					endcase
				end
			endcase
		end
	end
	bcd(.binary(score/2),.tens(score1),.ones(score0));
endmodule

//================================================================
//  Random var.                         
//================================================================
module lfsr(clk, rst, Q);
	input clk, rst;
	output [3:1] Q;
	reg [3:1] Q;


	always@(posedge clk or negedge rst)begin
 		if(~rst)
 			Q = 3'b100;
 		else
 			Q = {Q[2:1], Q[1]^Q[3]};
	end 
endmodule

//================================================================
//  Random var.                         
//================================================================
module bcd(binary, tens, ones);
	input [7:0] binary;
	output [3:0] tens;
	output [3:0] ones;
	reg [3:0] tens;
	reg [3:0] ones;
	integer i;
	always@(binary)
		begin
		tens = 0;
		ones = 0;
		for(i=7; i>=0; i=i-1)
		begin
			if(tens >=5)
				tens = tens + 3;
			if(ones >=5)
				ones = ones + 3;
			tens = tens <<1;
			tens[0] = ones[3];
			ones = ones <<1;
			ones[0] = binary[i];
		end
	end
endmodule
