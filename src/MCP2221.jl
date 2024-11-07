struct MCP2221Interface
    device::Ptr
end

# Function to open a connection to the MCP2221
function MCP2221_connect(vid::UInt16, pid::UInt16)
    
    mcp2221 = MCP2221Interface(HidApi.hid_open(vid, pid, C_NULL))

    if mcp2221.device === C_NULL
        @printf("Failed to connect to MCP2221 device with VID:PID = %X:%X\n", vid, pid)
    else
        @printf("MCP2221 device connected successfully!\n")
    end

    return mcp2221
end

function MCP2221_reset(mcp::MCP2221Interface)
    # reset MCP2221
    command_buffer = fill(UInt8(0x00), 64)
    command_buffer[2] = 0x70 # command code
    command_buffer[3] = 0xAB # index 1
    command_buffer[4] = 0xCD # index 2 
    command_buffer[5] = 0xEF # index 3

    res = HidApi.hid_write(mcp.device, command_buffer, 65)
    if res < 0
        error("Failed to hid write command (error #01)")
    end
end

function MCP2221_disconnect(mcp::MCP2221Interface)

    HidApi.hid_close(mcp.device)

    @printf("MCP2221 disconnected!")
end

# Function to reset I2C BUS of MCP2221
function MCP2221_I2C_Initialize(mcp::MCP2221Interface)
    
    # Cancel I2C current transfer, no effect for I2C speed (100 kHz)
    cmd = UInt8[0x00, 0x10, 0x00, 0x10, 0x00, 0x00, 0x00]
    res = HidApi.hid_write(mcp.device, cmd, 65)
    if res < 0
        error("Failed to hid write command (error #01)")
    end

    response = Vector{UInt8}(undef, 64)
    res2 = HidApi.hid_read_timeout(mcp.device, response, 65, 1000)  # Read with a timeout of 1000 ms

    if res2 < 0
        error("Failed to hid read timeout command (error #02)")
    end
  
    #=
    for (index, value) in pairs(response)
        @printf "response[%d] = %x\n" index value
    end
    =#

    if(response[1] == 0x10 && response[2] == 0)
        @printf("MCP2221 I2C bus initialized successfully!")
    else    
        error("Something went wrong...please reconnect")
    end

end