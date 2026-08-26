// Copyright 2026 Open Circuit Design LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// type: Split2000
//
// This cell has the basic form of a Filler2000 cell, but removes the two
// "vdd" buses, such that the 1.2V power domains end on either side of
// this cell, splitting the domain (however, the ground domain cannot be
// split, as it is shorted through the substrate).

`timescale 1ns/10ps
`celldefine
module sg13cmos5l_ocd_Split2000 (iovdd, iovss, vss);
	inout iovdd;
	inout iovss;
	inout vss;
endmodule
`endcelldefine

