local x = 42;
local y = 43;

local a = x < y;
local b = x > y;
local c = x == y;
local d = x != y;
local e = x <=> y;
local f = x <= y;
local g = x >= y;

// Doesn't appear to support constants _in_ the instruction;
// the 50 is loaded to a register.
local h = x < 50;
local i = x > 50;
local j = x == 50;
local k = x != 50;
local l = x <= 50;
local m = x >= 50;
local n = x <=> 50;

local s = "Foo"
local o = s == "Foo";
local p = s != "Bar";
local q = "Foo" == "Bar";

// TODO: More string comparisons
// TODO: Floats
// TODO: Mixtures
