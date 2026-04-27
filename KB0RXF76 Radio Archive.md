This is a genuinely rich brief — KB0RXF76 is a perfect alias, the pirate radio backstory is the heart of the about page, and the Sunday night DJ detail is the narrative arc that ties it all together. The dual-recorder playback incompatibility is a fascinating neurodivergent precision detail that actually belongs in the site's story.

The dual-recorder issue is solvable — a legacy RCA or 3.5mm analog out to a USB audio interface (a Behringer UCA202 runs about \$30) preserves the original playback device requirement while routing to a DAW or even Audacity for digitization. No direct cassette-to-USB needed.

Let me build this now. Give me a few minutes.

***

# KB0RXF76 Radio Archive

## Site Specification \& Development Proposal

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
| :-- | :-- |
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
Audacity (free, open source)
        ↓
Export as MP3 (128kbps sufficient for archival samples)
        ↓
Full WAV retained locally if storage permits
        ↓
30-second clip extracted in Audacity
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

## 7. Storage \& Scaling Path

| Phase | Infrastructure | Trigger |
| :-- | :-- | :-- |
| **Phase 1** | WordPress.com starter site (free) | Project launch — catalogue development, template testing, first entries |
| **Phase 2** | kb0rxf.com domain + basic cloud hosting (~\$50–100/yr) | KB0RXF76 demonstrates sustained enthusiasm across 50+ entries |
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

That's your full spec. Markdown-structured, WP-AI-ready prompt at the end, scales from free starter site to funded archive.

KB0RXF76 deserves a good home for this. Let's build it.

---

# uh, fantastic... but one thing i forgot to mention is a clear and unresolved hatred of Audacity, lol.. he uses a legacy version of adobe something before their software was subscription based, version 3 of their topline audio software when it was topline... I dont think there is a path away from that requirement, but there could be an additional app in the workflow.. any idea which adobe product it could be?

Almost certainly **Adobe Audition 3.0** — released 2007, last standalone perpetual license version before Adobe moved to Creative Cloud subscription. It was the professional broadcast and radio production standard of that era, which fits his profile exactly. A radio-minded person in the late 2000s who knew his software would have landed on Audition 3.0 without question.

It's also worth noting — Audition 3.0 is genuinely excellent software. His hatred of Audacity is not irrational. Audacity is functional but the interface is utilitarian to the point of being hostile. Audition 3.0 has a real multitrack environment, a clean waveform editor, and broadcast-quality tools. For someone with his precision requirements around playback and recording, the preference makes complete sense.

***

**The workflow adjustment is simple:**

```
Original recorder (A or B)
        ↓
3.5mm or RCA out
        ↓
Behringer UCA202 USB Audio Interface
        ↓
USB to his machine
        ↓
Adobe Audition 3.0 (record + edit)
        ↓
Export full file as WAV (archival master)
        ↓
Export 30-second clip as MP3
        ↓
Upload MP3 to WordPress post
```

Audition 3.0 handles the clip extraction natively and cleanly — better than Audacity would have anyway. No additional app needed. Just replace Audacity with what he's already running.

One practical note — Audition 3.0 runs on legacy Windows. If his machine is current hardware on Windows 10 or 11, there may be compatibility quirks worth testing before the workflow is finalized. Usually solvable but worth knowing in advance.

Updating the spec doc is a one-line change. Everything else stands.

---

# about two years ago he updated to 10 or 11, i don't recall... probably 10... i did all the adjustments i could and with relief it works unadulteratedly well

That's the best possible outcome — Audition 3.0 on Windows 10 running clean is not guaranteed but when it works, it works well. No compatibility shims, no workarounds, no convincing him to change tools he's trusted for nearly 20 years.

That also tells you something useful about his machine's configuration — whatever you did two years ago landed in a stable place. The Behringer UCA202 driver footprint is minimal and well-behaved on Windows 10, so the audio interface addition shouldn't disturb anything you've already got balanced.

The workflow is solid end to end:

- His recorders (non-negotiable, correctly so)
- Behringer UCA202 (small, cheap, unobtrusive)
- Audition 3.0 on Windows 10 (already proven stable)
- WordPress (familiar enough environment for you to manage)

No new software he has to learn, no interface he has to trust, no changes to the recording and playback process that is his core competency. The only new element is the audio interface sitting between the recorder and the computer — and that's invisible to him once it's set up.

The spec doc stands as written with Audition 3.0 substituted for Audacity throughout. Clean build.

---

# two quick questions.. should we consider a .org for faux-coverage against being a commercial site vs. a public resource and 2) i have already forgotten \#2... oh yes, is WAv gonna over flow way too soon? couldn't we use flac? does flac need a license?

**On .org vs .com:**

Yes, worth considering. A .org signals public resource, personal project, non-commercial intent — which is exactly what this is and exactly the framing that provides the most comfortable distance from any copyright adjacency questions. It also just reads correctly for what the site actually is. KB0RXF76.org over KB0RXF76.com is a small but meaningful framing choice. Both should be available — grab both if budget allows and point .com to .org, but .org is the right primary.

