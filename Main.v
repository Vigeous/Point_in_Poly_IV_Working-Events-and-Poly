//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ABS Global
// Engineer: Shane Peterson
// 
// Create Date:    14:02:26 08/21/2012 
// Design Name: 
// Module Name:    Main 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
/*
library IEEE;
library UNISIM;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
*/


module Main(CLK, reset, out, Event, Span, Peak, ADC_In, Event_Out, Trig_Out
    );


//------------Input Ports--------------
input  	CLK;
input 	reset;
input		ADC_In;
//------------Output Ports--------------
output	out;
output	Event;
output	Span;
output	Peak;
output	Event_Out;
output	Trig_Out;

//------------Internal Variables--------
reg 	[11:0]	out 		= 12'b000000000000;
reg				Event		= 0;
reg				End_Event = 0;
reg	[7:0]		End_Event_Count = 0;
reg				Event_Inside = 0;
reg	[3:0]		Boundary = 0;
reg	[3:0]		Point_Intersect = 0;
wire	[7:0]		ADC_In;
reg				Event_Out = 0;
reg				Trig_Out = 0;
reg				Span_Flag = 0;
reg	[4:0]		Trig_Count = 0;
reg	[2:0]		a = 0;
reg	[2:0]		b = 0;
reg	[5:0]		i1 = 0;
reg	[4:0]		i2 = 0;
reg	[5:0]		i3 = 0;
reg	[5:0]		i4 = 0;
reg	[5:0]		i5 = 0;
reg signed		[8:0]			Peak		= 0;
reg signed		[12:0]		Span		= 0;
reg 		[11:0]		Span_Count	= 0;	// 12 bit number, can count up to 1024, where 16.7nsec per count, where 1usec = ~60 counts
reg signed	[9:0]		Bound_Peak [4:0];
reg signed	[12:0]	Bound_Span [4:0];
reg			[1:0]		Count_CLK = 0;
reg						Sub_CLK;

reg signed	[24:0]	Compare_Right [4:0];
reg signed	[24:0]	Compare_Left [4:0];




reg			[4:0]		Baseline_Count = 0;
reg			[2:0]		ADC_Count = 0;
reg			[7:0]		ADC_Buf = 0;
reg			[7:0]		Baseline_Rolling_Buf [31:0];
reg			[7:0]		Baseline = 0;
reg			[7:0]		ADC_Rolling_Buf [7:0];
reg			[10:0]	ADC_Value = 0;
reg			[7:0]		Threshold = 15;
reg			[3:0]		Event_Check_Count = 0;
reg			[7:0]		Half_Peak = 0;



wire	linear_feedback1;
wire	linear_feedback2;
wire	linear_feedback3;
////////////////////////////

////////////////////////////
assign linear_feedback1 =  ! (out[7] ^ out[5]);
assign linear_feedback2 =  ! (out[4] ^ linear_feedback1);
assign linear_feedback3 =  ! (out[2] ^ linear_feedback2);


initial begin

Bound_Peak[0]	=	110;
	Bound_Span[0]	=	250;
Bound_Peak[1]	=	150;
	Bound_Span[1]	=	175;
Bound_Peak[2]	=	130;
	Bound_Span[2]	=	100;
Bound_Peak[3]	=	90;
	Bound_Span[3]	=	100;
Bound_Peak[4]	=	70;
	Bound_Span[4]	=	175;

/*
Bound_Peak[0]	=	120;
	Bound_Span[0]	=	250;
Bound_Peak[1]	=	140;
	Bound_Span[1]	=	200;
Bound_Peak[2]	=	130;
	Bound_Span[2]	=	150;
Bound_Peak[3]	=	110;
	Bound_Span[3]	=	150;
Bound_Peak[4]	=	100;
	Bound_Span[4]	=	200;
*/

