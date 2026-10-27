# PlantQuest (Flutter remake) — Plan

> **Status: APPROVED (Oct 15, 2026).** This is the source of truth for the remake.
> Q1–Q4 answered and D1–D8 accepted (section 14). Change it here first, then in code.

---

## 1. What PlantQuest is

A fully offline, game-like Android app that teaches elementary students about 15 plants
commonly found in the Philippines.

- **Who:** Grades 3–6. Grades 1–2 can use the easiest level.
- **One student per phone.** No login, no backend, no internet, no ads, no real-money purchases (the Shop uses leaves only),
  no timers, no pop-ups.
- **Session length:** about 5 minutes (one plant + its quiz).
- **Platform:** Android first. Code stays iOS-ready (no Android-only APIs without a guard).
- **App id:** `com.plantquest.plantquest` · **Version:** 2.0.0
- **Credits (loading screen):** Developed by Elyssa Jean Vicencio and Ma. Cristine Joy Cristobal.

## 2. Kid-friendly rules (apply everywhere)

| Rule | How we enforce it |
|---|---|
| Tap targets ≥ 56 dp | `AppSizes.minTap = 56`; every button/card/chip uses it as min size |
| Short Grade 3 sentences | All copy lives in `lib/content/strings.dart`; ≤ 12 words per sentence target |
| No emojis in UI text | Icons are drawn or from an icon set, never emoji characters |
| Gentle "try again" | Wrong answers use coral + "Good try!", never red, never "WRONG" |
| No timers, no pop-ups | No countdowns; confirmations are in-app sheets, not system dialogs |
| ~5 minute sessions | Plant quiz = 3 questions; Sprout = 5; Sapling = 10 |

## 3. Binhi the mascot

A sprout in a coral pot. Stage depends on the **total leaves** (summed from `leaves_log`).

| Stage | Leaves | Look |
|---|---|---|
| Seed | 0–9 | Pot with a seed bump and one tiny shoot |
| Sprout | 10–24 | Two leaves |
| Sapling | 25–49 | Taller stem, 4–6 leaves |
| Blooming | 50+ | Full plant with a pink flower |

**Moods:** happy (rest), cheering (correct / celebration), encouraging (wrong answer,
start over sheet), worried (Start over confirmation).

**Behaviour:** breathes and blinks at rest; squash-and-stretch hop when tapped (says a
short line, read aloud); cheers on correct answers; gentle encouraging look on wrong ones;
a full-screen celebration when reaching a new stage.

## 4. Screens and flow

Layout follows the screenshots in `docs/screens/`. **Match where things sit, not the look.**

```
Loading ──► (first launch) Welcome ► Get Started ► About you ──► Home
        └─► (returning)                                       ──► Home

Bottom tabs: Home | Plants | Quiz | Shop | Profile
Home path stop ──► Plant details ──► Plant quiz ──► Results ──► Next plant / Done
Quiz tab ──► Sprout quiz / Sapling quiz / any unlocked plant quiz ──► Results
Profile ──► Edit profile
Profile gear ──► Settings ──► Start over sheet
```

| # | Screen | Screenshot | Layout notes |
|---|---|---|---|
| 1 | Loading | `01-loading.jpg` | Top half: sky scene with Binhi. Bottom: logo sprout, "PlantQuest", "Learn. Discover. Grow.", progress bar with "Almost ready!" + %, "DEVELOPED BY" credits, "Works offline · Version 2.0.0". Now the "Sunrise" design (D18). |
| 2 | Welcome (first launch) | `02-welcome.jpg` | Top scene: gumamela, Binhi, kalamansi on hills. Logo + "Explore the amazing world of plants!" with speaker button. Big GET STARTED at bottom. |
| 3 | Get Started | `03-get-started.jpg` | Back button. "Learn. Discover. Grow." + speaker. Three cards: Learn (book, teal), Discover (puzzle, grape), Grow (sprout, green). Binhi above GET STARTED. |
| 4 | About you | `04-about-you.jpg` | Back + Skip. Binhi with speech bubble "Hi! I am Binhi. What should I call you?" + speaker. Name field (max 20 chars), grade grid 1–6 (2 rows of 3), avatar carousel (6 boys + 6 girls). LET'S GO! disabled until name + grade. Skip → name "Explorer". |
| 5 | Home | `05-home.jpg` | Header: avatar + "Hi, {name}!", days pill (sun) + leaves pill, sound toggle. Binhi card: "{n} more leaves to grow!", stage text, growth bar, speaker. "Plant Adventure · x of 15 done". World banner card, then winding path of stops (done / current with START tag / locked). |
| 6 | Plants | `06-plants.jpg` | Title + "x of 15 explored". Grouped by world header (number badge + name + subtitle). Unlocked: colorful card with plant art, name, short line, chevron. Locked: mystery silhouette, "???", "Finish the plant before it to unlock". |
| 7 | Plant details | `07-plant-details.jpg` | Back, name, scientific name, speaker. Description. Big tappable illustration ("Tap the parts! x/4 found"). Part chips (Root / Stem / Leaf / Flower-or-Fruit). Part explanation card + speaker. Fun fact card + speaker. START QUIZ button at the bottom. |
| 8 | Quiz question | `08-quiz-question.jpg` | Close (X), progress bar, leaves earned, sound. "Question 1 of 3". Binhi + speech bubble with the question + speaker. Answer cards (2×2 picture grid or list A–D). Footer: hint text + CHECK (disabled until picked). |
| 9 | Correct | `09-correct-answer.jpg` | Picked card turns green, others fade. Confetti. Footer sheet: "Correct!" + one-sentence reason + speaker + CONTINUE. |
| 10 | Try again | `10-try-again.jpg` | Picked card coral, right answer green. Binhi encouraging. Footer sheet: "Good try!" + "Answer: …" + reason + speaker + CONTINUE (coral). |
| 11 | Results | `11-results.jpg` | Binhi cheering. "Great job, {name}!" + unlock line. Score card + Leaves card (+n). Growth bar. NEXT PLANT: {name} (primary), PLAY AGAIN + DONE. |
| 12 | Quiz tab | `12-quiz-tab.jpg` | Title + best score badge (trophy). Sprout Quiz card (YOUR LEVEL for grades 1–4) and Sapling Quiz card (CHALLENGE / YOUR LEVEL for 5–6). "Plant quizzes" grid of 15; locked ones faded with "???". |
| 13 | Profile | `13-profile.jpg` | Title + gear. Card: avatar (edit badge), name, grade, joined (month year), EDIT PROFILE. Binhi stage card. Stat tiles: leaves, days exploring, plants explored, best score. Garden of explored plants. **Added:** the Binhi card opens the Wardrobe; a Sticker book card below it. |
| 14 | Settings | `14-settings.jpg` | Back + title. Sound section (sounds on/off). Reading (read questions to me, talking speed Slow / Normal). Binhi's voice (Automatic + phone voices, ▶ preview each; voice style cheerful / normal / calm). Motion (less motion). Progress (Start over). |
| 15 | Start over | `15-start-over.jpg` | In-app sheet: worried Binhi, "Start over?", explanation, big KEEP MY PROGRESS (primary), smaller "Start over" (coral). Clears leaves, garden and quiz scores; keeps name and settings. |
| 16 | Edit profile | `16-edit-profile.jpg` | Back + title. Big avatar preview, name field, grade grid, avatars grouped Boys / Girls with check on selected. SAVE pinned at bottom. |

