#!/usr/bin/env python3

import sys
import os
import re
import json
import argparse

# Standard color name to ANSI index mapping
ANSI_MAP = {
    "black": 0,
    "red": 1,
    "green": 2,
    "yellow": 3,
    "blue": 4,
    "purple": 5,
    "cyan": 6,
    "white": 7,
    "brightBlack": 8,
    "brightRed": 9,
    "brightGreen": 10,
    "brightYellow": 11,
    "brightBlue": 12,
    "brightPurple": 13,
    "brightCyan": 14,
    "brightWhite": 15,
}

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


def convert_to_fbterm(colours_json):
    """Convert standard colour JSON to fbterm config format"""
    lines = []

    if "foreground" in colours_json:
        lines.append(f"color-foreground={colours_json['foreground'].lstrip('#')}")
    if "background" in colours_json:
        lines.append(f"color-background={colours_json['background'].lstrip('#')}")

    for colour_name, index in ANSI_MAP.items():
        if colour_name in colours_json:
            hex_val = colours_json[colour_name].lstrip('#')
            lines.append(f"color-{index}={hex_val}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Convert terminal colour profiles between formats")
    parser.add_argument("input", help="Path to input colour profile (iTerm2 JSON or standard JSON)")
    parser.add_argument("name", nargs="?", default=None, help="Profile name (required for iTerm2 input)")
    parser.add_argument("-f", "--format", choices=["winterm", "fbterm"], default="winterm",
                        help="Output format: winterm (default) or fbterm")
    parser.add_argument("--from", dest="input_format", choices=["iterm", "standard"], default="iterm",
                        help="Input format: iterm (default) or standard JSON")

    args = parser.parse_args()

    try:
        with open(args.input, "r") as file:
            input_json = json.load(file)
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        sys.exit(1)

    try:
        if args.input_format == "iterm":
            if not args.name:
                print("Profile name required for iTerm2 input", file=sys.stderr)
                sys.exit(1)
            colours = parse_iterm_colours(input_json)
            colours["name"] = args.name
        else:
            colours = input_json

        if args.format == "fbterm":
            print(convert_to_fbterm(colours))
        else:
            print(json.dumps(colours, indent=2))

    except Exception as e:
        print(f"Error processing file: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