ADC_Rolling_Buf[0] = 0;
ADC_Rolling_Buf[1] = 0;
ADC_Rolling_Buf[2] = 0;
ADC_Rolling_Buf[3] = 0;
ADC_Rolling_Buf[4] = 0;
ADC_Rolling_Buf[5] = 0;
ADC_Rolling_Buf[6] = 0;
ADC_Rolling_Buf[7] = 0;

Baseline_Rolling_Buf[0] = 0;
Baseline_Rolling_Buf[1] = 0;
Baseline_Rolling_Buf[2] = 0;
Baseline_Rolling_Buf[3] = 0;
Baseline_Rolling_Buf[4] = 0;
Baseline_Rolling_Buf[5] = 0;
Baseline_Rolling_Buf[6] = 0;
Baseline_Rolling_Buf[7] = 0;
Baseline_Rolling_Buf[8] = 0;
Baseline_Rolling_Buf[9] = 0;
Baseline_Rolling_Buf[10] = 0;
Baseline_Rolling_Buf[11] = 0;
Baseline_Rolling_Buf[12] = 0;
Baseline_Rolling_Buf[13] = 0;
Baseline_Rolling_Buf[14] = 0;
Baseline_Rolling_Buf[15] = 0;
Baseline_Rolling_Buf[16] = 0;
Baseline_Rolling_Buf[17] = 0;
Baseline_Rolling_Buf[18] = 0;
Baseline_Rolling_Buf[19] = 0;
Baseline_Rolling_Buf[20] = 0;
Baseline_Rolling_Buf[21] = 0;
Baseline_Rolling_Buf[22] = 0;
Baseline_Rolling_Buf[23] = 0;
Baseline_Rolling_Buf[24] = 0;
Baseline_Rolling_Buf[25] = 0;
Baseline_Rolling_Buf[26] = 0;
Baseline_Rolling_Buf[27] = 0;
Baseline_Rolling_Buf[28] = 0;
Baseline_Rolling_Buf[29] = 0;
Baseline_Rolling_Buf[30] = 0;
Baseline_Rolling_Buf[31] = 0;

end




//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//This Module generates random numbers

always @(posedge CLK) begin
if (reset) begin // active high reset
   out <= 12'b0 ;
end
else begin
	out <= { out[10],out[9],
				out[8],out[7],
				out[6],out[5],
				out[4],out[3],
				out[2],out[1],
				out[0], linear_feedback3
				};
end


	Count_CLK = Count_CLK + 1;

	if (Count_CLK < 2) begin
		Sub_CLK = 1;
	end
	else begin
		Sub_CLK = 0;
	end
	

assign Event_Out = Event;
end // end always at posedge CLK



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

always @(posedge CLK) begin

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
//Module calcs the ADC_Value using the last 2 samples in rolling buffer

// always take samples, and update ADC rolling buffers
	ADC_Count = ADC_Count + 1;
	ADC_Buf = ADC_In;												//Buffer ADC input
	ADC_Rolling_Buf[ADC_Count] = ADC_Buf;					//fill rolling buffer with last 8 samples, for ADC_Value calc


	for (i2=0; i2<10; i2=i2+1) begin
		if (i2 == 0) begin
		ADC_Value = 0;
		end
		if (   (i2 > 0)  &&  (i2 < 9) ) begin
		ADC_Value = ADC_Value + ADC_Rolling_Buf[i2-1];
		end
		if (i2 == 9) begin
		ADC_Value = (ADC_Value >> 3);		// divide by 8
		end
	end

////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
//Module calcs the Baseline using the last 32 samples in rolling buffer
if (Event_Check_Count == 0) begin		// If ADC value above threshold, stop updating baseline and threshold, to check to see if event,
													//		filter for noise at neg CLK edge

