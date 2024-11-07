module AR_ADC_DAC

using HidApi
using Printf

include("MCP2221.jl") 
include("MCP47FEB01.jl") 

# Export MCP2221 functions
export MCP2221Interface,MCP2221_connect,MCP2221_reset,MCP2221_disconnect,MCP2221_I2C_Initialize

# Export MCP47FEB01 functions
export MCP47FEB01_Set_DAC_Volatile_Value,MCP47FEB01_Get_DAC_Volatile_Value

# Export MCP3021 functions

end