**Android back button:** on Home it opens an in-app "Leave PlantQuest?" sheet
(STAY primary, Leave secondary). Elsewhere it goes back normally; in a quiz it asks
"Stop this quiz?" so progress isn't lost by accident.

## 5. Game rules

### Leaves (every award is a row in `leaves_log`; totals are always sums — see §5b for spending)

| Event | Leaves | When it can happen |
|---|---|---|
| Explore a plant for the first time | +5 | Once per plant (opening Plant details) |
| Tap every part of a plant | +3 | Once per plant |
| Correct answer | +2 | Per correct answer **above your best score** for that quiz |
| Perfect quiz | +5 | The first time a quiz is perfect |
| Win Label it or Grow it | +3 | Once per plant per game (§6b) |
| Match a plant in Match it | +1 | The first time each plant is matched (§6b) |

**Replays earn leaves only for new bests.** Each quiz (each plant quiz, Sprout, Sapling)
keeps a best score. A play earns `2 × (score − previous best)` when it beats the best,
plus +5 the first time it is perfect. The first play counts as beating a best of 0.
Example: first try 2/3 → +4. Replay 2/3 → +0 ("Same as your best! Try for 3/3"). Replay
3/3 → +2 +5 = +7. This stops leaf farming but still rewards trying again.

### Unlocking

- The path is 15 stops in order: World 1 (1–5) → World 2 (6–10) → World 3 (11–15).
- Stop 1 (Sampaguita) is open at the start.
- **Finishing a plant's quiz always unlocks the next stop**, whatever the score. No one gets
  stuck; kids can replay to do better.
- Finishing the last plant of a world opens the next world (its banner pops open).
- Stop states: **done** (quiz finished, sunshine), **current** (next to do, START tag,
  bouncing), **locked** (shakes when tapped, Binhi says "Finish {previous} first!").
- NEXT PLANT on Results moves along the path, crossing into the next world.

### Days visited

Counts distinct local calendar days the app was opened (`visits` table, one row per day).
Never resets, not even on Start over.

### 5b. Rewards (Oct 22, 2026 — sticker book + leaf shop)

**Two leaf numbers** (both sums of `leaves_log`, so nothing can drift):
- **Leaves to spend** = earned minus spent. The leaf pill everywhere shows this.
- **Leaves earned** = only the positive rows. Binhi's stage and growth bar use this, so
  **buying never shrinks Binhi**.

- **Sticker book.** Finishing a plant's quiz the first time gives its sticker (any
  score), free. After Results, the leaves and grow moments come first, then a "You got
  a sticker!" card. Profile shows a Sticker book card that opens `/profile/stickers`: 15
  stickers by world; earned ones open the plant, the rest are mystery shapes.
- **Shop tab** (`/shop`, 4th tab — see D12). Things for Binhi, bought with leaves to
  spend. BUY → a "Buy the …?" card (BUY / Not now, so a small finger can't buy by
  accident) → "Salamat!" card; the item goes on right away. Owned items: tap to wear
  or take off. Not enough leaves: dimmed, "N more leaves" and a saving-up bar. A dot on
  the Shop tab when something becomes affordable that wasn't when the shop was last
  opened (this session). Profile's YOUR BINHI card also opens the shop. Binhi wears his
  outfit everywhere (Home, Loading, quiz, Results, grow celebration, Profile, Shop).

| Item | Price |
|---|---|
| Stripes pot | 20 |
| Dots pot | 30 |
| Sunglasses | 40 |
| Salakot hat | 50 |
| Sampaguita garland | 60 |
| Banig pot | 80 |

Prices add up to 280, about what the whole game pays (19 per plant × 15 + level
quizzes), so finishing everything can buy everything; the first item comes after one or
two plants. Replays pay only for new bests, so leaves can't be farmed. Hat, garland and
sunglasses can be worn together; one pot pattern at a time. Start over empties the shop
too.

The other ideas (gold cards, garden decorations, bonus facts, certificate) stay in the
preview page `#/rewards-preview` only.

### 5c. Badges (Oct 23, 2026)

Twelve badges for real learning milestones (`lib/game/badges.dart`). Progress is worked
out from what the child has done; when a goal is met the badge is claimed once
(`badge_wins`) and its reward paid: leaves, or an **animal friend** to use as an avatar.

| Badge | Goal | Reward |
|---|---|---|
| First Sprout | Finish your first plant | +5 leaves |
| Part Finder | Find all parts on 5 plants | +10 leaves |
| Backyard Explorer | Finish World 1 | Tarsier |
| Quiz Star | 4 of 5 (or 80 %) on a level quiz | +10 leaves |
| Sharp Eye | 5 perfect plant quizzes | Philippine eagle |
| Explorer Week | Visit on 7 days (any days, never a streak) | Pawikan |
| Sticker Collector | 10 stickers | +10 leaves |
| Farm Explorer | Finish World 2 | Carabao |
| Game Master | Win Label it and Grow it for 5 plants | +15 leaves |
| Matchmaker | Match all 15 plants | +15 leaves |
| Nature Explorer | Finish World 3 | Pilandok |
| Plant Expert | Every part found and every quiz finished, all 15 plants | Butanding |

