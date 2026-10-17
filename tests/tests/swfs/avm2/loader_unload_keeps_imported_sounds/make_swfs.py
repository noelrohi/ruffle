import struct
import sys


def tag(code, body=b""):
    if len(body) < 0x3F:
        return struct.pack("<H", code << 6 | len(body)) + body
    return struct.pack("<HI", code << 6 | 0x3F, len(body)) + body


def swf(tags):
    file_attributes = tag(69, struct.pack("<I", 0x08))
    body = b"\x00" + struct.pack("<HH", 24 << 8, 1) + file_attributes + b"".join(tags) + tag(1) + tag(0)
    return b"FWS" + bytes([10]) + struct.pack("<I", 8 + len(body)) + body


def string(text):
    return text.encode() + b"\x00"


SAMPLES = 550
# Uncompressed little-endian PCM, 5.5 kHz, 16-bit, mono: a tenth of a second of silence.
define_sound = struct.pack("<HBI", 1, 0x32, SAMPLES) + bytes(2 * SAMPLES)
export = struct.pack("<HH", 1, 1) + string("beep")
import_ = string("asset.swf") + bytes([1, 0]) + struct.pack("<HH", 1, 1) + string("beep")

out = sys.argv[1]
open(f"{out}/asset.swf", "wb").write(swf([tag(14, define_sound), tag(56, export)]))
open(f"{out}/importer.swf", "wb").write(swf([tag(71, import_)]))
