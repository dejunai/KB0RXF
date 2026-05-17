***

# KB0RXF76 Radio Archive
## Site Specification & Development Proposal
### Prepared for Development — April 2026

***

## 1. Project Overview

KB0RXF76 Radio Archive is a personal digital preservation project and living catalogue documenting one man's four-decade obsessive recording of broadcast radio across multiple states. Beginning in the early-to-mid 1980s in Colorado and continuing through the present, the archive represents thousands of cassette tapes — a continuous, intimate, and unrepeatable record of American radio as heard by one listener, in one life, across one extraordinary journey.

The project is initiated and owned by KB0RXF76, a neurodivergent lifelong radio enthusiast, former pirate shortwave broadcaster, and current Sunday overnight DJ at a working broadcast radio station. The archive is his idea, his life's work, and his alone.

The site serves three purposes simultaneously:
- **Personal preservation** — digitizing and cataloguing a physical collection before further tape degradation occurs
- **Spatial liberation** — creating a trusted digital home for the collection that makes physical retention of the tapes unnecessary
- **Living document** — an ongoing project that gives shape, structure, and audience to a life spent listening

***

## 2. Site Identity

| Element | Value |
|---|---|
| **Site Name** | KB0RXF76 Radio Archive |
| **Domain (target)** | kb0rxf.com |
| **Alias / Author Name** | KB0RXF76 |
| **Tagline (proposed)** | *Four decades. Thousands of tapes. One listener.* |
| **Platform** | WordPress (starter site, scalable to full hosted) |
| **Tone** | Personal, nostalgic, technically precise, unpretentious |

***

## 3. Site Architecture

### 3.1 Primary Pages

**Home**
- Brief identity statement — who KB0RXF76 is, what the archive is, why it exists
- Latest catalogue entries (5–10 most recent posts)
- Archive stats widget: total tapes catalogued, states represented, decade breakdown, tapes digitized vs. pending
- 30-second sample player — featured tape of the week

**About KB0RXF76**
- His story in his voice — pirate shortwave broadcaster, call sign history, the recording habit, the dual-recorder system, the Sunday night DJ gig
- The origin of this project — his idea, his terms
- A note on the collection — what it is, what it isn't, why it can't be shared in full and why the catalogue is the point
- Photo of the wall of license plates if he consents

**The Archive (Catalogue Index)**
- Filterable/searchable index of all tape entries
- Filter by: decade, state/geography, station, format, playback status (recovered / partial / unrecoverable)
- Sortable by date recorded, date catalogued, tape ID

**The Equipment Room**
- His two primary recorders — model, acquisition story, why they matter
- The playback incompatibility explained in his own words
- The digitization setup
- A love letter to the cassette format, if he wants to write one

**Contact / Community**
- Simple contact form
- If community layer is added later: link to forum or social group
- Note on what he welcomes (fellow tape enthusiasts, radio historians, people who remember the stations) and what he doesn't

***

### 3.2 Post Structure — The Catalogue

Each tape or tape batch gets its own WordPress post. Posts are the archive. Everything else is navigation and context.

**Post Categories (top level):**
- `Decade` — 1980s / 1990s / 2000s / 2010s / 2020s
- `Geography` — by state (added as confirmed)
- `Format` — Standard Cassette / Reel-to-Reel
- `Playback Status` — Recovered / Partial Recovery / Unrecoverable / Pending
- `Content Type` — Music / Talk / News / Sports / Mixed / Unknown

**Post Tags (flexible, added organically):**
- Station call letters (e.g., `KBCO`, `KOA`)
- Broadcast format (e.g., `classic-rock`, `top-40`, `am-talk`, `shortwave`)
- Notable content flags (e.g., `live-event`, `news-broadcast`, `holiday-programming`)
- Recorder used (e.g., `recorder-a`, `recorder-b`)
- Personal memory tags (e.g., `colorado`, `road-trip`, `apartment-on-elm`)

***

## 4. The 30-Second Sample

The 30-second sample is a first-class feature, not an afterthought.

**Implementation:**
- WordPress audio block or a lightweight audio player plugin (e.g., CP Media Player or Compact Audio Player — both free)
- Each recovered tape post includes one embedded 30-second clip, selected by KB0RXF76 as the most representative or memorable moment
- Clip is embedded directly in the post — not linked to an external service
- Unrecoverable tapes get a placeholder graphic and a written description of what would have been heard

**Why it matters:**
- It makes the catalogue sensory, not just archival
- It gives visitors a reason to explore beyond reading
- It gives KB0RXF76 a curatorial decision on every tape — which 30 seconds matters most — which deepens his engagement with the project
- It is legally defensible as personal archival sampling on a private/personal site with no monetization

**Sample selection note for KB0RXF76:**
*You choose the 30 seconds. It can be a song you remember, a DJ you loved, a news break, static clearing into signal, anything. Your choice is the point.*

***

## 5. Digitization Workflow

### The Dual-Recorder Constraint

KB0RXF76 recorded on two distinct cassette players. Due to speed inconsistency between devices, tapes recorded on one player must be played back on the same player. Direct cassette-to-USB conversion devices are incompatible with this requirement and should not be used.

**Recommended digitization chain:**

```
Original recorder (A or B)
        ↓
3.5mm headphone out OR RCA out
        ↓
Behringer UCA202 USB Audio Interface (~$30)
        ↓
USB to laptop/desktop
        ↓
Adobe Audition 3.0 (record + edit)
        ↓
Export as MP3 (128kbps sufficient for archival samples)
        ↓
Export full recording → FLAC (archival master, stored locally/cloud)
        ↓
30-second clip extracted in Adobe Audition 3.0
        ↓
Uploaded as audio attachment to WordPress post
```

