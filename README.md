# JW Quote Linker Plugin for [Obsidian](https://obsidian.md)

> Fork of [MrBertie/jwl-linker](https://github.com/MrBertie/jwl-linker) (GPL-3.0), credit to MrBertie. Plugin id `jw-quote-linker`. The fork adds a paragraph picker for publication citations, see below.

Display all scripture references as *JW Library* links In Reading View. Adds commands to convert scriptures references and JW.Org links to *JW Library* links. Adds commands to fetch verse, paragraph, and publication citations.

# How to Install

With [BRAT](https://github.com/TfTHacker/obsidian42-brat): add the beta plugin `dubefab/jw-quote-linker`. This works on iPhone and iPad too.

Manually: download `main.js`, `manifest.json` and `styles.css` from the latest [release](https://github.com/dubefab/jw-quote-linker/releases), put them in `{Obsidian Vault}/.obsidian/plugins/jw-quote-linker/`, restart Obsidian and enable the plugin in *Community Plugins*.

The plugin id differs from the original `jwl-linker`, so both can be installed. Disable the original to avoid duplicate commands.

# How to Use In Reading View

Displays all valid scripture references as *JW Library* links.
Open any page that contains scripture references, e.g. `Rom 1:20; Psalm 89:18; 1 Cor 9:26, etc...` and then simply switch to *Reading View.*  

You should see that all scripture references are now displayed as functioning hyperlinks; in addition any abbreviated bible book names will be written out in full.  Invalid scripture references will be ignored.

> Note: This only affects the *Reading View*, it does not modify the underlying Markdown text.


# How to Use In Editing View

The plugin provides many new commands to work with scriptures, publication references and JW.Org links.

To access the commands:
- On Desktop: right-click next to the scripture, and hover on *JWL Linker* to see the list of commands.
![Menu](menu.png)
  
- On Mobile: add a toolbar item for the *JWL Linker* command.

| Command                               | Mode | Target                          | Result                                                                                  | Replace target | 
| -------------------------------------| ---- | ------------------------------ | ------------------------------------------------------------------------------------ | ------------- |
| Cite verses                           | Edit | Scripture reference             | `[[ JW Library url \| scripture reference ]] < Verses in plain format >`                | Adds below     | 
| Cite verses as callout                | Edit | Scripture reference             | `[[ JW Library url \| scripture reference ]]<br/>< Verses in callout format >`          | Adds below     | 
| Cite jw.org url                       | Edit | wol.jw.org \| jw.org/finder url | `[[ JW Library url \| article nav title ]]<br/>< Picked paragraphs in plain format >`   | Replaces       | 
| Cite jw.org url as callout            | Edit | wol.jw.org \| jw.org/finder url | `[[ JW Library url \| article nav title ]]<br/>< Picked paragraphs in callout format >` | Replaces       | 
| Cite publication lookup               | Edit | Publication reference           | `[[ JW Library url \| article nav title ]]<br/>< Picked paragraphs in plain format >`   | Replaces       | 
| Cite from publication…                | Edit | jw.org url \| pub. reference     | Opens the paragraph picker, then as above                                               | Replaces       | 
| Lookup selected text on WOL           | Edit | All text \| pub. reference       | `Open WOL lookup using selected as search text`                                         | Opens          | 
| Add title to jw.org url               | Edit | wol.jw.org \| jw.org/finder url | `[[ original url \| article nav title ]]`                                               | Replaces       | 
| Convert scriptures to JW Library      | Edit | Scripture reference             | `[[ JW Library url \| scripture reference ]]`                                           | Replaces       | 
| Convert jw.org url to JW Library      | Edit | wol.jw.org \| jw.org/finder url | `JW Library url<br/>(Converts just the url portion)`                                    | Replaces       | 
| Open scripture at caret in JW Library | Edit | Scripture reference             | `Open JW Library at the scripture`                                                      | Opens          | 
| (Link scriptures as JW Library)       | HTML | Scripture reference             | `<a href …> scripture reference </a>`                                                   | Replaces       | 



# Details on the usage

### Cite verses

This command fetches bible verse content online and inserts (or cites) the text directly into the page markdown content with plain formatting.  Any range of verses with in a single chapter is accepted, e.g. `Ac 12:1-4.`
Click anywhere in the scripture reference, then click the run the command.  The plugin will show a popup notice while it is fetching the citation, and then insert it together with the scripture.

## Cite verses as callout

As above but uses callout formatting.

----

## Cite jw.org url

Select a jw.org share link (the kind you get from *Share*) or a wol.jw.org link. The plugin reads the link even when another plugin has already turned it into `[Title](url)`. Select the whole link, or put the cursor on its line with nothing selected.

- A link that names a paragraph (`par=4`, or `#h=4`) inserts that paragraph straight away.
- A link without a paragraph opens the **paragraph picker**.

The citation replaces the link. Italics and scripture links in the article are kept. The title links to the first picked paragraph in *JW Library* (or on wol.jw.org if *Link cited scripture* is off).

Note: to create a paragraph link in wol.jw.org first click on a paragraph (you will see faint underlining), then copy the page link.

## Cite jw.org url as callout

As above, but uses the callout template.

----

## Cite publication lookup

Select a publication reference such as `w26.12 30` and run the command. The plugin finds the article, and the picker opens with the paragraphs of that reference ticked. The citation uses the plain template, and replaces the reference. *Cite jw.org url as callout* on the same text uses the callout template.

## Cite from publication…

Accepts a jw.org or wol link, or a publication reference, and always opens the picker. Uses the plain template.

## The paragraph picker

Lists the article's paragraphs under the printed page they appear on.

- Everything is ticked to start. Study questions, and song, date and focus lines, start unticked. Untick what you do not need.
- Click a paragraph's text to expand it.
- Keys: up and down move, space ticks, enter inserts, esc cancels and leaves your note unchanged.

## Lookup selected text on WOL

Open WOL website and search based on the selected text. Works well for publication references also.

----

## Add title to jw.org url 

Adds the correct navigation title to an existing wol.jw.org link.

## Convert scripture to JW Library 

This command converts Bible scripture references to *JW Library* links.
Click anywhere in a line or select text that contains scripture references then click the command and the scriptures should be converted to a local JW Library links.

> Note: Unlike the 'Reading View' option above this command permanently rewrites scripture references as a markdown style link in the Markdown text.  The Reading View option is non-destructive.

## Convert jw.org url to JW Library

Converts existing wol.jw.org and jw.org Finder style links [^1] into local JW Library links.

## Open scripture at caret in JW Library

Open the scripture under the caret in the local JW Library app.

----

# Opening links

Click on a newly created link to open it directly in your installed *JW Library* app at that scripture or publication reference.


# Plugin Settings

The various templates and other parameters can be changed in the plugin settings, including:

- *Skip study questions by default* and *Include headings*: what the picker ticks to start.
- *Replace the source when citing*: turn off to keep the link or reference above the citation.


# Tips for using Commands

You can also:
  1. Use a plugin like *Commander* to add a new command wherever you prefer
  2. Use the *Command palette* `Ctrl + P` to call up the commands as needed; just start typing "jw..." and they should be listed  
  3. You can also used *Pinned commands* in the *Command Palette* to keep them available at the top (works well on mobile)

[^1]: The type of link you get when you click on the 'Share Link' option on JW.Org, WOL.Org, or in the *JW Library* App.

