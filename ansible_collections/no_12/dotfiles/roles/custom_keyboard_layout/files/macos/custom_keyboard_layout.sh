#!/usr/bin/env bash

# map "caps lock" (0x700000039) to "F12" (0x700000045)
# switch "left option" (0x7000000E2) and "left command" (0x7000000E3)
# switch "right option" (0x7000000E6) and "right command" (0x7000000E7)
# switch "`/~" (0x700000035) and "§/±" (0x700000064)

key_map_pc=$(cat <<-END
{
    "UserKeyMapping":[
        {
            "HIDKeyboardModifierMappingSrc":0x700000039,
            "HIDKeyboardModifierMappingDst":0x700000045
        }
    ]
}
END
)

key_map_apple=$(cat <<-END
{
    "UserKeyMapping":[
        {
            "HIDKeyboardModifierMappingSrc":0x700000039,
            "HIDKeyboardModifierMappingDst":0x700000045
        },
        {
            "HIDKeyboardModifierMappingSrc":0x7000000E2,
            "HIDKeyboardModifierMappingDst":0x7000000E3
        },
        {
            "HIDKeyboardModifierMappingSrc":0x7000000E3,
            "HIDKeyboardModifierMappingDst":0x7000000E2
        },
        {
            "HIDKeyboardModifierMappingSrc":0x7000000E6,
            "HIDKeyboardModifierMappingDst":0x7000000E7
        },
        {
            "HIDKeyboardModifierMappingSrc":0x7000000E7,
            "HIDKeyboardModifierMappingDst":0x7000000E6
        },
        {
            "HIDKeyboardModifierMappingSrc":0x700000035,
            "HIDKeyboardModifierMappingDst":0x700000064
        },
        {
            "HIDKeyboardModifierMappingSrc":0x700000064,
            "HIDKeyboardModifierMappingDst":0x700000035
        }
    ]
}
END
)

# DasKeyboard
hidutil property --matching "{\"ProductID\":0x0142}" property --set "$key_map_pc"

# Builtin keyboard
hidutil property --matching "{\"ProductID\":0x0340}" property --set "$key_map_apple"

# Magic keyboard
hidutil property --matching "{\"ProductID\":0x026c}" property --set "$key_map_apple"