- "You got a badge!" pops up after the other celebrations (quiz results and sticker,
  games, finding parts) and when Home opens; animal badges offer USE IT / Later.
- Profile has a Badges card (count, newest medals, animal friends) that opens
  `/profile/badges`: earned first, then the rest sorted by how close they are, each with
  a progress bar and its reward.
- Edit profile shows the six animal friends under the kids; locked ones are faded with how
  to unlock them. Animal avatar ids are `animal_<name>`.
- Start over clears badges (they follow progress).

### 5d. My Garden (Oct 23, 2026)

Profile → My Garden. Every explored plant grows in the child's own garden,
beside the family's bahay kubo (lib/features/garden, lib/art/garden,
rules in lib/game/garden.dart):

- **Homes:** flowers and ferns in clay pots (sampaguita, gumamela, pako);
  crops side by side in the garden bed (palay, mongo); water plants in the
  pond (kangkong, bakawan); trees and wild plants in the ground (the rest).
- **Moving:** hold a piece, then drag it (the garden scrolls, so a plain
  drag scrolls). Tapping a plant or decoration makes it wiggle and shows
  its name (it no longer opens the plant page, at the owner's request);
  tap Binhi and he hops. Pieces never overlap: one dropped too close slides
  just far enough to stand beside the other (owner's choice); the piece
  being carried shows on top while moving. The pond,
  the kubo and Binhi stay put. Moves are saved in `garden_spots` (DB v7).
- **Decorations** cost leaves: Stepping stones 10, Butterfly 15, Bench 20,
  Bird bath 20, Fence 25, Capiz lamp 25, Clay jar 30, Swing 35, Carabao
  statue 45 (the last five added Oct 24). The Decorate tray scrolls
  sideways; bought ones move to its end. They share the purchases table as `garden_<name>`. Pots and the
  garden bed are free and come with their plants, so a flower never waits
  behind leaves (changed from the preview, where they were for sale).
- Start over clears the garden. Spending never shrinks Binhi.

### 5e. Daily gift and caring for Binhi (Oct 24, 2026)

Two small reasons to come back each day (lib/game/daily.dart, `daily_care`
table, DB v8). Missing days never takes anything away.

- **Binhi's gift:** the first time Home opens on a new day, Binhi offers a
  gift. Gifts count through a week of seven: 3, 3, 4, 4, 5, 5 leaves, and
  gift 7 is the big surprise (15 leaves); then the week starts again. A
  missed day just waits (gift 3 comes on the next visit, not on day 3).
- **Water Binhi:** a watering can sits on Binhi's ring on Home. While he
  hasn't had water today the can wears a drop and Binhi leans a little and
  looks hopeful (never sad or hurt). Tapping it flies the can over Binhi,
  tips it and pours drops onto his leaves; he cheers: +2 leaves, once a day.
  With less motion, no flying can, just the thank-you.
- **Flower pot:** watering on any 7 days earns the Flower pot pattern for
  Binhi, put on at once and shown in the Shop's pot patterns (not for
  sale; the tile shows days watered out of 7).
- Start over clears both counts. Tests switch the gift popup off
  (`testOverrides(db, dailyGift: true)` turns it on).

### 5f. Weather in My Garden (Oct 24, 2026)

The child plays with the weather (lib/game/weather.dart). Changed the same
day from date-based seasons, at the owner's request, to make it more
interactive.

- **Opening weather:** random each time the garden opens: sunny 40%,
  cloudy 30%, rainy 30%.
- **Tap a cloud:** it rains (dark clouds, grey veil, falling rain, rings
  on the pond, puddles that stay for the visit). **Tap the sun:** it
  clears; if it was raining, a rainbow comes out. The sun always shows
  (peeking on grey days) so it can be tapped. Screen readers get the sky
  as a button ("Make it rain" / "Make it sunny").
- **Rainbow** also after watering Binhi on Home that day (it stops rain).
- **Notes:** each change shows a short plant fact at the bottom of the
  garden for 6 seconds, with a speaker button: rain ("Plants drink
  rainwater through their roots!"), sun ("Leaves use sunlight to make
  food!"), rainbow. Facts go round; Tag-ulan and Tag-init are among them.
- The header says the weather and what to tap ("Sunny day · Tap a cloud").
  Tests open the garden sunny (`testOverrides(..., weather:)`).

### 5g. A garden that moves (Oct 24, 2026)

One 8-second loop (GardenLife in lib/art/garden/garden_art.dart) brings My
Garden to life; everything stops with less motion:

- Plants sway from their base (a skew, so pots and roots stay put): small
  plants and crops more, trees slowly; each plant out of step with the next.
- Clouds drift a little, the sun's rays turn, the trees behind the hedge
  sway, and two birds glide across the sky (not in the rain).
- Two butterflies flutter around the garden, flapping and facing the way
  they fly; they hide in the rain. A bought Butterfly flaps and bobs.
- The sky layer repaints each frame; the ground (hedge, kubo, path) is
  painted once, so cheap phones stay smooth.
- **Garden gate:** the first time the garden shows each day (on Home's
  switch or from Profile), two bamboo doors slide open over it (0.9 s).
  The app's own loading screen stays Sunrise (owner's choice).

### 5h. Save my progress (Oct 26, 2026)

Settings → Progress → **Save my progress** (lib/data/backup.dart,
lib/services/backup_files.dart, package `file_picker`, chosen by the owner;
no phone permissions):

- **SAVE** writes every table, row for row, to one JSON file named like
  `PlantQuest-Jamie-2026-10-26.json`, through the phone's own "save as"
  chooser (Downloads, Google Drive, a USB stick…).
- **LOAD** picks such a file, asks first, then replaces all progress on
  this phone with it. Older backups load into newer versions (new columns
  get their defaults, new tables start empty); a file from a newer app or
  not a PlantQuest save is refused and nothing changes.

### 5i. Smart review (Oct 26, 2026)

lib/game/review.dart; no new table (it reads `quiz_answers` and
`plant_progress`):

- **Tricky questions:** any question whose latest answer was wrong comes
  back until it's answered right.
- **Plants to check on:** a finished plant not asked about for 7 days.
- **Review:** up to 5 questions (tricky first, then one per waiting plant),
  played in the normal quiz screen (`/quiz/review`, kind `review`).
  **+1 leaf per right answer**; answered questions leave the review, so it
  can't be farmed. No PLAY AGAIN; missed ones come back next time.
- Shown as a "Time to review" card at the top of the Quiz tab (or "All
  caught up!"), and Binhi mentions it on Home when something is waiting.

### 5j. Plants react to touch (Oct 26, 2026)

On a plant's details page, tapping the plant (any part) makes it react
(lib/art/plants/plant_touch.dart): it wobbles from its base, and does its
own thing where the finger landed:

- **Makahiya** folds its leaflets shut and droops, stays shut about two
  seconds, then slowly opens: what the real "shy" plant does.
- Sampaguita: scent wisps float up. Gumamela: bubbles. Bakawan: air
  bubbles. Narra: yellow flowers fall. Palay: grains drop. Mongo: seeds hop
  out. Kangkong: ripples on the water. The rest: a few leaves flutter down.
- Less motion: no wobble or effects, but Makahiya still folds.
- The part buttons under the plant (Root, Stem, Leaf, Flower…) trigger the
  same reaction at that part, not only taps on the drawing.
- In My Garden, tapping a plant (pot, bed, ground or pond) does the same
  reaction on top of the wiggle and name tag. Holding to drag doesn't.

### 5k. Garden sounds (Oct 26, 2026)

Nature sounds under the music while My Garden is on screen
(lib/services/garden_ambience.dart; files made by
tool/make_garden_sounds.py into assets/sounds/garden/, owner approved the
samples in docs/previews/garden-sounds/):

- **Rainy:** soft rain with little drops. **Sunny / rainbow:** birds now and
  then plus a light breeze. **Cloudy:** breeze. **Rainbow:** one rising
  chime when a tap stops the rain.
- Sounds fade over about 0.7 s when the weather changes; the music plays at
  70% while the garden shows.
- Follows Settings → Sounds; dips while Binhi talks; stops when the garden
  leaves the screen or the app goes to the background.

### 5l. Colouring pages (Oct 27, 2026)

Colour any explored plant by hand, then hang it in the bahay kubo (owner
approved docs/previews/colour-draw/):

- **Opening it:** "Colour it" card on each plant's page (+2 until hung), or
  tap the bahay kubo in My Garden → the wall → "Colour a plant".
- **The page** is the plant's own drawing as an outline (`Sticker.lineArt`
  turns fills white and lines to ink), on a hill or in water, with a sun and
  a cloud (lib/art/colouring/colouring_art.dart). Taped to a wooden desk.
- **Tools:** Crayon (grainy), Paint (soft, see-through; darker with each
  stroke), Fill (one tap fills a part), Eraser; Undo; 12 colours. No sizes.
- **Colour stays inside the lines**, always: every area closed in by lines
  is a part (lib/game/colouring.dart). A scribble stays in the part it
  started in; starting in a small part (a leaf, a petal) it may also cross
  other small parts, so a bush colours in one go, never the sky.
- **Saving:** the colours are kept as a PNG per plant (colourings table, DB
  v9; in backups; cleared by Start over), saved a moment after each change,
  so leaving keeps a draft.
- **HANG IT:** Binhi's "Ang ganda!" card with the framed picture, +2 leaves
  the first time per plant, then SEE IT IN MY GARDEN: the newest picture
  drops onto its nail on the bahay kubo wall with a swing and a glow. Tap
  the kubo for the wall of all pictures; tap one to colour it more.

### 5m. More shop items (Oct 27, 2026)

25 new things in the Shop (owner approved the try-on preview in
docs/previews/shop-items/; drawings checked in docs/previews/shop-items/all.png):

- **Slots, one item each:** hats (salakot, flower crown, straw hat, bandana,
  graduation cap), glasses (sunglasses, round, heart, explorer goggles), around
  the rim (sampaguita garland, bow tie, scout scarf), little friends (butterfly,
  ladybug, bee, maya bird; they move gently with Binhi), pot patterns (old four
  plus jeepney, ocean waves, picnic, pakwan, rainbow, capiz).
- **Binhi's spot:** beach, rice terraces, moonlit night, fiesta. Shown inside
  the growth ring on Home and behind Binhi in the Shop.
- **Colouring packs:** pastel, fiesta, earth, gold & silver; six colours each,
  added to the colouring palette (which slides sideways once it has more than 12).
- Prices 25 to 100. The first six items still cost 280 (about what the game
  pays); the new ones are extras to save up for.
- Saved in new profile columns (DB v10: hat, glasses, neck, friend, spot); the
  old salakot/garland/sunglasses flags are kept in step, so older backups load.
- The Shop shows each group as one row that slides sideways.

## 6. Quiz

- **Plant quiz:** 3 questions about that plant (matches the original).
- **Sprout quiz:** Grades 1–4, 5 questions, random from a bank of ≥ 15.
- **Sapling quiz:** Grades 5–6, 10 questions, random from a bank of ≥ 15.
- **Level quizzes only ask about unlocked plants.** Every bank question is tagged with its
  plant. While fewer than 5 plants are unlocked, the pool is all of World 1, so there are
  always enough questions. Each level bank has 3 questions per plant (45 per level), so
  even the World 1 pool has 15 — enough for a 10-question Sapling quiz with no repeats.
- Both level quizzes are available to everyone; the grade decides which says YOUR LEVEL.
- **Question types:** multiple choice (A–D list), picture choice (2×2 plant cards),
  tap the part (tap the root/stem/leaf/flower on an illustration).
- **Flow per question:** pick → CHECK → feedback sheet with a one-sentence reason →
  CONTINUE. Answers are shuffled each time.
- **Safety:** each step accepts one tap only (guard flag, no double counting on fast taps);
  saves run one at a time through a queue; if a save fails the quiz still moves on and the
  save is retried — the quiz never gets stuck.
- **Results:** score, leaves earned (flying leaves into the counter), growth bar, stage-up
  celebration if Binhi grew, NEXT PLANT / PLAY AGAIN / DONE.

### 6b. Mini-games (Oct 23, 2026)

Three games that teach by doing. Each wrong try gets a gentle "Not yet!" hint, never a
penalty, and each right step says (and reads aloud, if "Read questions to me" is on)
what it means. Leaves are paid only the first time (`game_wins`), so replays are
practice, not farming. Words are DRAFT for teacher review (`lib/content/plant_games.dart`).

- **Label it** (`/plant/:id/label`, from Plant details → "Play with …"). Drag each part
  name (Root, Stem, Leaf, and the plant's special part) onto the right box, like a
  worksheet; tapping a word then a box works too. Box positions come from each plant's
  own part zones. Right labels glow the part and read that part's sentence.
- **Grow it** (`/plant/:id/grow`). Tap four pictures in life order. Not every plant
  starts from a seed: Sampaguita (cutting), Saba (baby shoot), Niyog (coconut), Kawayan
  (bamboo shoot), Pako (spores), Bakawan (seedling pod). Stage 3 is the plant's own
  drawing, small; stage 4 the full plant.
- **Match it** (`/games/match`, Quiz tab → "Plant games"). Four plants a round from the
  unlocked ones (never fewer than World 1), unmatched plants first; match each to what it
  is known for (e.g. Malunggay → In soup, Bakawan → Guards the coast).

## 7. Content

Bundled as Dart files under `lib/content/`, every file marked
`// DRAFT — for teacher review` and each plant has `reviewed: false`.

| World | Plant | Scientific name | Theme color idea |
|---|---|---|---|
| 1 Bakuran (Backyard) | Sampaguita | *Jasminum sambac* | jasmine white + leaf green |
| | Gumamela | *Hibiscus rosa-sinensis* | hibiscus red |
| | Makahiya | *Mimosa pudica* | soft pink |
| | Kalamansi | *Citrus × microcarpa* | lime green + orange |
| | Malunggay | *Moringa oleifera* | fresh green |
| 2 Bukid (Farm) | Palay | *Oryza sativa* | golden rice |
| | Mango | *Mangifera indica* | mango yellow |
| | Saba | *Musa* 'Saba' | banana green |
| | Mongo | *Vigna radiata* | mung green |
| | Niyog | *Cocos nucifera* | coconut brown |
| 3 Kalikasan (Nature) | Narra | *Pterocarpus indicus* | golden flower yellow |
| | Kawayan | *Bambusa blumeana* | bamboo green |
| | Pako | *Diplazium esculentum* | fern green |
| | Bakawan | *Rhizophora* spp. | mangrove teal |
| | Kangkong | *Ipomoea aquatica* | water green |

**Each plant has:** id, name, scientific name, world, order, theme color, short line
(for cards), description (2 sentences), 4 parts with one-sentence explanations, one fun
fact, level, a painter (illustration), and its 3 plant-quiz questions.

**Fourth part** is "Flower" or "Fruit" depending on what kids know the plant for. Plants
without a usual flower use the closest kid-known part (decision D3).

## 8. Read-aloud (offline text-to-speech)

- `flutter_tts` with the phone's offline voices only.
- Speaker buttons on: welcome line, Binhi bubbles, descriptions, parts, fun facts,
  questions, each answer, feedback reasons.
- Binhi's speech bubbles are read aloud automatically when "Read questions to me" is on.
- The sentence being spoken is highlighted.
- Speech stops when leaving a screen (route observer).
- Talking speed: Slow / Normal. Voice: Automatic (default) or any installed offline voice,
  with ▶ preview. Voice style: cheerful (higher pitch), normal, calm (lower pitch, slower).
- If no offline voice exists: a friendly tip card explaining how to download one in the
  phone's settings (no links out of the app).

### 8b. Background music (Oct 23, 2026)

Two original loops made by `tool/make_music.py` (soft marimba like the Wooden sounds; no
licensing). Files: `assets/music/` (22 kHz mono WAV, about 5.4 MB together).

- **Bahay kubo morning** (69 s): everywhere except quizzes.
- **Quiet focus** (55 s): during quizzes and their Results.
- Switching crossfades over about a second, and each track carries on from where it paused.
- Volume stays low (35 % / 45 % of a softer track). It dips to about a third while Binhi
  reads aloud, and stops at once when the app goes to the background or the phone locks.
- **Settings → Sound → Music** switch (on by default), separate from Sounds.
- Browsers block sound until the first tap, so on the web the music starts at the first
  tap. Phones play it right away.
- Not chosen: "Garden stroll" (sample in `docs/previews/music/`).

## 9. Graphics (the main upgrade)

**Style:** bright "sticker" illustrations — soft gradients, a gentle highlight on the top
of each shape, a slightly darker outline, rounded everything, soft *colored* shadows.

**All artwork is drawn in code** with `CustomPainter` (no downloaded or AI images):

- Binhi: 4 stages × 4 moods, plus blink, breathe, hop, cheer poses.
- 15 plants, each with a distinct, recognizable silhouette, plus a "mystery" silhouette
  version and a defined hit region per part.
- 12 avatars: 6 boys, 6 girls, varied skin tones and hair (some with glasses, caps, clips).
- 3 world scenes, layered:
  - **Bakuran:** warm sky, sun, fence, rolling hills, flowers, butterflies.
  - **Bukid:** golden rice terraces, nipa hut, carabao silhouette, birds.
  - **Kalikasan:** forest, river, mangroves, fireflies/birds, teal water.
- Living scenes: slow parallax as the path scrolls, drifting clouds, swaying grass,
  small ambient life.

**Animation:** Binhi breathes/blinks, squash-and-stretch hop, cheer and encourage poses,
full-screen stage-up celebration; confetti and sparkles; leaves fly from the answer to the
leaf counter; counters tick up; path stops pop open when unlocked; chunky 3D buttons and
cards press down with a light vibration and soft tap sound; playful slide-and-scale page
transitions.

**Performance:** 60 fps target on cheap phones; `RepaintBoundary` around every animated
scene; painters cache static layers (`Picture`) and only repaint what moves; **Less motion**
setting turns off parallax/ambient life, shortens celebrations, and swaps transitions for
simple fades.

### 9b. Design rules (Oct 23, 2026 — D14)

Every new screen follows these, so the app looks like one thing:

1. **One art style: Sticker.** Plants, Binhi, avatars, path stops and icons all use a
   thick dark outline, a white die-cut edge and a soft top-to-bottom shade. No Material
   or other font icons anywhere in the app: use `KidIconView` (`lib/art/icons/kid_icon.dart`).
   New icons are drawn there from simple shapes in a 48 × 48 box.
2. **Three icon sizes only:** `AppSizes.iconSmall` (22, inside pills and ticks),
   `iconMedium` (30, buttons, tab bar, rows), `iconLarge` (44, game cards and headers).
3. **One "not active" look:** unselected tabs, locked things and disabled buttons use the
   faded icon (`muted: true`), never grey in one place and see-through in another.
4. **Icons stand alone.** Sticker icons carry their own color and white edge, so they never
   sit inside colored squares. A soft tint circle is allowed only inside counter pills.
5. **Three kinds of card** (`ChunkyCard`): white for content; a colored card for
   something to *do* (quizzes, games); a pale background card for locked things.
6. **One button family** (`ChunkyButton`) in the fixed tones (leaf, sky, sunshine, grape,
   coral, white), at least 56 tall. A one-word label shrinks to fit instead of breaking
   mid-word. Game-only pieces (drag chips, match tiles) are the one exception.
7. **One game card** (`GameCard`), full size on the Quiz tab, `compact` on the Plant page.

## 10. Color palette

All colors live in `lib/theme/app_colors.dart`. **No hard-coded colors in screens.**

| Token | Hex | Use |
|---|---|---|
| `background` | #FFF9EC | screen background (cream) |
| `card` | #FFFFFF | cards |
| `border` | #F0E6D0 | card borders, 3D button base |
| `text` | #263046 | main text (navy) |
| `textMuted` | #6E7191 | secondary text |
| `leaf` / `leafDark` / `leafLight` | #4CC35A / #2E9142 / #A6E58A | main buttons, progress, correct |
| `sky` / `skyLight` | #6EC6FF / #B8E8FF | skies, selected answer |
| `sunshine` / `sunshineDark` | #FFC93C / #F2A100 | rewards, finished stops, sun |
| `coral` / `coralLight` | #FF7F66 / #FFB38A | Binhi's pot, gentle try again |
| `grape` / `grapeInk` | #8E6CFF / #7E60E2 | quests, level badges (`grapeInk` behind small white text) |
| `bubblegum` | #FF8AC4 | blush, flowers, avatars |
| `teal` | #22C1C3 | water topics, Kalikasan accents |

**World accent themes:** Bakuran = sunshine + bubblegum · Bukid = golden rice + leaf ·
Kalikasan = deep forest green + teal.

**Contrast check (WCAG AA = 4.5:1 for normal text, 3:1 for large bold text):**

| Pair | Ratio | Result |
|---|---|---|
| navy on cream / white | 12.6 / 13.2 | ✅ AA |
| muted on cream / white | 4.51 / 4.74 | ✅ AA (just) |
| navy on leaf / coral / sky / teal / sunshine | 5.8 / 5.3 / 7.0 / 6.0 / 8.6 | ✅ AA |
| white on leafDark | 4.00 | ⚠️ large bold text only |
| white on grape | 3.66 | ⚠️ large bold text only |
| white on leaf / coral / sky / teal / bubblegum | 1.9 – 2.5 | ❌ fails |
| coral text on cream | 2.36 | ❌ fails |

The original look (white text on bright green/coral buttons) does **not** pass AA.

**Decision: bright fills, navy text.** Buttons, banners and badges keep their bright
fills and use navy `#263046` text and icons (5.3–8.6:1). White text is never used on the
bright colors. Grape is the one exception, as it's too dark for navy: grape badges use
white text that is large and bold (3.66:1 passes as large text), or the darker `grapeInk`
#7E60E2 when the text is small. Coral is a fill color only, never a text color. "Good
try!" text uses navy on a coral-light sheet. A unit test checks every text/fill pair in
the theme against these ratios.

## 11. Tech stack

| Need | Choice |
|---|---|
| Framework | Flutter stable (3.47.x) + Dart 3.13, Material 3 with a custom theme |
| Navigation | `go_router` (shell route for the 4 tabs, custom transitions) |
| State | `flutter_riverpod` |
| Database | `drift` (SQLite) with versioned migrations — updates never wipe progress |
| Read-aloud | `flutter_tts` |
| Sound effects | `audioplayers`, sounds bundled in `assets/sounds/` |
| Vibration | `HapticFeedback` (built in) |
| Animation | `flutter_animate` + `CustomPainter` |
| Font | Fredoka, bundled in `assets/fonts/` (works offline) |
| Icon / splash | `flutter_launcher_icons`, `flutter_native_splash`. Images are drawn with the game's own painters by `tool/render_brand_test.dart` into `assets/brand/`; to change them, edit that file, then run `flutter test tool/render_brand_test.dart`, `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create` |
| Browser preview | Flutter web build, **preview only** (the app ships as an Android APK). `flutter build web --no-web-resources-cdn`, served by `.claude/launch.json` → `plantquest-web` on port 8686 |
| Database in the browser preview | `web/sqlite3.wasm` (from sqlite3 3.5.2) and `web/drift_worker.js` (from drift 2.35.2), downloaded from those packages' official GitHub releases. **Re-download both whenever `sqlite3` or `drift` is upgraded**, or the preview's database stops working |

### Database tables

| Table | Columns |
|---|---|
| `profile` (one row) | id, name, grade, avatar_id, joined_at, onboarded, sound_on, auto_read, speech_rate (slow/normal), voice_id (null = Automatic), voice_style (cheerful/normal/calm), less_motion, wear_salakot, wear_garland, wear_sunglasses, pot_pattern (plain/stripes/dots/banig) — v2, music_on — v4 |
| `purchases` (v3) | item (PK, OutfitItem name), price, bought_at |
| `game_wins` (v5) | game (label/grow/match), plant_id (PK together), won_at |
| `badge_wins` (v6) | badge (PK, Achievement name), won_at |
| `daily_care` (v8) | kind (`gift` / `water`), day (`YYYY-MM-DD`); PK both |
| `garden_spots` (v7) | piece (PK, e.g. `plant_gumamela`, `bed`, `deco_bench`), x, y (feet, garden design units) |
| `leaves_log` | id, amount (negative for 'buy'), reason (explore/parts/correct/perfect/buy), plant_id?, attempt_id?, created_at |
| `plant_progress` | plant_id (PK), explored_at, parts_found (bitmask), all_parts_at, quiz_done_at, best_score |
| `quiz_attempts` | id, kind (plant/sprout/sapling), plant_id?, started_at, finished_at, score, total |
| `quiz_answers` | id, attempt_id, question_id, chosen, correct, answered_at |
| `visits` | day (YYYY-MM-DD, PK) |

Start over deletes `leaves_log`, `plant_progress`, `quiz_attempts`, `quiz_answers`,
`purchases`, `game_wins`, `badge_wins`; keeps `profile` and `visits`.

**Migrations:** the schema is versioned (`schemaVersion` in `lib/data/database.dart`,
snapshots in `drift_schemas/`). To change a table: edit `lib/data/tables.dart`, bump the
version, run `dart run drift_dev make-migrations`, add the step to `onUpgrade`, and run
the tests. A test fails if the tables change without a new schema snapshot.
Versions: v1 (first build), v2 (Binhi's outfit columns on `profile`), v3 (`purchases`), v4 (`music_on`), v5 (`game_wins`), v6 (`badge_wins`), v7 (`garden_spots`), v8 (`daily_care`).
None are released yet. The v1 → v2 test checks a saved child's progress survives the update.

### Folder layout

```
lib/
  main.dart, app.dart
  theme/        app_colors.dart, app_theme.dart, app_sizes.dart, world_themes.dart
  widgets/      chunky_button.dart, chunky_card.dart, progress_bar.dart, stat_pill.dart, speaker_button.dart …
  art/          binhi/, plants/, avatars/, scenes/, effects/ (confetti, sparkles, flying leaves)
  content/      plants.dart, worlds.dart, questions_sprout.dart, questions_sapling.dart, strings.dart
  data/         database.dart (drift), tables.dart, migrations/, repositories/
  state/        providers for profile, leaves, progress, quiz session, settings, tts
  features/     loading/, onboarding/, home/, plants/, plant_detail/, quiz/, results/, profile/, settings/
  services/     tts_service.dart, sound_service.dart, haptics.dart, save_queue.dart
assets/  fonts/, sounds/
docs/screens/  the 16 reference screenshots
```

## 12. Build order

After each step: `flutter analyze` (zero issues), `flutter test`, run on the emulator (and
the phone by APK when wanted), fix problems, then report before the next step.

**Version control:** at first no Git (owner's decision, Oct 15, 2026). On Oct 27, 2026 the
owner asked for it to go on GitHub: https://github.com/RjhnJms/PlantQuestV2 (branch `main`).
Commit and push only when the owner asks. Built APKs in `release/` are not committed.

1. Theme, colors, font; button, card, progress bar and stat pill components
2. Artwork: Binhi, avatars, world scenes, then the 15 plants
3. Database, migrations and game state
4. Onboarding, Home with the path, Plants, Plant details
5. Quiz and results, Profile, Settings
6. Read-aloud, sounds, haptics, celebrations and transitions
7. Loading screen, app icon and splash

## 13. Release (Phase 7)

- Android permissions kept to the minimum: **none** beyond what Flutter adds for release
  (INTERNET is removed from the release manifest; no microphone, storage or overlay).
  `VIBRATE` only if `HapticFeedback` needs it.
- Release signing key stored **outside** the project (e.g. `C:\Android\keys\`), referenced
  from `android/key.properties`. The key file itself never goes inside the project folder,
  and `key.properties` is never shared along with the project.
- `flutter build apk --release`, then install on the phone by copying the APK over USB
  file transfer.
- Write a README covering setup and building.
- **Done Oct 23, 2026 (D17):** owner chose to skip the release key for now (no Play Store
  yet), so 2.0.0 is signed with this PC's test key. `flutter build apk --release
  --split-per-abi`; the TECNO gets `release/PlantQuest-2.0.0-arm64.apk` (26 MB). The release
  manifest asks for no permissions. Make a real key (README) before handing the app out
  widely: moving from the test key needs an uninstall.

## 14. Open questions

### Answered (Oct 15, 2026)

- **Q1 — Button text:** bright fills with navy text (§10).
- **Q2 — Unlock rule:** any finished plant quiz unlocks the next stop (§5).
- **Q3 — Replay leaves:** only new bests earn leaves (§5).
- **Q4 — Level quizzes:** only unlocked plants, World 1 as the minimum pool (§6).

### Decisions I made (say so if you want them different)

- **D1 — Sound effects** are made by me with a small script (simple chimes, pops, taps),
  so they're original and offline. Tell me if you have sounds you'd rather use.
- **D2 — Font:** Fredoka for everything (closest to the original).
- **D3 — Fourth part for non-flowering plants:** Pako → "Spores" (under the leaf),
  Kawayan → "Shoot", Palay → "Grain", Niyog → "Fruit", Saba → "Fruit", Bakawan → "Seedling".
- **D4 — Language:** English UI with Filipino plant names, same as the original.
- **D5 — Best score** (Profile and Quiz tab badge) = best Sprout or Sapling result, shown
  as a fraction.
- **D6 — Less motion** lives in Settings under a new "Motion" section; it starts off.
- **D7 — Leaving a quiz** midway asks first; answers already saved keep their leaves.
- **D8 — Plant quiz** is 3 questions (as in the original screenshots).

### Style lab picks (Oct 15, 2026)

- **D9 — Graphics style: Current** (sticker style as built). Glossy, Storybook and Bold
  cartoon were tried in the Style lab and not chosen.
- **D10 — Animation feel: Bouncy.** Confetti burst (about 45 pieces), 5 leaves fly to the
  counter, Binhi hops twice on a right answer, answer cards pop to 108 %. The "less
  motion" setting still calms all of it.
- **D11 — Sound pack: Wooden** (soft marimba): tap, correct, try again, leaf, level up.
  Generated by a script, stored in `assets/sounds/wooden/`.

### Rewards picks (Oct 22, 2026)

- **D12 — Shop is a 5th bottom tab** (Home | Plants | Quiz | Shop | Profile), a change
  from the original 4-tab layout, chosen by the owner. Leaves became the in-game
  currency; Binhi grows from leaves earned so spending never shrinks him (§5b).

### Layout pass (Oct 23, 2026)

- **D13 — Cleaner screens** (owner picked from previews in docs/previews/ui/):
  - **Home:** the adventure path fills the screen and opens at the current plant. A slim
    floating bar holds the avatar, greeting, days and leaves. Binhi sits bottom-left in a
    growth ring ("7 to grow") with a speech bubble pointing to the next plant; tap him
    to hear him. World cards became small labels on each world scene. The Home sound
    button moved to Settings only.
  - **Plant page:** one card to learn (description, plant, four part buttons, what the
    picked part does), one "Did you know?" line, and everything to do at the bottom
    (Label it, Grow it, START QUIZ).
  - **Plants:** a world's locked plants share one "N more to discover" row.
  - **Quiz:** your level is the big card; the other level is a slim challenge row; only
    unlocked plant quizzes show, plus one "N more unlock" line.
  - **Profile:** compact header row; Binhi (opens the Shop) and Sticker book side by
    side; only Days exploring and Best score as stats; My garden shows "N of 15".
- **D14 — Sticker icons + consistency pass** (owner picked Sticker from the icon previews
  in docs/previews/icons/): every Material icon replaced by drawn KidIcons; the design
  rules in §9b.
- **D15 — Avatars: Filipino outfits** (owner picked B from docs/previews/avatars/): the same
  12 kids, with sparkly eyes, a nose, an open smile, hair shine, a sun-ray background and a
  white sticker rim, dressed in barong, school uniforms (tie or ribbon), Filipiniana
  butterfly sleeves, scout neckerchiefs and jerseys (AvatarLook.outfits). Avatar ids are
  unchanged, so saved choices keep working. The six Philippine animal avatars
  (lib/art/avatars/animal_avatar.dart) are drawn but not offered yet; the plan is to
  unlock them with achievements.
- **D16 — Badges with animal rewards** (§5c), built from the preview in docs/previews/badges/.
- **D18 — Loading screen "Sunrise"** (owner picked D from docs/previews/loading/): as the
  bar fills the sun rises over the hill, blue spreads down the sky, clouds drift and birds
  fly by, and Binhi (the child's own stage and outfit) hops once when it is done. Text:
  "Good morning, explorer!" → "The sun is almost up!" → "Let's go!". Credits and version
  stay; "Works offline" was removed. Less motion: no drifting, no hop, a quick fill.
  The progress bar is a growing vine (owner picked it from 15 ideas in
  docs/previews/progress/): leaves pop out along it and a flower opens at the tip.
- **D19 — My Garden** (§5d): the owner picked the Storybook look and asked for a bahay
  kubo, flower pots for the flowers and garden beds for the plants that need them
  (docs/previews/garden/mixed.png).
- **D20 — Daily gift and watering Binhi** (§5e), built from docs/previews/engage/ without
  the star icons the owner asked to drop; the owner asked for the watering to be a real
  pouring animation.
- **D21 — Weather in My Garden** (§5f): requested by the owner (rainy days, sunny days,
  a rainbow after watering). First built on the Philippine seasons, then changed to
  option B: random opening weather that kids change by tapping clouds and the sun.
- **D22 — My Garden on Home** (owner picked B from docs/previews/home-garden/): a switch
  under Home's bar flips between **Adventure** (the path, with Binhi's corner) and **My
  Garden** (the garden, with its weather; decorations open from a DECORATE button in a
  sheet). The choice lasts while the app is open; Home starts on Adventure. Profile's
  My Garden card still opens the full garden page.
- **D23 — Adventure map as storybook pages** (owner picked C from 8 ideas in
  docs/previews/map/): each world is one page, a rounded card with the world's living scene,
  its label, and five plants on a trail winding up from the bottom. Swipe sideways (or tap
  the page dots) for the next world; Home opens on the world with the next plant. Stops
  shrink a little on short screens. Binhi's corner stays below the pages.
- **D24 — Colouring by hand** (owner asked for real tools instead of
  tap-to-fill, then for fewer controls): 4 tools, 12 colours, no size
  buttons, "stay inside the lines" always on. Pages come from the plant art
  itself, so all 15 plants match the app's style.
- **D25 — Bahay kubo: Classic with a duyan** (owner picked A + E from 6 designs in
  docs/previews/kubo/): layered nipa roof, woven sawali walls, window with a propped
  awning, bamboo ladder down to the path; under the house a hammock, a banga jar and a
  sleeping cat. The newest coloured picture hangs left of the door.
- **D26 — Quiz tab as Binhi's Quiz Show** (owner picked A, then style A5 "Puppet
  theatre", from docs/previews/quiz-tab/ and docs/previews/quiz-show/): a wooden puppet
  booth at the top (at most 40% of the screen) whose curtains open as Binhi pops up holding
  the PLAY sign for your level; a plaque shows the best level score. Below: smart review as
  a "BONUS ROUND" ticket, the other level as CHALLENGE, Match it, and the plant quizzes as
  a sideways row of "contestants" with their best scores.
- **D27 — Profile as an explorer's passport** (owner picked A from 12 designs in
  docs/previews/profile/, after asking which suits the app): a green cover ("Republika ng
  Halaman · Plant Explorer") with an ID page (photo, name, grade, since, signature, EDIT
  PROFILE), then dashed "stamp" boxes for badges and animal friends, sticker book, My
  Garden, My pictures (the bahay kubo wall) and Binhi (opens the Shop), and two oval ink
  stamps for days exploring and best score.
- **D28 — Loading screen credits as a ribbon banner; about 3 seconds** (owner picked 5 of 7
  in docs/previews/credits/): a sunny "A PLANTQUEST STORY BY" ribbon, each developer on a
  white pill. Each piece "bubbly pops" in (small, a little too big, settles), one after
  another at 0.4 s, 1.6 s and 2.8 s (owner picked it from 9 in
  docs/previews/credits/animations.html). The vine now grows steadily from its very start to the
  flower at the end in 4.5 s (it used to rush ahead, then pause), then Binhi hops: about 5 s
  in all (owner asked for 3 s, then 5 s: it felt too fast). With less motion it stays quick. Frames in docs/previews/loading-live/vine-steps.png.

