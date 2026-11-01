# Wagon ambush slice

2026-11-01: S28 implemented as F3 → Wagon ambush / new combat. Three original kits (Moss, Ember, Lumen), two enemies, individual HP/DEF/shields, independent attack clocks, Focus +10/s, repeated active/passive interactions. Two lanes, front/rear positions; front lane 1 intercepts the raider. A faster exposed Ember formation trades wagon integrity for time. No types needed or introduced.

The sample is separate from expedition state and saves to wagon_ambush_v1 plus backup in the active namespace. No travel Energy, food, cargo, condition, history or real-wagon costs. Existing manual/automatic battle completion paths unchanged. S29 six-kit/equipment depth and S30 integration remain pending.

Fixed 100ms ticks; saved seeded starting offsets, clocks, targets, effect source/expiry, Focus and partial tick. Abilities precede basic attacks in saved unit order; KO cancels actions; one follow-up per source/tick, no recursive reactions. Wagon failure precedes victory on simultaneous outcomes; retreat and 180s stalemate end safely. Stun pauses attack/Focus; slow halves attack-clock progress. HP does not regenerate in this sample; shield never repairs the wagon.

Validation: 122 Lua checks, native checkpoint/backup tests and original 36 GUI states plus new sample input flow. Production controller verifies focus loss, menus and close. Five actual 1280×720 captures in reviews/evidence/wagon-ambush; source hashes identify the pre-commit feature inputs. 24 matched seeds per preset: guard always wins at15s with100 wagon; rush wins at13.8–14.4s with18–34 wagon. This is one sample, not whole-game balance or proof of enjoyment.

See docs/WAGON_AMBUSH_PLAYTEST.md. No Computer Use or new firewall prompt. Physical keyboard, listening/human pacing and existing native activation fault remain separate known gaps. Fresh Windows packaging follows merge; builds/Trailomon-windows.json is authoritative for the exact build revision. Post-merge provenance is recorded locally and can be folded into the next substantive PR.