Baseline_Count = Baseline_Count + 1;					
Baseline_Rolling_Buf[Baseline_Count] = ADC_Buf;		//fill rolling buffer with last 32 samples, for baseline calc
	
	
	for (i1=0; i1<36; i1=i1+1) begin
		if (i1 == 0) begin
		Baseline = 0;
		end
		if (   (i1 > 0)  &&  (i1 < 33) ) begin
		Baseline = Baseline + Baseline_Rolling_Buf[i1-1];
		end
		if (i1 == 33) begin
		Baseline = (Baseline >> 5);	// divid by 32
		end
		if (i1 == 35) begin
	//	Threshold = Baseline;
		Threshold = 15; // 10 is default
		end
	end


end	// end Event_Check_Count
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This module checks to see if we are in an event, and does event handling; gather peak information, half max span information,
//		and declares End_Event condition
			if (Event == 0) begin
				if (ADC_Value > Threshold) begin
						Event_Check_Count = Event_Check_Count + 1;	// If ADC is above threshold, increment counter, require consequetive samples to be above
						if (Event_Check_Count > 4) begin					//		threshold to confirm event, not noise
							Event = 1;
							Peak = 0;
							Half_Peak = 0;
							Span_Count = 0;
							Span = 0;
							Span_Flag = 0;
						end					
				end // end if ADC_Value > threshold
				else begin
					Event_Check_Count = 0;								// If ADC is below threshold, reset counter
				end
			end // end if Event == 0
			
				
			if (Event == 1) begin
				
				if (ADC_Value > Peak) begin
				Peak = ADC_Value; // Peak saved in absolute terms
					if (ADC_Value > Baseline) begin	// Due to noise, sometimes the ADC value, can be less than baseline, causing number to loop around
					Half_Peak = (ADC_Value >> 1);	
				//	Half_Peak =  (   (  (ADC_Value - Baseline) >> 1)   +  Baseline);  //Divid baseline adjusted Peak by 2, adjusted back by baseline to have absolute value
					end
				Span_Count = 0;	// reset span count every time a new highest point on curve found
				end
				
				if (Span_Flag == 0) begin
					Span_Count = Span_Count + 1;	//increment Span, and stop once span pin is high, indicating Half Max Condition met
					if (Span_Count > 10) begin
						if (ADC_Value < Half_Peak) begin
						Span = (Span_Count << 1);		//Double Span count, counted from Peak, to half peak, double to get full span at half max.
						Span_Flag = 1;
						end
					end // end if Span > 10
				end // end if Span_Flag = 0
				
				if (ADC_Value < (Threshold - 1)    ) begin	//add hystersis to threshold if event detected
					Event = 0;
					End_Event = 1;
					End_Event_Count = 0;
				end
				
			end // end if Event == 1
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This module tests the point (Peak, Span) against my gate after the End_Event condition met

	if (End_Event == 1) begin
	
// Correction factor for test point intersecting Polygon points
/*		if(End_Event_Count == 3) begin
				for (i3=0; i3<5; i3=i3 + 1) begin	
					if (Bound_Span[i3] == Span) begin
						if (Bound_Peak[i3] > Peak) begin
							Point_Intersect = Point_Intersect + 1;
							//Point_Intersect = 0;
						end
					end
				end
			end
*/

		if ( (  End_Event_Count > 5)    &&    (End_Event_Count < 11)   ) begin
			case (   (End_Event_Count - 6)  )
			0: begin a = 0; b = 1; end
			1: begin a = 1; b = 2; end
			2: begin a = 2; b = 3; end
			3: begin a = 3; b = 4; end
			4: begin a = 4; b = 0; end
			endcase





			if ( Bound_Span[a] < Bound_Span[b]) begin
				if ( (Bound_Span[a] <= Span) && (Span <= Bound_Span[b]) ) begin
				Compare_Right[(End_Event_Count - 6)] = (Bound_Peak[b] - Bound_Peak[a])*(Span - Bound_Span[a]) + (Bound_Peak[a]*(Bound_Span[b] - Bound_Span[a]));
				Compare_Left[(End_Event_Count - 6)] = Peak * (Bound_Span[b] - Bound_Span[a]);
				end
				else begin
				Compare_Right[(End_Event_Count - 6)] = 0;
				Compare_Left[(End_Event_Count - 6)] = 1;
				end
			end
			else begin
				if ( (Bound_Span[b] <= Span) && (Span <= Bound_Span[a]) ) begin
				Compare_Right[(End_Event_Count - 6)] = (Bound_Peak[b] - Bound_Peak[a])*(Span - Bound_Span[a]) + (Bound_Peak[a]*(Bound_Span[b] - Bound_Span[a]));
				Compare_Left[(End_Event_Count - 6)] = Peak * (Bound_Span[b] - Bound_Span[a]);
				end
				else begin
				Compare_Right[(End_Event_Count - 6)] = 0;
				Compare_Left[(End_Event_Count - 6)] = 1;
				end
			end 

