# jwl-linker fork: paste a jw.org link, pick the paragraphs

## Context

JWL Linker (MrBertie, GPL-3) works for scriptures and for `w26.12 30` style lookups, but getting a clean quote out of a publication is hard:

- **Share links without a paragraph do nothing useful.** `https://www.jw.org/finder?srcid=jwlshare&wtlocale=E&prefer=lang&docid=2026688` has `docid` but no `par`. `_fetchParagraphCitation` (main.js:708) only quotes when `parId` is set, so you get a title link and no text.
- **The lookup dumps the whole page as one block.** `_fetchLookupCitation` (main.js:772) takes `.resultItems` `textContent`: no paragraph breaks, headings run into body text, no way to pick the sentence you want.
- **Text loses its formatting.** `_getElementAsText` uses `textContent`, so italics (`***When***`), scripture links and headings are stripped.

Two smaller bugs found while reading:
- `_extractLinkParts` (main.js:1262) does `new URLSearchParams(url)` on the full URL. The first key becomes `https://www.jw.org/finder?srcid`, so `docid` breaks whenever it is the first parameter. Use `new URL(url).searchParams`.
- Paragraph selector `#p${match.parId}${i}` (main.js:730) concatenates digits (`par=4`, i=0 gives `#p40`). Looks wrong. Verify against a real share link that carries `par=` before changing.

### What's installed now
- Local copy = upstream commit `f100b3a` (2025-08-06) plus your one change: default `verseCalloutTemplate` `[!verse]`→`[!cite]`, `pubCalloutTemplate` `[!cite]`→`[!quote]`. Both values are already saved in `data.json`, so the code edit is redundant once settings carry over.
- Upstream has one newer feature since: `openSelectedInWOL` (2025-09-06). The fork picks it up for free.
- Installed from the community store (not BRAT), so a store update would wipe local edits.
- `wol-mcp-connector/` (your Python port) sits inside the plugin folder. Leave it there for now.
- `jw-library-linker` (msakowski) is installed but not enabled. Not touched.

### Live probe (2026-10-17)
- `wol.jw.org/en/wol/d/r1/lp-e/2026688` returns 200. Article "Three Tips to Help You Linger in Prayer". Paragraphs carry `id="pN" data-pid="N"`. Printed page markers: `<span class="pageNum" data-no="30">`, `data-no="31"`. So paragraphs can be grouped by page.
- The lookup page for `w26.12 30` links to `/en/wol/d/r1/lp-e/2026688#h=1:0-9:0`, which gives docid plus paragraph range. Lookup and share link can share one code path.
- `defuddle.md/wol.jw.org/...` returns 200 in 0.9s with clean markdown (headings, italics, scripture links), but drops the `pN` ids and page markers.

## Fetch engine: decision

| Option | Paragraph ids / pages | Formatting | Extra network hop | Mobile |
|---|---|---|---|---|
| Current: `requestUrl` + `textContent` | yes | lost | no | yes |
| defuddle.md hosted API | no | good | yes, third-party server | yes |
| defuddle npm library bundled | partial (works on whole doc) | good | no | needs a build step |
| **`requestUrl` + Obsidian `htmlToMarkdown` per paragraph** | yes | good | no | yes |

Pick the last one. `htmlToMarkdown` ships in the `obsidian` module, so no dependency and no build step. Keep `requestUrl` (it bypasses CORS and already works). Rewrite WOL-relative links (`/en/wol/bc/...`) to absolute URLs before conversion. defuddle stays out.

## Phase 0: fork and rename (one session)

Status: [x] done 2026-10-17 (fork dubefab/jw-quote-linker, clone ~/Developer/jw-quote-linker, deployed; enable jw-quote-linker in Obsidian by hand)

