"""Validate the shipped media, independently of the editor or encoder."""
import hashlib
import json
from pathlib import Path
import struct
import unittest
ROOT=Path(__file__).resolve().parents[1]
MEDIA=ROOT/"reviews/evidence/trailer"
def atoms(data):
    offset=0
    while offset<len(data):
        size,kind=struct.unpack_from(">I4s",data,offset)
        header=8
        if size==1:
            size=struct.unpack_from(">Q",data,offset+8)[0];header=16
        if size==0:size=len(data)-offset
        if size<header or offset+size>len(data):raise ValueError("Invalid MP4 atom")
        yield kind,data[offset+header:offset+size]
        offset+=size
class TrailerArtifactTests(unittest.TestCase):
    def test_exact_twenty_second_fast_start_video(self):
        data=(MEDIA/"Trailomon-20s.mp4").read_bytes()
        top=list(atoms(data));kinds=[k for k,_ in top]
        self.assertLess(kinds.index(b"moov"),kinds.index(b"mdat"))
        moov=dict(atoms(dict(top)[b"moov"]))
        header=moov[b"mvhd"];self.assertEqual(header[0],0)
        scale,duration=struct.unpack_from(">II",header,12)
        self.assertEqual(duration/scale,20)
        for kind,track in atoms(dict(top)[b"moov"]):
            if kind!=b"trak":continue
            track=dict(atoms(track));mdia=dict(atoms(track[b"mdia"]))
            if mdia[b"hdlr"][8:12]!=b"vide":continue
            width,height=struct.unpack(">II",track[b"tkhd"][-8:])
            self.assertEqual((width>>16,height>>16),(1280,720))
            stbl=dict(atoms(dict(atoms(mdia[b"minf"]))[b"stbl"]))
            self.assertEqual(struct.unpack_from(">I",stbl[b"stsz"],8)[0],600)
            break
        else:self.fail("No video track")
    def test_provenance_matches_video_and_capture_script(self):
        manifest=json.loads((MEDIA/"manifest.json").read_text())
        verification=json.loads((MEDIA/"verification.json").read_text())
        sha=hashlib.sha256((MEDIA/"Trailomon-20s.mp4").read_bytes()).hexdigest()
        self.assertEqual(sha,manifest["video_sha256"])
        self.assertEqual(sha,verification["video_sha256"])
        self.assertEqual(manifest["capture_script_sha256"],hashlib.sha256((ROOT/"tools/trailer_capture.gui_script").read_bytes()).hexdigest())
        self.assertLess(verification["audio_peak_dbfs"],0)
    def test_phone_delivery_retains_controls_and_prototype_context(self):
        page=(ROOT/"reviews/trailer.html").read_text(encoding="utf-8")
        for text in ["controls playsinline", "Trailomon-20s.mp4", "Download MP4", "prototype footage", "practice", "Text version"]:
            self.assertIn(text.lower(),page.lower())