/*
	

			if ( Bound_Peak[a] < Bound_Peak[b]) begin
				if ( (Bound_Peak[a] <= Peak) && (Peak <= Bound_Peak[b]) ) begin
				Compare_Right[(End_Event_Count - 6)] = (Bound_Span[b] - Bound_Span[a])*(Peak - Bound_Peak[a]) + (Bound_Span[a]*(Bound_Peak[b] - Bound_Peak[a]));
				Compare_Left[(End_Event_Count - 6)] = Span * (Bound_Peak[b] - Bound_Peak[a]);
				end
				else begin
				Compare_Right[(End_Event_Count - 6)] = 0;		//debugged, number should be 0 for normal use
				Compare_Left[(End_Event_Count - 6)] = 1;		//debugged, number should be 1 for normal use
				end
			end
			else begin
				if ( (Bound_Peak[b] <= Peak) && (Peak <= Bound_Peak[a]) ) begin
				Compare_Right[(End_Event_Count - 6)] = (Bound_Span[b] - Bound_Span[a])*(Peak - Bound_Peak[a]) + (Bound_Span[a]*(Bound_Peak[b] - Bound_Peak[a]));
				Compare_Left[(End_Event_Count - 6)] = Span * (Bound_Peak[b] - Bound_Peak[a]);
				end
				else begin
				Compare_Right[(End_Event_Count - 6)] = 0;		//debugged, number should be 0 for normal use
				Compare_Left[(End_Event_Count - 6)] = 1;		//debugged, number should be 1 for normal use
				end
			end 
*/
		end // end endEvent count between 5 and 11
		
		
		End_Event_Count = End_Event_Count + 1;	// found that this works best here, moved from top of module
		


	if (End_Event_Count == 14) begin
		for (i4=0; i4<5; i4 = i4 + 1) begin
			if (Compare_Left[i4][24] == 1) begin
			Compare_Left[i4] = (-1)*(Compare_Left[i4]);
			end
			if (Compare_Right[i4][24] == 1) begin
			Compare_Right[i4] = (-1)*(Compare_Right[i4]);
			end
		end
	end
	

	if (End_Event_Count == 19) begin
		for (i5=0; i5<5; i5 = i5 + 1) begin
			if (Compare_Left[i5] < Compare_Right[i5]) begin
			Boundary = Boundary + 1;
			end
		end
	end

//	if (End_Event_Count == 21) begin
//		Boundary = Boundary + Point_Intersect;
//	end

	if (End_Event_Count == 24) begin
		if (Boundary[0] == 1) begin
			Event_Inside = 1;
		end
	end
	
	if (End_Event_Count == 26) begin
		Boundary = 0;
		End_Event = 0;
		Point_Intersect = 0;
	end


end // end EndEvent




	if (Event_Inside == 1) begin
		Trig_Count = Trig_Count + 1;
		if (Trig_Count > 30) begin
		Event_Inside = 0;
		Trig_Count = 0;
		end
	end // end Event_Inside == 1
	
assign Trig_Out = Event_Inside;



end //always @ posedge CLK     Debug, always @ posedge CLK moved here, original was higher in code
//end // always @ negedge CLK

endmodule