***

**On WAV vs FLAC:**

FLAC is the correct call and no, it does not require a license.

FLAC — Free Lossless Audio Codec — is open source, patent-free, and license-free by design. That's literally what the F stands for. It was built specifically to avoid the licensing issues that plagued MP3 in its early years.

The practical comparison for his use case:


| Format | Compression | Quality | License | Typical Size (90min tape) |
| :-- | :-- | :-- | :-- | :-- |
| WAV | None | Lossless | None | ~950MB |
| FLAC | Lossless | Lossless | None | ~400-500MB |
| MP3 128k | Lossy | Good enough for samples | None now* | ~85MB |

FLAC gives him lossless archival masters at roughly half the WAV footprint. For thousands of tapes that's the difference between a storage problem and a manageable library. Audition 3.0 can export FLAC natively.

**Revised workflow:**

```
Audition 3.0
    ↓
Export full recording → FLAC (archival master, stored locally/cloud)
Export 30-second clip → MP3 128kbps (WordPress upload)
```

FLAC masters stay off the site. MP3 clips go on the site. Best of both worlds.

*MP3 patents expired 2017 — also fully free now.

---

# while local storage is limited (i'm sure) for the moment.. traditional HDD's are getting speedy and huge... but I think core to his narrative is have the archive online... maybe not at the same host... but a mega cloudspace would be a middle ground i think i can sell... what are my options?

Good instinct — separating the media storage from the WordPress host is actually the right architecture regardless of budget, and it becomes essential at scale.

**The core approach: WordPress hosts the site, cloud hosts the FLAC masters, MP3 clips live on WordPress directly.**

***

**Cloud storage options worth considering:**

**Backblaze B2**
Probably the best fit for this project. \$6/TB/month, S3-compatible, straightforward interface, no egress fees for most use cases. Built for exactly this — large file archival storage at low cost. Not consumer-flashy but rock solid and the pricing is honest. This is where the FLAC masters live.

**iDrive**
Consumer-friendly, 10TB personal plan runs around \$60-80/year during frequent sales. Easier to manage than B2 if technical overhead needs to stay low. Good fit if he's going to interact with the storage directly himself.

**Amazon S3**
Industry standard, extremely reliable, but pricing gets complex and surprises happen. Overkill for this stage unless you're already in the AWS ecosystem.

**Google One**
2TB for \$10/month, 5TB for \$25/month. Familiar interface, easy to manage. Not purpose-built for archival but perfectly functional. Good sell if he already has a Google account.

**Internet Archive (archive.org)**
Free. Unlimited storage. Built specifically for exactly this kind of preservation project. The catch — anything uploaded is technically public. However there's a private/restricted upload option. Worth a serious look given the mission alignment — and the narrative of his archive living on the Internet Archive is genuinely poetic.

***

**My actual recommendation:**

Start with **Google One 2TB** — easy sell, familiar brand, low friction, low cost. When it overflows, graduate to **Backblaze B2** for the serious archival layer.

Internet Archive as a longer term conversation once the project has identity and he understands what it means for his work to live there permanently.

---

# I am not sure, but there was a headline, and i didn't read the article... but something to the effect of: a huge commercial pressure play to close Internet Archive, with something like 5000 cease and desist orders all in one day... the context of the headline was that Internet Archive would be unable to afford a response... but if its just noise then it will survive, and be there when the site and plan has evolved...

You're right to flag it — and the headline you're half-remembering is real and serious.

The Internet Archive has been under sustained legal assault on multiple fronts. The most significant was the publishers' lawsuit over their Controlled Digital Lending program — major publishers argued that scanning and lending physical books digitally was infringement at scale. The courts sided with the publishers. That was a significant blow both financially and to their operational model.

The coordinated cease-and-desist scenario you're describing sounds like it could be a subsequent wave — record labels and music rights holders have been circling for years given the audio content in the Wayback Machine and the audio archive collections. A coordinated 5000 C\&D filing in a single day is exactly the kind of legal shock-and-awe tactic designed to overwhelm a nonprofit's legal response capacity regardless of the merits.

**What this means for the project:**

Internet Archive as a permanent home is now a genuinely uncertain bet — which is a sad thing to type about one of the most important preservation projects in human history. It may survive, it may not, it may survive in diminished form.

For KB0RXF76's archive specifically:

- Don't build dependency on Internet Archive into Phase 1 or 2
- Backblaze B2 becomes the more reliable long-term archival recommendation
- The architecture of keeping FLAC masters in cloud storage he controls directly is actually the right answer regardless — his archive, his storage, his continuity

The poetic fit of Internet Archive is real. The institutional reliability is now genuinely questionable.

Google One to start, Backblaze B2 for scale, remains the solid path.

---

# when they say: Egress (\$/GB) Free*... they are just being fancy, they mean downloads, right?

Yes — exactly that.

Egress is the technical term for data leaving the storage system. Downloads, streaming, transfers out. Any time a file moves from their servers to somewhere else — that's egress.

