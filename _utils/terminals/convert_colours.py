#!/usr/bin/env python3

import sys
import os
import re
import json

def convert_iterm2_to_winterm(iterm_colour):
    """Maps iTerm2 colour names to Windows Terminal names"""
    colour_map = {
        "Ansi 0 Color": "black",
        "Ansi 1 Color": "red",
        "Ansi 2 Color": "green",
        "Ansi 3 Color": "yellow",
        "Ansi 4 Color": "blue",
        "Ansi 5 Color": "purple",
        "Ansi 6 Color": "cyan",
        "Ansi 7 Color": "white",
        "Ansi 8 Color": "brightBlack",
        "Ansi 9 Color": "brightRed",
        "Ansi 10 Color": "brightGreen",
        "Ansi 11 Color": "brightYellow",
        "Ansi 12 Color": "brightBlue",
        "Ansi 13 Color": "brightPurple",
        "Ansi 14 Color": "brightCyan",
        "Ansi 15 Color": "brightWhite",
        "Cursor Color": "cursorColor",
        "Selection Color": "selectionBackground",
        "Background Color": "background",
        "Foreground Color": "foreground",
    }
    return colour_map.get(iterm_colour, "")


def convert_real_to_hex(red, green, blue):
    """Converts RGB float values to hex code"""
    r = round(float(red) * 255)
    g = round(float(green) * 255)
    b = round(float(blue) * 255)
    return f"#{r:02X}{g:02X}{b:02X}"


def parse_iterm_colours(iterm_json):
    """Parse an iTerm2 profile for colours"""
    winterm_json = {}
    for key, value in iterm_json.items():
        colour_name = convert_iterm2_to_winterm(key)
        if colour_name:
            red = value["Red Component"]
            green = value["Green Component"]
            blue = value["Blue Component"]
            winterm_json[colour_name] = convert_real_to_hex(red, green, blue)

    return winterm_json

def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <Path to iterm profile json file > <Profile name>", file=sys.stderr)
        sys.exit(1)

    input_path = sys.argv[1]
    try:
        with open(input_path, "r") as file:
            iterm_json = json.load(file)
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        sys.exit(1)

    winterm_json = {
        "name": sys.argv[2]
    }
    try:
        winterm_colors = parse_iterm_colours(iterm_json)
        winterm_json.update(winterm_colors)
        print(json.dumps(winterm_json, indent=2))

    except Exception as e:
        print(f"Error processing file: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
