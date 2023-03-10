if Debug then Debug.beginFile "SaveLoadUtils" end
--[[
    Lua Codeless Save Load FileIO Utils

    These files were adapted/taken directly from https://github.com/aiq/basexx

    Modified slightly for Warcraft 3 syntax

    Updated: March 8 2023
--]]

Base64Encode = {}
Base32Encode = {}

function SerializeTable(val, name, skipnewlines, depth)
skipnewlines = skipnewlines or false
depth = depth or 0

local tmp = string.rep(" ", depth)

if name then tmp = tmp .. name .. " = " end

if type(val) == "table" then
    tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

    for k, v in pairs(val) do
        tmp =  tmp .. SerializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
    end

    tmp = tmp .. string.rep(" ", depth) .. "}"
elseif type(val) == "number" then
    tmp = tmp .. tostring(val)
elseif type(val) == "string" then
    tmp = tmp .. string.format("%%q", val)
elseif type(val) == "boolean" then
    tmp = tmp .. (val and "true" or "false")
else
    tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
end

return tmp
end

--------------------------------------------------------------------------------
-- Base64Encode && Base32Encode util functions
--------------------------------------------------------------------------------

function divide_string( str, max )
    local result = {}

    local start = 1
    for i = 1, #str do
        if i %% max == 0 then
            table.insert( result, str:sub( start, i ) )
            start = i + 1
        elseif i == #str then
            table.insert( result, str:sub( start, i ) )
        end
    end

    return result
end

function number_to_bit( num, length )
    local bits = {}

    while num > 0 do
        local rest = math.floor( math.fmod( num, 2 ) )
        table.insert( bits, rest )
        num = ( num - rest ) / 2
    end

    while #bits < length do
        table.insert( bits, "0" )
    end

    return string.reverse( table.concat( bits ) )
end

function ignore_set( str, set )
    if set then
        str = str:gsub( "["..set.."]", "" )
    end
    return str
end

function pure_from_bit( str )
    return ( str:gsub( '........', function ( cc )
                return string.char( tonumber( cc, 2 ) )
            end ) )
end

function unexpected_char_error( str, pos )
    local c = string.sub( str, pos, pos )
    return string.format( "unexpected character at position %%d: '%%s'", pos, c )
end

bitMap = { o = "0", i = "1", l = "1" }

function from_bit( str, ignore )
   str = ignore_set( str, ignore )
   str = string.lower( str )
   str = str:gsub( '[ilo]', function( c ) return bitMap[ c ] end )
   local pos = string.find( str, "[^01]" )
   if pos then return nil, unexpected_char_error( str, pos ) end

   return pure_from_bit( str )
end

function to_bit( str )
   return ( str:gsub( '.', function ( c )
               local byte = string.byte( c )
               local bits = {}
               for _ = 1,8 do
                  table.insert( bits, byte %% 2 )
                  byte = math.floor( byte / 2 )
               end
               return table.concat( bits ):reverse()
            end ) )
end

function from_basexx( str, alphabet, bits )
    local result = {}
    for i = 1, #str do
        local c = string.sub( str, i, i )
        if c ~= '=' then
            local index = string.find( alphabet, c, 1, true )
            if not index then
                return nil, unexpected_char_error( str, i )
            end
            table.insert( result, number_to_bit( index - 1, bits ) )
        end
    end

    local value = table.concat( result )
    local pad = #value %% 8
    return pure_from_bit( string.sub( value, 1, #value - pad ) )
    end

function to_basexx( str, alphabet, bits, pad )
    local bitString = to_bit( str )

    local chunks = divide_string( bitString, bits )
    local result = {}
    for _,value in ipairs( chunks ) do
        if ( #value < bits ) then
            value = value .. string.rep( '0', bits - #value )
        end
        local pos = tonumber( value, 2 ) + 1
        table.insert( result, alphabet:sub( pos, pos ) )
    end

    table.insert( result, pad )
    return table.concat( result )   
end


url64Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
                    "abcdefghijklmnopqrstuvwxyz"..
                    "0123456789-_"

function Base64Encode.from_url64( str, ignore )
    str = ignore_set( str, ignore )
    return from_basexx( str, url64Alphabet, 6 )
end

function Base64Encode.to_url64( str )
    return to_basexx( str, url64Alphabet, 6, "" )
end

function Base32Encode.from_url32( str, ignore )
    str = ignore_set( str, ignore )
    return from_basexx( str, url64Alphabet, 5 )
end

function Base32Encode.to_url32( str )
    return to_basexx( str, url64Alphabet, 5, "" )
end

if Debug then Debug.endFile() end