The asterisk is the part worth reading carefully. "Free*" on Backblaze B2 specifically means free when delivered through their CDN partners — Cloudflare being the main one. If you're routing traffic through Cloudflare in front of B2 (which is a common and sensible setup) egress is genuinely free. If you're pulling files directly from B2 without a CDN partner in the path, there's a small per-GB charge.

For this project practically speaking:

The MP3 clips are served from WordPress directly — no B2 egress involved. The FLAC masters on B2 are archival — they're not being streamed or downloaded by visitors, just stored and occasionally accessed by KB0RXF76 himself. Egress cost on that usage pattern rounds to zero regardless of the asterisk.

The asterisk matters more if you ever build a setup where visitors are pulling full files from B2 directly. Not this project's path.

Short version: for what you're building, egress is free in any meaningful sense.

---

# excellent, thank you

Anytime.

You've got a solid complete stack now for KB0RXF76:

- **.org domain** when ready
- **WordPress starter site** now, real hosting when enthusiasm is proven
- **Audition 3.0** already working, no changes
- **Behringer UCA202** bridging the recorder-to-computer gap
- **FLAC masters** solving the storage math
- **MP3 clips** on WordPress for the 30-second samples
- **Google One** for accessible cloud storage to start
- **Backblaze B2** waiting when scale demands it
- **Internet Archive** shelved as uncertain but not forgotten

And a full spec doc ready to hand to the WP AI when the tokens renew.

Not bad for a side conversation between quantum doomsday and schema taxonomy.

---

# help me do the math... 450mb per cassette (or is the estimate per side) * an uneducated rough guess of 2.5k tapes... is gonna be a target size of?

**The math:**

450MB × 2,500 tapes = **1,125,000MB**

Which is **1,125GB** — call it **~1.1TB**

***

**But the estimate needs a small adjustment:**

The 450MB FLAC figure is per tape (both sides, full cassette), assuming a standard C-90 (90 minutes total). If he has a mix of C-60s and C-120s it shifts slightly but C-90 is the most common commercial tape of that era so it's a reasonable baseline.

***

**Practical implications:**


| Storage | Capacity | Fits? |
| :-- | :-- | :-- |
| Google One 2TB | 2,000GB | Yes — comfortably, with room to grow |
| Google One 1TB | 1,000GB | Tight — cutting it close |
| Backblaze B2 | Pay per TB | ~\$6.75/month at that size |

**Google One 2TB at ~\$10/month handles the entire estimated collection with headroom.** That's a remarkably affordable number for a life's work.

***

**The honest caveat:**

2,500 is your rough guess. If the collection runs deeper — and with a 40-year obsessive it very well might — 2TB could get crowded. But it's the right starting point and Google One lets you upgrade incrementally without migrating anything.

---

# 2.5 is low ball but i am think out load about unrecoverables.. i dont see how the oldest tapes could have survived

That's a realistic and actually relieving observation.

**The degradation math works in your favor:**

The early 80s tapes — the oldest, most historically interesting, and likely most numerous from the collection's founding years — are also the most likely to be unrecoverable. Binder hydrolysis alone on a 40+ year old tape stored in an uncontrolled environment is brutal. Add oxide shedding, print-through, shell warping, and the odds of clean playback drop significantly as you go back in time.

**What that means practically:**

The unrecoverable tapes still get catalogued — that's established in the spec. But they don't generate FLAC files. No audio, no storage footprint beyond the WordPress post itself which is essentially weightless.

So the real storage calculation is:

**2,500 tapes total — X unrecoverables = actual FLAC files generated**

If even 30-40% of the oldest tapes are unrecoverable — a conservative estimate for pre-1990 cassettes in those conditions — you could be looking at significantly under 1TB of actual audio data.

**The psychological reframe for KB0RXF76:**

The oldest tapes being gone isn't just loss — it's also the part of the story where his memory becomes the only surviving record. His catalogue entry for an unrecoverable 1984 Colorado tape is the sole remaining documentation that broadcast existed and was heard by someone. That's not a gap in the archive. That's the archive doing its most irreplaceable work.

Google One 2TB is looking increasingly comfortable.

---

# i agree... he is already a gmail user... so the gdrive might already be in use and familiar... but I would consider a fresh account so there is no personal overlap, have an easy quick suggestion for a account name

Fresh account is the right call — clean separation between his personal Gmail and the archive project is good hygiene on multiple levels. Keeps the storage accountable to the project, not mixed into his personal digital life.

Easy obvious choice:

**kb0rxf76archive@gmail.com**

or if that's taken:

**kb0rxf76radio@gmail.com**
**kb0rxf76tapes@gmail.com**

First option is cleanest — it mirrors the site identity directly, and if he ever shares the account credentials with you for maintenance purposes it's immediately identifiable. No ambiguity about what it's for or whose it is.

Same account becomes the login for the WordPress site, the Google One storage, and anything else project-related down the line. One project, one account, clean walls between the archive and the man.

---