**Condition assessment before digitization:**
- Visual inspection: shell condition, tape visible through window, no obvious oxide shedding
- Brief rewind test: does tape move freely
- First 10 seconds playback: audio present, speed stable, no squealing
- If any failure at any stage: log as `unrecoverable` or `needs-assessment`, do not force playback

***

## 6. Handling Unrecoverable Tapes

Not every tape will play. This is expected, honest, and not a failure of the project.

**Unrecoverable tapes are catalogued, not discarded from the archive.**

An unrecoverable tape entry includes:
- All known metadata (date range, station, geography, recorder)
- KB0RXF76's memory of the tape — what was on it, why he recorded it, anything he remembers
- Condition notes — what happened when playback was attempted
- Status tag: `Unrecoverable`
- A written description in place of the audio sample

**The framing for KB0RXF76:**
*Real archives have damaged records. Your catalogue noting a tape from 1987 that couldn't be recovered is honest archiving. The memory of it still belongs here. The tape existed. That matters.*

This framing should be introduced before the first unrecoverable tape is encountered, not after.

***

## 7. Storage & Scaling Path

| Phase | Infrastructure | Trigger |
|---|---|---|
| **Phase 1** | WordPress.com starter site (free) | Project launch — catalogue development, template testing, first entries |
| **Phase 2** | kb0rxf.com domain + basic cloud hosting (~$50–100/yr) | KB0RXF76 demonstrates sustained enthusiasm across 50+ entries |
| **Phase 3** | Expanded cloud storage for audio files | Audio library exceeds hosting plan limits |
| **Phase 4** | Grant / community funding | Project has audience, story, and documented scope |

**Phase 4 funding candidates when the time comes:**
- Local arts council grants (Colorado connection is an asset)
- Disability arts funding programs
- Public radio stations — the meta-narrative of a lifelong listener who became a Sunday night DJ is a story they may want to tell
- Internet Archive partnership for long-term preservation
- Patreon from a small passionate community

***

## 8. Community Layer (Phase 2+)

Not built on day one. Earned by the archive.

**When community is added:**
- Simple comments enabled on posts — fellow listeners, station memories, tape enthusiasts
- Optional: a dedicated forum or Facebook group seeded from the about page
- KB0RXF76 moderates on his own terms — this is his space

**What the community is for:**
- People who remember the stations he recorded
- Fellow tape archivists and cassette culture enthusiasts
- Radio historians
- People who just find the story compelling

**What it is not:**
- A place to request full recordings
- A place that changes the project's ownership or direction

***

## 9. Per-Tape Entry Template

This is the WordPress post template for every catalogue entry.

***

### POST TITLE FORMAT:
`[Tape ID] — [Station/Content] — [Approximate Date] — [State]`

*Example: T-0047 — KBCO Boulder — Spring 1989 — Colorado*

***

### POST BODY FIELDS:

**Tape ID** *(assigned sequentially as catalogued)*
T-[XXXX]

**Recorded Approximately**
[Year or year range — month if known]

**Station / Source**
[Call letters, frequency, or best description if unknown]

**Geography**
[City, State — where the signal was received]

**Recorder Used**
[ ] Recorder A
[ ] Recorder B
[ ] Unknown

**Format**
[ ] Standard Cassette
[ ] Reel-to-Reel
[ ] Other: ___________

**Tape Brand / Type** *(if legible on shell)*
[Brand, e.g., TDK D90, Maxell XLII, generic]

**Content Type**
[ ] Music
[ ] Talk / DJ
[ ] News
[ ] Sports
[ ] Mixed
[ ] Unknown

**Playback Status**
[ ] Recovered — full
[ ] Recovered — partial
[ ] Unrecoverable
[ ] Pending digitization

**Condition Notes**
[Brief description of physical condition and playback assessment]

**KB0RXF76 Remembers:**
*[Free text — his memories, associations, why he recorded this, anything he recalls. No minimum, no maximum. His words, his voice.]*

**30-Second Sample**
[Audio player embed — or written description if unrecoverable]

*"[Optional quote from KB0RXF76 about why he chose this 30 seconds]"*

***

**Categories:** [Decade] [Geography] [Format] [Playback Status] [Content Type]
**Tags:** [Station] [Broadcast format] [Recorder] [Personal memory tags]

***

## 10. WP AI Kickoff Prompt

When your WordPress.com AI tokens renew, open a new session on the starter site and use this prompt verbatim:

***

> I am building a personal cassette tape archive blog called **KB0RXF76 Radio Archive**. The site owner is KB0RXF76, a neurodivergent lifelong radio enthusiast who has recorded broadcast radio onto cassette tapes since the early 1980s across multiple US states. The archive is his personal preservation project — not a public streaming library.
>
> I need you to help me set up a WordPress blog with the following structure:
>
> **Pages needed:**
> - Home (with recent posts and a stats widget)
> - About KB0RXF76
> - Archive / Catalogue Index (filterable post index)
> - The Equipment Room
> - Contact
>
> **Post category structure:**
> - Decade: 1980s, 1990s, 2000s, 2010s, 2020s
> - Geography: by US state
> - Format: Standard Cassette, Reel-to-Reel
> - Playback Status: Recovered, Partial Recovery, Unrecoverable, Pending
> - Content Type: Music, Talk, News, Sports, Mixed, Unknown
>
> **Each post represents one tape entry and must include:**
> Tape ID, approximate recording date, station/source, geography, recorder used (Recorder A or Recorder B), format, tape brand, content type, playback status, condition notes, a free-text memory field in the owner's voice, and an embedded 30-second audio sample or written description if unrecoverable.
>
> Please start by setting up the page structure and category taxonomy, then generate a reusable post template using WordPress blocks that I can use for every tape entry going forward.

***

*End of specification document.*

***
