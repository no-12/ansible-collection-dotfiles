#!/usr/bin/env bash

# map "caps lock" (0x700000039) to "F12" (0x700000045)
# switch "left option" (0x7000000E2) and "left command" (0x7000000E3)
# switch "right option" (0x7000000E6) and "right command" (0x7000000E7)
# switch "`/~" (0x700000035) and "§/±" (0x700000064)

key_map_apple=$(cat <<-END
{
    "UserKeyMapping":[
        {
            "HIDKeyboardModifierMappingSrc":0x700000039,
            "HIDKeyboardModifierMappingDst":0x700000045
        },
        {
            "HIDKeyboardModifierMappingSrc":0x700000064,
            "HIDKeyboardModifierMappingDst":0x700000035
        }
    ]
}
END
)

# Keychron Q1 Max
hidutil property --matching "{\"VendorID\":0x3434}" property --matching "{\"ProductID\":0x0810}" property --set "$key_map_apple"

# Builtin keyboard
hidutil property --matching "{\"VendorID\":0x05ac}" property --matching "{\"ProductID\":0x0342}" property --set "$key_map_apple"
