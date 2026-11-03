# Settings window and overlay (Racing 26)

Beta 1.35 redraws the window and the overlay from the final mockup *ACAdvancedIA — Refonte UI* (artifact version 1793649588-c9be). This page records how the mockup maps to the code.

## Files

- `src/widgets.lua`: the Racing 26 kit (colour tokens, fonts per role, cut-corner panels, parallelogram buttons, switches, chips, segments, tiles, list and sidebar rows, sliders with the default mark, inputs, messages, scroll rails, tooltips).
- `src/groups.lua`: the sub-groups of every section and of the three racing-rules views, in the mockup order. A key missing from the schema is skipped; a setting no sub-group lists is shown under *Other settings*, so no setting can disappear.
- `src/ui.lua`: header, HOME, SETTINGS, RACING RULES, DIAGNOSTICS and the overlay.
- `src/applier.lua`: `fontDir` (the `fonts/` folder when complete) and `appFile` (the header icon).
- `fonts/`: Barlow Regular and SemiBold, Barlow Condensed SemiBold, Bold and ExtraBold Italic, JetBrains Mono Medium, with their OFL licences.

## Fonts per role

| Role | Font file | DWrite name | Used for |
|---|---|---|---|
| body | Barlow Regular | `Barlow:fonts/barlow;Weight=Regular` | text, descriptions |
| sb | Barlow SemiBold | `Weight=SemiBold` | names, sidebar entries |
| label | Barlow Condensed SemiBold | `Weight=SemiBold` | small capitals labels |
| cond | Barlow Condensed Bold | `Weight=Bold` | headings, chips, segments, links |
| display | Barlow Condensed ExtraBold Italic | `Weight=UltraBold;Style=Italic` | titles, buttons, tabs, overlay titles |
| mono | JetBrains Mono Medium | `Weight=Medium` | values, tables, logs, delta |

DWrite weight names are CSP's (`ui.DWriteFont.Weight`): Regular is 400 and UltraBold is 800, the weight of the ExtraBold file. Fallbacks: Segoe UI (weights and italic) and Consolas. The fonts are looked up once, by the window or by the overlay, whichever draws first.

## Drawing cost

- One font is pushed per change of role, not per text; every font and clip is closed at the end of the frame, also when a drawing error interrupts it.
- Measured widths, cut texts and wrapped lines are cached per role, size and width (cleared beyond 6,000 entries and on a scale change); control identifiers, value texts and preset signatures are built once per change; the language switch clears them.
- The overlay reuses its points and text boxes: no table or point is created per frame.
- Standing-start box: the slot and the distance given by the grid (to the metre below 20 m, rounded to 10 m beyond), replaced by **IN POSITION** when you are stopped in your slot and **SLOT PASSED** beyond it (with the distance behind, up to 500 m, since Beta 1.36); with no slot, the panel says *Start from the pit lane*.

## Differences from the mockup (CSP limits and safety)

- **Tooltips** are CSP's native ones (kit colours when CSP exposes the style colours), not the drawn `.tip` box: a drawn box would be clipped by the window edge.
- **Text inputs** are native ImGui inputs on a drawn frame (their own font, no DWrite).
- **An unticked section** shows its warning instead of its dimmed settings, as before: its settings do not apply, and the controls stay out of reach. Since the review, **Global options** follow the same rule.
- **Profile selector**: in a window too narrow for the names next to the tabs, the profiles show as their first letter; the selector is never hidden.
- **State chip**: states the mockup did not have, **PAUSED · <profile>** (neutral), **NO AI · <profile>** (neutral, no AI in the session, since Beta 1.36) and **SUSPENDED** (amber: replay, finished session, no AI line, abnormal frames, refused access).
- **Updates**: the block adds three states to the mockup's, *ready* (copy when stopped), *GitHub request limit* and *recovery impossible* (with the marker file).
- **Minimum size**: the manifest keeps 640 × 520 (small screens); below 900 px the window scales down instead of cropping.
- **Pattern editor**: the eight rows open with **Edit row by row**; closed, the free-text field stays (as before).
- **Native AC yellow on the HUD** is greyed out only on an equipped track (detected panels) with the **Track light panels** section ticked for the profile shown; elsewhere it still works and stays settable.
- **Track light panels** (Beta 1.37, mockup version 1793693617-17ad): the section follows the app's rule for an unticked section (its warning instead of dimmed settings); its circuit status and **Active for** chips stay visible so it can be ticked again. Two defaults differ from the mockup's example on purpose: red is on (as in Beta 1.36) and the section is ticked for every profile, Hotlap included. The colour rows draw a 14 px swatch with the kit's flag colours; the yellow row is a switch drawn on and greyed. The English link line says *Race & safety*, the sidebar's real name (the mockup's English texts say *Racing & safety*).
- **Download progress** is not shown (CSP gives none), as agreed in the mockup.