1. `gh repo fork MrBertie/jwl-linker --clone=false` to get `dubefab/jw-quote-linker`.
2. Clone it **outside iCloud** (git inside iCloud corrupts). Location: confirm with fab, default `~/Developer/jw-quote-linker`.
3. Add `upstream` remote. Work on `main` of the fork (it is fab's repo).
4. `manifest.json`: id `jw-quote-linker`, name `JW Quote Linker`, version `0.3.0`, author keeps MrBertie and adds fab. Keep LICENSE (GPL-3) and a README line crediting upstream.
5. Copy this plan into the repo as `PLAN.md` with checkboxes. That file becomes the hand-off between sessions.
6. `deploy.sh` (bash 3.2, self-healing per CLAUDE.md): copies `main.js manifest.json styles.css` into `<vault>/.obsidian/plugins/jw-quote-linker/`. Never touches the old `jwl-linker` folder.
7. Copy `data.json` settings into the new plugin folder on first deploy (only if absent).
8. In Obsidian: disable the store `jwl-linker`, enable `jw-quote-linker`. Do not delete the old folder (Safety rule). Later, BRAT can track `dubefab/jw-quote-linker` once there are GitHub releases.

## Phase 1: link parsing fixes (small, isolated)

Status: [ ] not done

In `main.js`:
- `_extractLinkParts`: parse with `new URL(url).searchParams`. Accept `jw.org/finder` with or without `www`. Accept a finder link with `docid` and no `par` (return `parId: ''`, already allowed).
- Verify the `#p${parId}${i}` selector against a real share link with `par=`. Fix to `#p${Number(parId) + i}` only if the probe confirms the bug.

## Phase 2: article model + paragraph picker (the main feature)

Status: [ ] not done

New helper `_parseArticle(dom, baseUrl)` returns:
```
{ title, pubNav, docId, paragraphs: [{ pid, page, kind: 'heading'|'body'|'question'|'box', md }] }
```
- Walk `p[data-pid]` and headings (`h1–h3`) in document order.
- `page` = the last `.pageNum[data-no]` seen at or before that element.
- `md` = `htmlToMarkdown(cleanedInnerHTML)`. Clean first: drop `.pageNum`, footnote markers, `+ * #` annotation symbols (reuse the cleanup in `_getElementAsText`, main.js:887-899), absolutize links.
- Study questions (`kind: 'question'`) default to unticked.

New `ParagraphPickerModal extends Modal`:
- Header: article title + pub nav.
- Paragraphs grouped under "Page 30", "Page 31". Each row: checkbox, paragraph number, first ~20 words, expand on click.
- Optional preselect range (from lookup `#h=1:0-9:0` or from a requested page).
- Insert button builds the existing `pubCalloutTemplate` / `pubTemplate` output, so your `[!quote] PUB. — {title}` settings keep working. Title link points to `jwlibrary:///finder?docid=…&par=<first ticked pid>` when "citation link" is on.
- Keyboard: arrows move, space ticks, enter inserts.

Wire it up:
- `insertCitation` → `Cmd.citeParagraph*`: if the link has no `parId`, open the picker instead of returning a title only.
- New command "Cite from publication…" that works on whatever is selected: a share link, a wol link, or a lookup reference.
- `_fetchLookupCitation` (`w26.12 30`): read the `/d/…#h=` link from the lookup result, fetch that article, open the picker with the requested page preselected. Old one-block behaviour goes away.
- History cache (`view.addToHistory`) stores the parsed article per docid so reopening the picker is instant.

## Phase 3: polish

Status: [ ] not done

- Settings: "Skip study questions by default" (on), "Include headings" (on).
- Notice on failure names the URL that failed (current notices say only "lookup failed").
- README: document the share-link flow and the picker.
- Tag `v0.3.0`, GitHub release with the three files, so BRAT can install it on iPhone/iPad.

## Verification

Run each in the real vault after `deploy.sh`, reload the plugin each time:
1. Paste the share link `…docid=2026688` → picker opens, title "Three Tips to Help You Linger in Prayer", groups Page 30 and Page 31, 11 body paragraphs.
2. Tick p2 and p4 → callout `> [!quote] PUB. — [Three Tips…](…)` with two paragraphs, `Prov. 15:8` stays a link, `***When***` stays italic.
3. Select `w26.12 30` → picker opens on the same article with page 30 preselected. Confirm it is docid 2026688 and not another article (identity check, not just "something came back").
4. A share link with `par=` → quotes that exact paragraph, no picker (regression check for the old path).
5. A wol `/d/…#h=` link → same as 4.
6. Scripture commands (verse cite, callout, open in JW Library) unchanged: run one of each.
7. A bad link and airplane mode → clear error notice, editor text untouched.
8. Reading mode and editing mode, light and dark theme for the modal.
9. iPhone via BRAT after the release (Phase 3).

## How to continue across sessions

The state lives in the repo's `PLAN.md` checkboxes, not in this chat.

- **Clear after Phase 0** (fork, clone, deploy script). That session is mostly shell and git noise.
- **Clear after Phase 2** if the session is long or the status line shows a cold count of 100k+.
- Phase 1 and 2 can share a session. Phase 3 is small.

To resume after `/clear`, open Claude Code in the clone (`cd ~/Developer/jw-quote-linker`) and say:

> Continue the jw-quote-linker plan. Read PLAN.md, do the next unchecked phase, run its verification steps, tick the boxes, and commit.

Per your standing orchestration rule, design work (Phase 2 article model and modal) stays on Opus, and mechanical work (deploy script, README, release) can go to `fast-worker` with a spec, only when you ask for subagents.
