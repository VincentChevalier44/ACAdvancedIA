# Settings window and overlay (Racing 26)

Beta 1.35 redraws the window and the overlay from the final mockup *ACAdvancedIA — Refonte UI* (artifact version 1793649588-c9be). This page records how the mockup maps to the code. Beta 1.38 brings the details to the final mockup (version 1793693617-17ad) after a fidelity review of Beta 1.37, and Beta 1.39 closes the gaps a review of Beta 1.38 still found.

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
- The overlay reuses its points and text boxes: no table or point is created per frame; pill texts are put in capitals once per text.
- **No disk read in one frame** (Beta 1.39): the Safety Car car base is read in steps (24 files and 4 ms at most per frame, at least one), once per session. A window or overlay frame longer than 50 ms (500 ms for the first frame of each, while its fonts load) is logged once per place (`WARN interface lente: …`).
- Standing-start box: the slot and the distance given by the grid (to the metre below 20 m, rounded to 10 m beyond), replaced by **IN POSITION** when you are stopped in your slot and **SLOT PASSED** beyond it (with the distance behind, up to 500 m, since Beta 1.36); with no slot, the panel says *Start from the pit lane*.

## Differences from the mockup (CSP limits and safety)

- **Tooltips** are CSP's native ones (kit colours when CSP exposes the style colours), not the drawn `.tip` box: a drawn box would be clipped by the window edge.
- **Text inputs** are native ImGui inputs on a drawn frame (their own font, no DWrite).
- **An unticked section** (since Beta 1.38, as in the mockup) shows its warning at the top of the pane and its settings dimmed underneath (a veil of the panel colour at 58 %, the mockup's 42 % opacity). They stay adjustable and apply once the section is ticked. Beta 1.37 showed the warning alone. Since Beta 1.39 the veil covers the settings list only (and, for the track light panels, the circuit status): the **Personalities** block of Global options, the legend, the class patterns and the Safety Car base stay clear. **Racing rules** keep their dimmed settings when unticked (the mockup never shows them unticked; a choice left to the driver).
- **Profile selector**: in a window too narrow for the names next to the tabs, the profiles show as their first letter; the selector is never hidden.
- **State chip**: states the mockup did not have, **PAUSED · <profile>** (neutral), **NO AI · <profile>** (neutral, no AI in the session, since Beta 1.36) and **SUSPENDED** (amber: replay, finished session, no AI line, abnormal frames, refused access).
- **Updates**: the block adds three states to the mockup's, *ready* (copy when stopped), *GitHub request limit* and *recovery impossible* (with the marker file).
- **Minimum size**: the manifest keeps 640 × 520 (small screens); below 900 px the window scales down instead of cropping.
- **Pattern editor**: the rows are open by default, as on the board (since Beta 1.39); **Edit row by row** closes them to the free-text field. Open, they show the rows in use (at least one) plus those added with **+ Add a row**, up to eight, under the **Class number** column.
- **Native AC yellow on the HUD** is greyed out only on an equipped track (detected panels) with the **Track light panels** section ticked for the profile shown; elsewhere it still works and stays settable.
- **Track light panels** (Beta 1.37, mockup version 1793693617-17ad): the section follows the app's rule for an unticked section (since Beta 1.38: its warning above its dimmed settings); its circuit status and **Active for** chips stay visible so it can be ticked again, and since Beta 1.38 its title row carries the section switch. Two defaults differ from the mockup's example on purpose: red is on (as in Beta 1.36) and the section is ticked for every profile, Hotlap included. The colour rows draw a 14 px swatch with the kit's flag colours; the yellow row is a switch drawn on and greyed. The English link line says *Race & safety*, the sidebar's real name (the mockup's English texts say *Racing & safety*).
- **Download progress** is not shown (CSP gives none), as agreed in the mockup.
- **CSP display options** (Beta 1.40, user request, not on the boards yet): two switches at the end of *Assetto Corsa displays* in the Overlay section, **Hide system messages (CSP)** and **Hide AC flags (CSP)**, then a status line in the message style of the kit (grey dot: waiting, amber: next launch, cannot be changed or messages lost, green: applied).
- **Safety Car base, while it is read** (Beta 1.39): *Reading the car base… n / N* replaces the rows for a moment the first time the view opens (a few seconds with hundreds of cars on a slow disk); the mockup has no such state.
- **Diagnostics** (Beta 1.39): the last flash event and the braking-zone note, which the board does not show, are in tooltips (the flash field, the capability notes); the track light panels line is gone (HOME tile, own section).

## Beta 1.38 fidelity pass: what still differs on purpose

- **Long texts cut with an ellipsis**, as the mockup does: the rule-set lines (*… · relance RS*) in the 252 px column, the header guard line in a narrow window, a capability name in a narrow Diagnostics column. The tooltips keep the full text.
- **Default texts** (*default: …*) are lower-cased like the mockup's; a label starting with an accented capital (*À la ligne…*) keeps it, since Lua only lower-cases ASCII.
- **Safety Car base**: eight rows at most, then *N more cars: refine the filter* (the mockup shows three examples; drawing hundreds of rows every frame would cost too much).
- **Overlay layout**: the version text is gone from the top right, but the title still stops where it was (the tested layout, which never overlaps, is kept).
- **Overlay instructions kept**, because they carry live values or a state the mockup's examples do not show: the double yellow (*Double yellow in 300 m*), the local yellow zone and AC's own yellow, the red-flag variants (pit lane, sessions), the Safety Car called and coming in, the standing-start slot with its distance, the relaunch laps, the penalty variants, the lap line and the race summary. The rolling and standing restart explanations keep the procedure in full (two lines).
- **Scroll bars** are dragged by their 6 px rail (only when the content overflows); clicking the rail does not jump.
- **Built-in presets** aimed at another profile keep the profile shown (the driver's choice for Beta 1.38); custom presets still show the profile they were saved for. Since Beta 1.39 the HOME line then stays *No active preset*, as on the MainApplique board; it shows the preset again on the profile it was applied to.
- **English texts** follow MainEN and TextesEN, except on purpose: the circuit status lines keep the Settings board's wording (TextesEN predates it); the colour legend uses ' · ' in both languages, like the French board; the link line says *Race & safety*, the sidebar's real name; the applied message is *Preset applied to the Race profile* (MainEN without *the automatic profile stays on*, which is only true with the automatic profile); the warning's offence count is in its pill (*OFFENCES: 1 / 5*), not in the instruction.

## Beta 1.42: new settings sections not yet in the mockup

- Two sidebar entries in « RACE & SAFETY », after Accidents: **AI strategy** (9 settings) and **AI sanctions** (17 settings), drawn with the same settings lists, subgroups and hidden-setting notes as the other sections.
- New subgroups: **Slipstream and dirty air** and **End of race** in Overtaking; **Out-lap** and **Wear and lock-ups** in Weather.
- Diagnostic: an « AI RACE » block (strategy, failures, sanctions, corrected classification), shown only when it has rows.
- Race recap: the line « Corrected classification: P<n> » when the app's classification changes your place.
- The sidebar rows shrink from 28 to 24 px only if the list is taller than the window (at 700 px everything fits).

